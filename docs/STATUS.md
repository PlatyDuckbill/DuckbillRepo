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
- 이번 요청: 두 플러그인 README의 공용 URL 전환과 개별 `main/repo/pluginmaster.json` 삭제를 진행 중이다. 새 원본에 대한 Actions 검증 후 삭제한다.
