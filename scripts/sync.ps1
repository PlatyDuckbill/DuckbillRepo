#Requires -Version 7.4
[CmdletBinding()]
param(
    [switch]$Check,
    [string]$RootDirectory = (Join-Path $PSScriptRoot '..')
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = [IO.Path]::GetFullPath($RootDirectory)
$utf8 = [Text.UTF8Encoding]::new($false)
$publicHeaders = @{ 'User-Agent' = 'DuckbillRepo/1.0' }
$apiHeaders = @{ 'User-Agent' = 'DuckbillRepo/1.0'; Accept = 'application/vnd.github+json'; 'X-GitHub-Api-Version' = '2022-11-28' }
if ($env:GITHUB_TOKEN) { $apiHeaders.Authorization = "Bearer $env:GITHUB_TOKEN" }

function Get-Bytes([string]$Url, [switch]$Api) {
    # Credentials go only to api.github.com, never to raw files or release redirects.
    if ($Api -and !($Url.StartsWith('https://api.github.com/', [StringComparison]::Ordinal))) {
        throw 'Refusing to send API credentials to another host.'
    }
    $headers = if ($Api) { $apiHeaders } else { $publicHeaders }
    $response = Invoke-WebRequest -Uri $Url -Headers $headers -TimeoutSec 60 -MaximumRetryCount 2 -RetryIntervalSec 3
    return ,$response.RawContentStream.ToArray()
}

function Get-Json([string]$Url, [switch]$Api) {
    $bytes = Get-Bytes $Url -Api:$Api
    return ,($utf8.GetString($bytes) | ConvertFrom-Json -AsHashtable -NoEnumerate)
}

function Get-Sha256([byte[]]$Bytes) {
    return [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($Bytes)).ToLowerInvariant()
}

function Assert-That([bool]$Condition, [string]$Message) {
    if (!$Condition) { throw $Message }
}

function Get-ZipBytes($Entry) {
    $inputStream = $Entry.Open()
    $outputStream = [IO.MemoryStream]::new()
    try {
        $inputStream.CopyTo($outputStream)
        return ,$outputStream.ToArray()
    } finally {
        $inputStream.Dispose()
        $outputStream.Dispose()
    }
}

$sources = [IO.File]::ReadAllText((Join-Path $root 'sources.json')) | ConvertFrom-Json -AsHashtable -NoEnumerate
Assert-That ($sources -is [array] -and $sources.Count -gt 0) 'sources.json must be a nonempty array.'
$names = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
$manifests = [Collections.Generic.List[object]]::new()
$records = [Collections.Generic.List[object]]::new()

foreach ($source in $sources) {
    $name = [string]$source.InternalName
    $repo = [string]$source.Repository
    $branch = [string]$source.Branch
    $path = [string]$source.ManifestPath
    Assert-That ($name -cmatch '^[A-Za-z][A-Za-z0-9]*$' -and $names.Add($name)) 'Invalid or duplicate InternalName.'
    Assert-That ($repo -cmatch '^PlatyDuckbill/[A-Za-z0-9_.-]+$') "Unexpected repository: $repo"
    Assert-That ($branch -cmatch '^[A-Za-z0-9_.-]+$' -and $path -ceq 'repo/pluginmaster.json') 'Unexpected source branch or manifest path.'

    # Resolve the last commit affecting this file, then read its immutable contents.
    $commits = Get-Json "https://api.github.com/repos/$repo/commits?sha=$branch&path=$path&per_page=1" -Api
    Assert-That ($commits -is [array] -and $commits.Count -eq 1) "No source commit for $repo."
    $commit = [string]$commits[0].sha
    Assert-That ($commit -cmatch '^[a-f0-9]{40}$') 'Invalid source commit.'
    $manifestUrl = "https://raw.githubusercontent.com/$repo/$commit/$path"
    $sourceBytes = Get-Bytes $manifestUrl
    $entries = $utf8.GetString($sourceBytes) | ConvertFrom-Json -AsHashtable -NoEnumerate
    Assert-That ($entries -is [array] -and $entries.Count -eq 1) "Expected one stable plugin in $repo."
    $entry = $entries[0]
    Assert-That ($entry -is [Collections.IDictionary] -and $entry.InternalName -ceq $name) "Manifest identity mismatch: $repo."
    $version = [string]$entry.AssemblyVersion
    Assert-That ($version -cmatch '^\d+\.\d+\.\d+\.\d+$') "Invalid version: $name."
    Assert-That ($entry.DalamudApiLevel -is [long] -and $entry.DalamudApiLevel -gt 0) "Invalid API level: $name."
    Assert-That ($entry.RepoUrl -ceq "https://github.com/$repo") "Repository URL mismatch: $name."
    foreach ($field in @('Name', 'Author', 'Description', 'Punchline')) {
        Assert-That ($entry[$field] -is [string] -and ![string]::IsNullOrWhiteSpace($entry[$field])) "Missing $field in $name."
    }
    Assert-That (!$entry['IsTestingExclusive'] -and [string]::IsNullOrEmpty($entry['DownloadLinkTesting'])) "Testing channels require separate validation: $name."
    $tag = "v$version"
    $assetName = "$name-$version.zip"
    $download = "https://github.com/$repo/releases/download/$tag/$assetName"
    Assert-That ($entry.DownloadLinkInstall -ceq $download -and $entry.DownloadLinkUpdate -ceq $download) "Unexpected download URL: $name."

    $release = Get-Json "https://api.github.com/repos/$repo/releases/tags/$tag" -Api
    Assert-That (!$release.draft -and !$release.prerelease -and $release.tag_name -ceq $tag) "Not a public stable release: $name."
    $assets = @($release.assets | Where-Object name -CEQ $assetName)
    $checksums = @($release.assets | Where-Object name -CEQ "$assetName.sha256")
    Assert-That ($assets.Count -eq 1 -and $checksums.Count -eq 1) "Missing ZIP or SHA-256 asset: $name."
    $asset = $assets[0]
    Assert-That ($asset.browser_download_url -ceq $download -and $asset.size -gt 0 -and $asset.size -le 100MB) "Invalid ZIP asset: $name."
    Assert-That ($checksums[0].browser_download_url -ceq "$download.sha256") "Unexpected checksum URL: $name."
    $checksumText = $utf8.GetString((Get-Bytes "$download.sha256")).Trim()
    $checksumPattern = '^([a-fA-F0-9]{64})\s+\*?' + [regex]::Escape($assetName) + '$'
    Assert-That ($checksumText -match $checksumPattern) "Invalid checksum file: $name."
    $expectedHash = $Matches[1].ToLowerInvariant()
    $zipBytes = Get-Bytes $download
    $zipHash = Get-Sha256 $zipBytes
    Assert-That ($zipBytes.Length -eq $asset.size -and $zipHash -ceq $expectedHash) "ZIP size or SHA-256 mismatch: $name."
    if ($asset['digest']) {
        Assert-That ($asset['digest'] -ceq "sha256:$zipHash") "GitHub asset digest mismatch: $name."
    }

    $zipStream = [IO.MemoryStream]::new($zipBytes, $false)
    $zip = [IO.Compression.ZipArchive]::new($zipStream, [IO.Compression.ZipArchiveMode]::Read)
    try {
        $zipNames = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
        foreach ($file in $zip.Entries) {
            Assert-That ($zipNames.Add($file.FullName)) "Duplicate ZIP path: $name."
            Assert-That ($file.Length -le 100MB) "Oversized ZIP entry: $name."
        }
        $jsonFile = $zip.GetEntry("$name.json")
        $dllFile = $zip.GetEntry("$name.dll")
        Assert-That ($null -ne $jsonFile -and $null -ne $dllFile) "Root manifest or DLL missing: $name."
        $packaged = $utf8.GetString((Get-ZipBytes $jsonFile)) | ConvertFrom-Json -AsHashtable
        foreach ($field in @('InternalName', 'AssemblyVersion', 'DalamudApiLevel', 'LoadRequiredState', 'LoadSync', 'CanUnloadAsync', 'LoadPriority')) {
            Assert-That ($packaged.Contains($field) -and $entry.Contains($field) -and $packaged[$field] -ceq $entry[$field]) "ZIP manifest $field mismatch: $name."
        }
        # Read assembly metadata without loading or executing the plugin.
        $dllStream = [IO.MemoryStream]::new((Get-ZipBytes $dllFile), $false)
        $pe = [Reflection.PortableExecutable.PEReader]::new($dllStream)
        try {
            $metadata = [Reflection.Metadata.PEReaderExtensions]::GetMetadataReader($pe)
            $assembly = $metadata.GetAssemblyDefinition()
            Assert-That ($metadata.GetString($assembly.Name) -ceq $name -and $assembly.Version.ToString() -ceq $version) "DLL identity or version mismatch: $name."
        } finally {
            $pe.Dispose()
            $dllStream.Dispose()
        }
    } finally {
        $zip.Dispose()
        $zipStream.Dispose()
    }

    $iconUrl = [string]$entry.IconUrl
    $iconPrefix = "https://raw.githubusercontent.com/$repo/$tag/assets/"
    Assert-That ($iconUrl.StartsWith($iconPrefix, [StringComparison]::Ordinal) -and $iconUrl.EndsWith('.png', [StringComparison]::Ordinal)) "Icon must use the release tag: $name."
    $iconBytes = Get-Bytes $iconUrl
    Assert-That ($iconBytes.Length -ge 24 -and [Convert]::ToHexString($iconBytes[0..7]) -ceq '89504E470D0A1A0A') "Invalid icon PNG: $name."

    $manifests.Add($entry)
    $records.Add([ordered]@{
        InternalName = $name
        AssemblyVersion = $version
        Repository = $repo
        SourceCommit = $commit
        ManifestUrl = $manifestUrl
        ManifestSha256 = Get-Sha256 $sourceBytes
        ReleaseUrl = $release.html_url
        DownloadUrl = $download
        ZipSha256 = $zipHash
        ZipSize = $zipBytes.Length
        IconSha256 = Get-Sha256 $iconBytes
    })
    Write-Host "Validated $name $version (ZIP SHA-256 $zipHash)"
}

# Do not change either output until every source and package has passed validation.
$outputs = [ordered]@{
    'pluginmaster.json' = (ConvertTo-Json -InputObject $manifests.ToArray() -Depth 50).Replace("`r`n", "`n") + "`n"
    'sources.lock.json' = (ConvertTo-Json -InputObject $records.ToArray() -Depth 20).Replace("`r`n", "`n") + "`n"
}
foreach ($file in $outputs.Keys) {
    $destination = Join-Path $root $file
    $same = [IO.File]::Exists($destination) -and [IO.File]::ReadAllText($destination) -ceq $outputs[$file]
    if ($Check) {
        Assert-That $same "Generated file is out of date: $file. Run scripts/sync.ps1 to update it."
    } elseif (!$same) {
        [IO.File]::WriteAllText($destination, $outputs[$file], $utf8)
        Write-Host "Updated $file"
    }
}
if ($Check) { Write-Host 'Published sources, packages and checked-in index agree.' }
