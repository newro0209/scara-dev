/*
 * pulleys.scad - GT2 타이밍 풀리(timing pulley) 기성품(vitamin)
 *
 * SCARA 표준 벨트 구동(standard belt drive)의 모터 20T : 허브축 60T 풀리.
 * GT2 6mm 벨트용. SCARA_KINEMATICS.md(PULLEY_20T·PULLEY_60T)·docs/BOM.md를
 * 따른다. 피치(pitch) 2mm.
 *
 * Z 브레이크포인트(Z breakpoint) 최적화: 풀리는 회전 대칭이고 중앙 보어
 * (bore)도 일정 반경이라, 허브·하부 플랜지·치형부·상부 플랜지·보어 벽을
 * 하나의 환형(annular) [r, z] 단면으로 묶어 단일 rotate_extrude로 만든다.
 * union·difference 없이 솔리드 하나로 끝낸다.
 *
 * 좌표계: 축(axis) = Z, 풀리 바닥 = z=0. 허브가 아래, 치형부가 위.
 */

include <../config.scad>

/* --- GT2 형상(spec) --- */
gt2_pitch	= 2;	/* 벨트 피치(belt pitch) */
gt2_tooth_off	= 0.508;/* GT2 PD→OD 보정(피치원 대비 외경 감소) */
flange_t	= 1;	/* 플랜지(flange) 두께 */
flange_ext	= 1.5;	/* 플랜지가 치형 외경(OD)보다 튀어나오는 양 */
belt_w		= 7;	/* 치형부(toothed) 폭 — GT2 6mm 벨트 */

/* --- 색상(cosmetic) --- */
c_pulley	= [0.71, 0.72, 0.74];	/* 알루미늄 풀리 */
c_set		= [0.15, 0.15, 0.16];	/* 세트 스크루(set screw) 머리 */

/* GT2 치형 외경(outer diameter) — 치수 T 로부터 산출. */
function gt2_od(teeth) = teeth * gt2_pitch / PI - gt2_tooth_off;

/*
 * GT2 풀리 — 치수(teeth), 보어(bore_d), 허브(hub_d·hub_h)를 받는다.
 * 환형 단면 한 개를 rotate_extrude로 돌려 솔리드를 만든다.
 */
module gt2_pulley(teeth, bore_d, hub_d, hub_h)
{
	tor = gt2_od(teeth) / 2;	/* 치형 외경 반지름 */
	br  = bore_d / 2;		/* 보어 반지름 */
	hr  = hub_d / 2;		/* 허브 반지름 */
	fr  = tor + flange_ext;		/* 플랜지 반지름 */

	z1 = hub_h;			/* 허브 top = 하부 플랜지 바닥 */
	z2 = z1 + flange_t;		/* 하부 플랜지 top = 치형 바닥 */
	z3 = z2 + belt_w;		/* 치형 top = 상부 플랜지 바닥 */
	z4 = z3 + flange_t;		/* 상부 플랜지 top = 전체 높이 */

	/* 환형 단면: 외곽 실루엣(아래→위) 후 보어 벽(위→아래)으로 폐합 */
	color(c_pulley)
		rotate_extrude(convexity = 4)
			polygon([[hr, 0],  [hr, z1],
				 [fr, z1],  [fr, z2],
				 [tor, z2], [tor, z3],
				 [fr, z3],  [fr, z4],
				 [br, z4],  [br, 0]]);

	/* 세트 스크루 머리 — 허브 옆면에 배치(boolean 없음) */
	color(c_set)
		translate([hr - 1 - eps, 0, hub_h / 2])
			rotate([0, 90, 0])
				cylinder(h = 2 + eps, d = 2.6);
}

/* --- 표준 변형(convenience) — 표준 벨트 구동 --- */
module gt2_20t() { gt2_pulley(20, 5, 9.6, 6); }	/* 모터축(drive) */
module gt2_60t() { gt2_pulley(60, 8, 18, 7); }	/* 허브축(driven) */

translate([-26, 0, 0]) gt2_60t();
translate([14, 0, 0])  gt2_20t();
