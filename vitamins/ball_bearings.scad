/*
 * ball_bearings.scad - 볼 베어링(ball bearing) 기성품(vitamin)
 *
 * SCARA 회전 관절축(revolute axis)과 WAIST 저널에 공통으로 쓰는 608ZZ
 * 베어링(8 x 22 x 7) 시각화용 모델. SCARA_KINEMATICS.md의 AXIS_BEARINGS·
 * WAIST_BEARINGS, docs/BOM.md를 따른다.
 *
 * Z 브레이크포인트(Z breakpoint) 최적화: 베어링은 회전 대칭(rotationally
 * symmetric)이라 내륜(inner race)·외륜(outer race)·실드(shield)를 각각
 * 사각 단면 한 개의 rotate_extrude 링으로만 만든다. 원기둥 union·difference
 * 없이 색상별 솔리드 3개로 끝낸다.
 *
 * 좌표계: 축(axis) = Z, 베어링 중심 = 원점. 폭(width)은 z=0..w.
 */

include <../config.scad>

/* --- 형상 비율(cosmetic) --- */
race_t		= 2.4;	/* 내·외륜(race) 반경 두께(radial thickness) */
shield_inset	= 0.6;	/* 실드(shield) 축방향 인셋(inset) */

/* --- 색상(cosmetic) --- */
c_race		= [0.52, 0.53, 0.56];	/* 내·외륜 — 크롬강(chrome steel) */
c_shield	= [0.70, 0.71, 0.74];	/* 실드(ZZ) 금속 커버 */

/*
 * 볼 베어링 — bore_d(내경) x od(외경) x w(폭). 내륜·외륜은 전폭(full
 * width), 실드는 그 사이를 인셋(inset)해 끼운다. 각 링은 사각 단면
 * 하나의 단일 rotate_extrude(중첩 모듈 bearing_ring)로 만든다.
 */
module ball_bearing(bore_d, od, w)
{
	ir = bore_d / 2;	/* 내경 반지름 */
	or = od / 2;		/* 외경 반지름 */

	/* Z 브레이크포인트 사각 링 — 반경 r0..r1, 높이 z0..z1 단일 회전체 */
	module bearing_ring(r0, r1, z0, z1)
		rotate_extrude(convexity = 2)
			polygon([[r0, z0], [r1, z0], [r1, z1], [r0, z1]]);

	color(c_race) {
		/* 내륜(inner race) — 전폭 */
		bearing_ring(ir, ir + race_t, 0, w);
		/* 외륜(outer race) — 전폭 */
		bearing_ring(or - race_t, or, 0, w);
	}

	/* 실드(shield) — 내·외륜 사이, 양면 인셋 */
	color(c_shield)
		bearing_ring(ir + race_t, or - race_t,
			     shield_inset, w - shield_inset);
}

/* --- 표준 변형(convenience) --- */
module bearing_608() { ball_bearing(8, 22, 7); }	/* 회전축·WAIST */

bearing_608();
