/*
 * linear_bearings.scad - 리니어 볼 베어링(linear ball bearing) 기성품(vitamin)
 *
 * 리니어 샤프트(linear shaft)를 따라 직선 안내(linear guide)하는 LM8UU
 * 볼 부싱(ball bushing) 시각화용 모델(보어 8 x OD 15 x 길이 24).
 *
 * Z 브레이크포인트(Z breakpoint) 최적화: 강철 셸(steel shell)은 회전 대칭
 * (rotationally symmetric)이라 외곽(outer)과 보어(bore)를 동시에 그리는
 * 환형(annular) 단면 한 개의 단일 rotate_extrude로 만든다 — union·
 * difference 없음. 양 끝 씰(seal) 링만 색상이 갈리므로 별도 rotate_extrude
 * 두 개로 그린다.
 *
 * 좌표계: 축(axis) = Z, 길이(length)는 z=0..length.
 */

include <../config.scad>

/* --- 형상 비율(cosmetic) --- */
seal_t		= 1.2;	/* 씰(seal) 링 축방향(axial) 두께 */
seal_inset	= 1.0;	/* 씰 보어 반경 인셋(inset) — 셸보다 안쪽으로 돌출 */

/* --- 색상(cosmetic) --- */
c_shell		= [0.55, 0.56, 0.59];	/* 강철 셸(steel shell) */
c_seal		= [0.12, 0.12, 0.13];	/* 양 끝 씰(seal) — 고무(rubber) */

/*
 * 리니어 볼 베어링 — bore_d(보어) x od(외경) x length(길이). 강철 셸은
 * 외경과 보어 사이의 환형(annular) 단면을 단일 rotate_extrude로 돌려
 * 만들고, 양 끝에 고무 씰(seal) 링을 보어 안쪽으로 인셋(inset)해 끼운다.
 */
module linear_bearing(bore_d, od, length)
{
	br = bore_d / 2;	/* 보어 반지름 */
	or = od / 2;		/* 외경 반지름 */
	sr = br - seal_inset;	/* 씰(seal) 내경 반지름 — 샤프트 접촉(contact) */

	/* 강철 셸(steel shell) — 외곽·보어 동시(환형 단면 단일 회전체) */
	color(c_shell)
		rotate_extrude(convexity = 4)
			polygon([[br, 0], [or, 0],
				 [or, length], [br, length]]);

	/*
	 * 씰(seal) 링 — 양 끝에서 보어 안쪽으로 돌출해 샤프트를 닦고
	 * 그리스(grease)를 가둔다. 색상이 셸과 갈려 별도 회전체로 둔다.
	 */
	module seal_ring(z0, z1)
		rotate_extrude(convexity = 2)
			polygon([[sr, z0], [br + eps, z0],
				 [br + eps, z1], [sr, z1]]);

	color(c_seal) {
		seal_ring(0, seal_t);			/* 하단 씰 */
		seal_ring(length - seal_t, length);	/* 상단 씰 */
	}
}

/* --- 표준 변형(convenience) --- */
module lm8uu() { linear_bearing(8, 15, 24); }	/* ⌀8 샤프트 리니어 가이드 */

lm8uu();
