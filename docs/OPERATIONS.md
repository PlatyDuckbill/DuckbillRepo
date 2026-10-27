# 배포·운영 안내

## 평소 배포

DuckbillTweak 또는 DuckbillFisher 중 변경한 플러그인만 기존 절차대로 검증하고 공개합니다.

1. 플러그인을 빌드하고 리소스·패키지와 필요한 실기 확인을 진행합니다.
2. 버전 태그와 정식 GitHub Release를 공개합니다.
3. Release에 `<InternalName>-<4자리 버전>.zip`과 같은 이름의 `.zip.sha256` 파일을 올립니다.
4. 해당 플러그인 저장소 `main`의 `repo/release.json`을 갱신합니다. 패키징 스크립트가 만드는 단일 객체 `release.json`을 사용하며 기존 `repo/pluginmaster.json`은 복원하지 않습니다.
5. 공용 저장소 Actions의 성공과 [설치 JSON](https://raw.githubusercontent.com/PlatyDuckbill/DuckbillRepo/main/pluginmaster.json)의 버전을 확인합니다.

예: Tweak 0.2.0.0은 `v0.2.0.0` 태그, `DuckbillTweak-0.2.0.0.zip`, `DuckbillTweak-0.2.0.0.zip.sha256`을 사용합니다.
Fisher도 동일한 명명 규칙을 사용합니다. SHA-256 파일은 `해시  ZIP파일명` 형식입니다.
배포 객체 갱신이 공용 목록에 공개해도 된다는 신호입니다. 개발 브랜치나 최신 Release를 임의로 추측하지 않습니다.
개별 `release.json`은 공용 자동화의 입력이며 Dalamud가 요구하는 배열 목록이 아니므로 직접 설치 URL로 사용하지 않습니다. 사용자 설치 URL은 공용 `pluginmaster.json` 하나입니다.

## 자동화와 권한

- `sources.json`: 허용된 플러그인 이름, 소스 저장소, 브랜치, 배포 객체 경로.
- `scripts/sync.ps1`: PowerShell 7.4 이상과 .NET 기본 라이브러리만 사용. 플러그인 DLL을 로드·실행하지 않습니다.
- `.github/workflows/sync.yml`: 30분 간격의 예약 실행, 수동 실행, 자동화 구성 변경 시 실행.
- `pluginmaster.json`: Dalamud가 읽는 공용 설치 목록. 원본 항목의 모든 필드를 유지합니다.
- `sources.lock.json`: 확인한 원본 커밋·매니페스트 해시·Release 주소·ZIP 해시와 크기·아이콘 해시.
- `.github/sync-heartbeat.json`: UTC 월별 성공 기록. 새 Release가 없는 기간에도 월 1회 커밋을 남겨 장기 비활성화를 예방합니다.

Actions는 이 저장소의 `contents: write` 권한을 가진 내장 `GITHUB_TOKEN`으로 생성 파일만 커밋합니다.
별도 PAT·Secrets나 다른 저장소의 쓰기 권한은 필요하지 않습니다. 플러그인 저장소 파일도 수정하지 않습니다.
동시에 시작한 실행은 순서대로 처리하며, 커밋·푸시에 실패하면 실행이 실패로 표시됩니다.

## 검증 범위

두 플러그인을 모두 확인한 후에만 생성 파일을 씁니다. 다음 중 하나라도 실패하면 Actions는 게시하지 않고 기존 공용 목록을 유지합니다.

- 원본 배포 객체의 마지막 변경 커밋을 조회하고 해당 커밋의 고정 raw 주소에서 객체를 읽습니다.
- 플러그인 식별자 중복, 저장소 주소, 네 자리 버전, API 값, 필수 표시 정보를 확인합니다.
- 설치·업데이트 주소가 해당 저장소의 버전 태그에 속하는지 확인합니다.
- 해당 태그의 공개된 정식 Release와 ZIP·SHA-256 자산을 확인합니다. 초안·사전 공개·테스트 채널은 게시하지 않습니다.
- 인증 없는 공개 주소에서 실제 ZIP을 내려받아 크기·SHA-256 파일·GitHub 제공 digest(있는 경우)를 대조합니다.
- ZIP 루트의 플러그인 JSON과 DLL이 존재하고, 중복 경로가 없는지 확인합니다.
- ZIP JSON의 이름·버전·API·로딩 설정과 원본 목록이 일치하는지 확인합니다.
- DLL 메타데이터의 AssemblyName·버전을 확인합니다. 코드는 실행하지 않습니다.
- 버전 태그에 고정된 아이콘 주소에서 PNG 헤더를 확인합니다.

이는 배포 목록과 패키지의 정적 검증입니다. 플러그인 빌드, 게임 호환성 가드, 내장 자료 검사, 실제 Dalamud 설치와 인게임 동작 확인은 각 플러그인의 검증 절차를 따릅니다.

## 수동 실행·로컬 확인

[Actions 화면](https://github.com/PlatyDuckbill/DuckbillRepo/actions/workflows/sync.yml)에서 **Run workflow**를 누르면 됩니다.
로컬에서는 저장소 루트에서 다음 명령을 사용합니다.

```powershell
# 공개 원본과 ZIP을 검증하고 생성 파일 갱신. 자동 커밋·푸시는 하지 않음.
pwsh -NoLogo -NoProfile -File scripts/sync.ps1

# 같은 검증 후 현재 생성 파일과 정확히 일치하는지 확인. 파일 변경 없음.
pwsh -NoLogo -NoProfile -File scripts/sync.ps1 -Check
```

인증 없이 실행할 수 있습니다. GitHub API 호출 한도에 걸릴 경우 잠시 후 다시 실행하거나 Actions에서 실행하세요.
Actions에서는 내장 토큰을 API 호출에 사용하며 공개 ZIP·raw 파일 요청에는 토큰을 보내지 않습니다.

## 실패·유지보수

- Actions의 실패한 실행에서 오류를 확인하고 해당 플러그인의 Release 또는 개별 배포 객체를 수정한 뒤 다시 실행합니다.
- ZIP 업로드와 목록 갱신 사이의 일시적인 실패도 다음 정상 실행에서 재시도됩니다.
- 기존 공용 목록의 다른 플러그인을 임의로 제거하거나 실패한 항목을 0·빈 값으로 대체하지 않습니다.
- 브랜치 보호·Ruleset이 봇의 직접 푸시를 차단하면 공용 목록도 갱신되지 않습니다. 이 저장소의 생성 파일 갱신을 허용하는 정책이 필요합니다.
- GitHub는 예약 실행을 지연·누락할 수 있고, 공개 저장소 활동이 60일 없으면 예약 실행을 중지할 수 있습니다. 월별 성공 기록이 이를 예방하지만 장기간 실패했다면 Actions에서 워크플로를 다시 활성화하고 수동 실행하세요.
- 새 플러그인 추가나 소스 주소 변경은 `sources.json`을 검토해 수정합니다. 패키지 명명 규칙·테스트 채널을 바꾸려면 검증 스크립트도 함께 수정해야 합니다.
- 잘못된 버전을 내릴 때는 원본 배포 객체를 검증된 이전 Release 정보로 되돌린 뒤 동기화합니다. 공용 목록을 되돌려도 사용자의 이미 설치된 상위 버전을 자동으로 강등하지는 않습니다.

## 기존 설치 URL 종료

Tweak와 Fisher의 `main/repo/pluginmaster.json`은 공용 자동화가 새 `repo/release.json`을 검증한 뒤 삭제합니다.
기존 URL은 raw 캐시 만료 후 HTTP 404를 반환합니다. 사용자는 Dalamud 저장소 설정에서 기존 행을 제거하고 공용 URL을 등록해야 합니다.
설치된 DLL·설정 파일은 이 파일 삭제로 변경하지 않습니다. 과거 커밋·버전 태그의 파일과 기존 Release ZIP은 보존하며 이력을 재작성하지 않습니다.

## 참고 자료

- [GitHub Actions 실행 조건](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#schedule): 예약 실행, 지연, 공개 저장소 비활성화 조건.
- [GITHUB_TOKEN 권한](https://docs.github.com/en/actions/tutorials/authenticate-with-github_token): 기본 토큰과 최소 쓰기 권한.
- [외부 자료·고정 revision 기록](SOURCES.md).
