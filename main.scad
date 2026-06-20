/*
 * main.scad - SCARA 로봇 전체 조립체(assembly)
 *
 * SCARA_KINEMATICS.md의 기구 체인(kinematic chain)을 따라 링크 모듈을
 * 베이스(base)부터 말단(tool)까지 적층한다. 각 링크 파츠는 parts/ 하위에
 * 분리해 두고, 이 파일은 배치(placement)와 조립만 담당한다.
 *
 * 좌표계: WAIST_AXIS = Z축, 베이스 원점. 캐리지 이동은 +Z 방향.
 *
 * 축별 구동 모터 추천 (Sanyo Denki SANMOTION F2, 바이폴라, 1.2 A/phase).
 * 상세 스펙·단가는 docs/BOM.md 참조.
 *
 *	축		관절		타입		추천 모터		홀딩 토크
 *	J0	WAIST		revolute	(없음 — 현재 고정)	-
 *	J1	VERTICAL	prismatic	SF2424-12B41		0.8 N·m
 *	J2	SHOULDER	revolute	SF2424-12B41		0.8 N·m
 *	J3	ELBOW		revolute	SF2423-12B41		0.56 N·m
 *	J4	WRIST		revolute	SF2422-12B41		0.43 N·m
 *
 * 선정 근거: 회전축은 떠받치는 하류(downstream) 관성이 클수록 큰 토크가
 * 필요하다 — 어깨(J2) > 팔꿈치(J3) > 손목(J4). J1(수직 승강)은 리드스크루
 * 감속으로 모터 토크 여유는 크나, 전체 암 중력 부하를 직접 들어올리므로
 * 최대 토크(SF2424)를 둔다. J0(WAIST)는 현재 임시 고정이라 구동기가 없다.
 */

include <config.scad>
use <parts/column_link.scad>

/* --- 로봇 조립체(robot assembly) --- */
module scara_robot()
{
	/* J0 WAIST — 현재 고정. BASE_LINK는 별도 미구현. */
	column_link();

	/* TODO: J1 위치에 carriage_link() 배치 */
	/* TODO: J2 위치에 upper_arm_link() 배치 */
	/* TODO: J3 위치에 forearm_link() 배치 */
	/* TODO: J4 위치에 tool_link() 배치 */
}

scara_robot();
