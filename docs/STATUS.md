# 현재 상태

갱신: 2026-10-27

- 목적: DuckbillTweak와 DuckbillFisher를 URL 하나로 제공하는 공용 설치 목록.
- 원본 소스·Release는 각 플러그인 저장소에서 계속 관리한다. 자동화 입력을 단일 객체 `repo/release.json`으로 전환하고 기존 개별 설치 URL은 종료한다.
- 초기 수집: DuckbillTweak 0.2.0.0, DuckbillFisher 0.6.0.0.
- 공개 ZIP의 크기·SHA-256, ZIP JSON과 DLL 식별자·버전, 아이콘 PNG 정적 검증을 로컬에서 통과했다.
- 자동화: 30분 간격·수동 실행, 검증 성공 시에만 공용 목록 갱신, 월별 성공 기록.
- 공용 설치 URL을 게시했고 인증 없는 HTTP 200 응답과 두 플러그인 항목을 확인했다.
- [첫 GitHub Actions 실행](https://github.com/PlatyDuckbill/DuckbillRepo/actions/runs/40517146026)은 성공했다. Linux 서버에서 패키지 검증과 봇 커밋·푸시를 확인했다.
- 초기 구성 커밋 `26bd10c`, 첫 자동 커밋 `f50e4f2`. 로컬 저장소는 `C:\Users\hyogu\Downloads\DuckbillRepo`에 있다.
- 예약 실행은 활성 상태다. 수동 실행도 제공한다. 실제 Dalamud 설치·인게임 확인은 수행하지 않았다.
- 두 플러그인 README를 공용 URL로 변경하고 개별 `main/repo/pluginmaster.json`을 삭제했다. 자동화는 단일 배포 객체 `repo/release.json`을 읽는다. [새 원본 검증 Actions](https://github.com/PlatyDuckbill/DuckbillRepo/actions/runs/40518916863)는 성공했으며 삭제 후 로컬 `-Check`도 통과했다.
- 설치 출처 URL 일치 조건을 확인해 기존 사용자에게 설정·기록을 보존한 1회 플러그인 재설치를 안내한다. 한국 Dalamud에서의 실제 전환·설정 복원 실기는 별도 대기다.
- 변경 커밋: Tweak `9ab158e`/`d9bbb51`, Fisher `be865aa`/`5713f78`, 공용 자동화 `1d20dcd`. 기존 Release ZIP과 플러그인 실행 파일은 변경하지 않았다.
- 2026-10-27 14:19:50 UTC에 Tweak의 실제 기존 raw URL도 HTTP 404로 전환된 것을 확인했다. Fisher 기존 URL은 이미 HTTP 404이며, 공용 URL은 HTTP 200으로 두 항목을 계속 제공한다. 두 README의 원격 최신 내용에서 공용 주소와 전환 절차 링크도 확인했다.
