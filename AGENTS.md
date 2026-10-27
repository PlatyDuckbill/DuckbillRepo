# DuckbillRepo 작업 지침

- 변경 이유와 결과는 한국어로 설명한다. 시작 시 `git status`와 `docs/STATUS.md`를 확인한다.
- `tmp_note.md`는 읽기·검색·수정·스테이징하지 않는다.
- 이 저장소는 공용 설치 목록만 관리한다. DuckbillTweak/DuckbillFisher 소스와 Release는 변경하지 않는다.
- 플러그인 식별자와 원본 항목 필드를 유지하며 공개된 개별 설치 목록을 진실의 원본으로 사용한다.
- 공개 ZIP과 체크섬·내장 매니페스트·DLL 메타데이터를 검증하기 전에 공용 목록을 게시하지 않는다.
- 하나라도 실패하면 기존 목록을 유지한다. 인증 정보·ZIP·DLL·캐시를 커밋하지 않는다.
- 출처·고정 revision·라이선스·가공 내역을 기록한다. GitHub Actions 의존성은 커밋 SHA로 고정한다.
- 일반 확인은 `pwsh -NoLogo -NoProfile -File scripts/sync.ps1 -Check`와 정적 검토다. 테스트는 사용자가 명시 요청할 때 추가·실행한다.
- 공개 목록 검증, Actions 성공, 실제 Dalamud 설치·인게임 확인을 구분한다.
