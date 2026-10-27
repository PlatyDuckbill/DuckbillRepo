# DuckbillRepo

[![Sync plugin repository](https://github.com/PlatyDuckbill/DuckbillRepo/actions/workflows/sync.yml/badge.svg)](https://github.com/PlatyDuckbill/DuckbillRepo/actions/workflows/sync.yml)

한국 FFXIV용 **DuckbillTweak**와 **DuckbillFisher**의 공용 Dalamud 설치 목록입니다.
각 플러그인은 별도로 설치·업데이트하며, 소스와 Release ZIP은 각자의 저장소에서 관리합니다.

## 설치

Dalamud 설정 → 실험적 기능 → 커스텀 플러그인 저장소에 아래 주소를 입력하고 **＋**를 누른 뒤 저장합니다.

```text
https://raw.githubusercontent.com/PlatyDuckbill/DuckbillRepo/main/pluginmaster.json
```

플러그인 설치 목록을 새로고침한 뒤 원하는 플러그인을 검색해 설치합니다.
저장소 URL을 추가하는 것만으로 플러그인이 자동 설치되지는 않습니다.

| 플러그인 | 설명 | 소스·릴리스 |
| --- | --- | --- |
| DuckbillTweak | 상점 필터, 필요 재화 계산, 공개된 입찰 결과, PvP 말풍선 | [DuckbillTweak](https://github.com/PlatyDuckbill/DuckbillTweak) |
| DuckbillFisher | 물고기 검색, 출현 일정, 미끼 준비와 낚시 기록 | [DuckbillFisher](https://github.com/PlatyDuckbill/DuckbillFisher) |

기존 Tweak/Fisher의 개별 `main/repo/pluginmaster.json` URL은 종료합니다.
Dalamud에 등록한 기존 개별 URL을 제거하고 위 공용 URL을 추가하세요.
플러그인 자체를 삭제하거나 설정을 초기화할 필요는 없습니다.

## 업데이트가 반영되는 방식

1. 각 플러그인 저장소에서 검증한 Release ZIP과 SHA-256 파일을 공개합니다.
2. 해당 저장소의 `repo/release.json`을 새 버전의 배포 객체로 갱신합니다.
3. 이 저장소의 Actions가 매시 **17분·47분(UTC)**에 두 배포 객체를 확인합니다.
4. 모든 검증을 통과한 경우에만 `pluginmaster.json`과 출처 기록을 함께 커밋합니다.

평소 배포 때 이 저장소를 직접 수정할 필요는 없습니다. **Release ZIP만 올리고 개별 `repo/release.json`을 갱신하지 않으면 공용 목록도 바뀌지 않습니다.**
`release.json`은 자동화 입력인 단일 객체이며 Dalamud에 직접 등록하는 설치 목록이 아닙니다. 기존 개별 `repo/pluginmaster.json` 파일은 다시 만들지 않습니다.
GitHub 예약 실행과 raw 파일 캐시 때문에 반영이 지연될 수 있습니다. 즉시 갱신하려면
[Actions → Sync plugin repository → Run workflow](https://github.com/PlatyDuckbill/DuckbillRepo/actions/workflows/sync.yml)를 실행합니다.
이 저장소는 빌드·태그 생성·Release 공개를 대신하지 않습니다.

세부 검증과 장애 대응은 [운영 안내](docs/OPERATIONS.md)를 참고하세요.
