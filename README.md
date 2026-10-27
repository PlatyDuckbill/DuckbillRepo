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

기존 개별 저장소 URL 대신 이 공용 URL을 사용하면 됩니다. 기존 URL은 각 저장소에서 계속 제공하지만,
동일한 플러그인이 여러 저장소에서 중복 제공되지 않도록 공용 URL로 전환한 후 기존 개별 URL은 목록에서 제거하는 것을 권장합니다.
플러그인 자체를 삭제하거나 설정을 초기화할 필요는 없습니다.

## 업데이트가 반영되는 방식

1. 각 플러그인 저장소에서 검증한 Release ZIP과 SHA-256 파일을 공개합니다.
2. 해당 저장소의 `repo/pluginmaster.json`을 새 버전으로 갱신합니다.
3. 이 저장소의 Actions가 매시 **17분·47분(UTC)**에 두 공개 목록을 확인합니다.
4. 모든 검증을 통과한 경우에만 `pluginmaster.json`과 출처 기록을 함께 커밋합니다.

평소 배포 때 이 저장소를 직접 수정할 필요는 없습니다. **Release ZIP만 올리고 개별 설치 목록을 갱신하지 않으면 공용 목록도 바뀌지 않습니다.**
GitHub 예약 실행과 raw 파일 캐시 때문에 반영이 지연될 수 있습니다. 즉시 갱신하려면
[Actions → Sync plugin repository → Run workflow](https://github.com/PlatyDuckbill/DuckbillRepo/actions/workflows/sync.yml)를 실행합니다.
이 저장소는 빌드·태그 생성·Release 공개를 대신하지 않습니다.

세부 검증과 장애 대응은 [운영 안내](docs/OPERATIONS.md)를 참고하세요.
