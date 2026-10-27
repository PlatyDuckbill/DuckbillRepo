# 출처·외부 의존성

## 플러그인 배포 자료

- DuckbillTweak: https://github.com/PlatyDuckbill/DuckbillTweak
- DuckbillFisher: https://github.com/PlatyDuckbill/DuckbillFisher
- 사용 자료: 각 저장소의 단일 배포 객체 `repo/release.json`, 공개 Release 메타데이터, ZIP·SHA-256·아이콘. 기존 개별 `repo/pluginmaster.json`은 종료합니다.
- 각 동기화에서 확인한 고정 원본 커밋과 해시는 `sources.lock.json`에 기록합니다.
- 가공: 배포 객체 두 개를 JSON 배열 하나로 결합하고 UTF-8/LF로 재직렬화합니다. 개별 항목 필드와 다운로드 주소는 변경하지 않습니다.
- ZIP·DLL·아이콘은 검증 목적으로 메모리에서 읽으며 이 저장소에 복사하거나 재배포하지 않습니다. 플러그인 소스 코드는 도입하지 않습니다.
- 원본 프로젝트의 라이선스·고지는 각 저장소와 배포 패키지를 따릅니다. 이 저장소의 라이선스가 원본 자료의 권리를 대체하지 않습니다.

## 구조 참고

- https://github.com/FFXIV-CombatReborn/CombatRebornRepo
- 확인 revision: `2dd129bf8b8fdbaf0bfd7d7e4df0d05d15a127ab` (2026-10-27).
- 참고 범위: README 설치 안내와 여러 플러그인을 담은 `pluginmaster.json` 구조.
- 코드·설명·이미지·플러그인 항목은 복사하지 않았습니다. 해당 revision의 루트 목록에서 별도 LICENSE 파일은 확인하지 못했습니다.

## 설치 출처 전환 근거

- [goatcorp/Dalamud](https://github.com/goatcorp/Dalamud), 고정 revision `1e514694497ae448fca8e8a46f7b63642ad1e5ad`, AGPL-3.0.
- [PluginManager.cs](https://github.com/goatcorp/Dalamud/blob/1e514694497ae448fca8e8a46f7b63642ad1e5ad/Dalamud/Plugin/Internal/PluginManager.cs#L1760): 설치 출처 기록과 업데이트 후보의 출처 URL 일치 조건을 참고했습니다.
- [PluginInstallerWindow.cs](https://github.com/goatcorp/Dalamud/blob/1e514694497ae448fca8e8a46f7b63642ad1e5ad/Dalamud/Interface/Internal/Windows/PluginInstaller/PluginInstallerWindow.cs#L3840): 플러그인 제거와 별도 설정 삭제 메뉴의 구분을 참고했습니다.
- 코드 복사·도입 없이 README 전환 안내만 보완했습니다. 한국 Dalamud 배포판에서의 실제 이전 결과는 추정하지 않습니다.

## Actions 의존성

- [actions/checkout](https://github.com/actions/checkout): `fbc6f3992d24b796d5a048ff273f7fcc4a7b6c09` (v5), MIT License.
- GitHub Actions에서 해당 revision을 실행하며 원본 코드를 이 저장소에 복사하지 않습니다.
- PowerShell 및 .NET: 실행 환경에서 제공하는 표준 기능을 사용하며 외부 모듈·패키지를 설치하지 않습니다.
