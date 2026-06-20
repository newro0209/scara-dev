/*
 * lead_nuts.scad - 플랜지 리드넛(flanged lead nut) 기성품(vitamin)
 *
 * T8 리드스크루(lead screw)의 회전을 직선 이송(linear feed)으로 바꾸는
 * 황동(brass) 플랜지 리드넛 시각화용 모델(보어 T8 / 몸체 ⌀10.2 /
 * 플랜지 ⌀22 x 3.5 / 총높이 15).
 *
 * Z 브레이크포인트(Z breakpoint) 최적화: 리드넛은 회전 대칭(rotationally
 * symmetric)이라 플랜지(flange)·몸체(body)·보어(bore)를 동시에 그리는
 * 환형(annular) 단면 한 개의 단일 rotate_extrude로 만든다 — union·
 * difference 없음. (플랜지 볼트홀(bolt hole)은 단일 회전체 유지를 위해
 * 생략한다.)
 *
 * 좌표계: 축(axis) = Z, 플랜지 바닥(flange base) = z=0.
 */

include <../config.scad>

/* --- 색상(cosmetic) --- */
c_brass		= [0.78, 0.62, 0.32];	/* 황동(brass) */

/*
 * 플랜지 리드넛 — bore_d(보어) x body_d(몸체) x flange_d(플랜지) x
 * flange_t(플랜지 두께) x height(총 높이). 플랜지 바닥(z=0)에서 시작해
 * 플랜지 외경으로 두께만큼 올린 뒤 몸체 외경으로 좁혀 끝까지 세운다.
 * 보어(bore)는 환형 단면의 안쪽 모서리로 한 번에 표현한다.
 */
module lead_nut(bore_d, body_d, flange_d, flange_t, height)
{
	br = bore_d / 2;	/* 보어 반지름 — T8 리드스크루 통과 */
	yr = body_d / 2;	/* 몸체(body) 반지름 */
	fr = flange_d / 2;	/* 플랜지(flange) 반지름 — 마운팅 면 */

	/* 환형 단면 단일 회전체 — 플랜지·몸체·보어 동시 표현 */
	color(c_brass)
		rotate_extrude(convexity = 4)
			polygon([[br, 0],		/* 보어 바닥 */
				 [fr, 0],		/* 플랜지 바깥 바닥 */
				 [fr, flange_t],	/* 플랜지 어깨(shoulder) */
				 [yr, flange_t],	/* 몸체로 좁힘 */
				 [yr, height],		/* 몸체 끝 외경 */
				 [br, height]]);	/* 보어 상단 */
}

/* --- 표준 변형(convenience) --- */
module t8_lead_nut() { lead_nut(8, 10.2, 22, 3.5, 15); }	/* T8 황동 */

t8_lead_nut();
