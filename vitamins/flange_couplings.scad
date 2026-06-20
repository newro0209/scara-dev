/*
 * flange_couplings.scad - 플랜지 커플링(flange coupling) 기성품(vitamin)
 *
 * 매끈 봉(round shaft)을 중앙 허브(hub)의 멈춤나사(grub screw)로 죄고, 볼트원
 * (bolt circle)이 있는 원형 플랜지를 판에 평면 체결해 봉을 판에 수직으로
 * 고정한다. SCARA_KINEMATICS.md의 COLUMN_LINK에서 가이드 로드(guide rod) 끝을
 * 가이드 플레이트에 고정(FLANGE_COUPLINGS)한다. NopSCADlib에 없어 로컬로 둔다.
 *
 * Z 브레이크포인트(Z breakpoint) 최적화: 회전 대칭인 플랜지+허브+보어를 환형
 * (annular) 단면 한 개의 rotate_extrude로 만든다. 볼트 홀·멈춤나사는
 * difference 없이 어두운 마커(marker)로 배치한다.
 *
 * 좌표계: 봉 축(axis) = Z, 플랜지 바닥(판 접촉면) = z=0, 허브는 +z.
 */

include <../config.scad>

/* --- 색상(cosmetic) --- */
c_body		= [0.74, 0.75, 0.77];	/* 아연도금강(zinc steel) 본체 */
c_hole		= [0.12, 0.12, 0.13];	/* 볼트 홀·멈춤나사 음각 마커 */

/*
 * 플랜지 커플링(제네릭) — 보어·플랜지·볼트원·허브 치수를 받는다. 회전체는
 * 환형 단면 단일 rotate_extrude, 볼트 홀·멈춤나사 마커는 그대로 배치한다.
 *   bore_d        봉 보어(shaft bore) 지름
 *   flange_d/t    플랜지 외경·두께
 *   bolt_circle_d 마운팅 볼트원(bolt circle) 지름
 *   bolt_n        마운팅 홀 개수
 *   hub_d/h       클램프 허브 외경·높이(플랜지 위)
 */
module flange_coupling(bore_d, flange_d, flange_t, bolt_circle_d, bolt_n,
		       hub_d, hub_h)
{
	br	= bore_d / 2;
	top	= flange_t + hub_h;
	bolt_mark_d = 4.3;	/* 마운팅 홀 마커 — M4 클리어런스 */
	grub_mark_d = 3;	/* 멈춤나사 마커 — M4 grub */

	/* 플랜지 + 허브 + 보어 — 환형 단면 단일 회전체 */
	color(c_body)
		rotate_extrude(convexity = 4)
			polygon([[br, 0], [flange_d / 2, 0],
				 [flange_d / 2, flange_t],
				 [hub_d / 2, flange_t],
				 [hub_d / 2, top], [br, top]]);

	/* 마운팅 볼트 홀 마커 ×n — 플랜지 윗면 볼트원에 배치 */
	color(c_hole)
		for (i = [0 : bolt_n - 1])
			rotate([0, 0, i * 360 / bolt_n])
				translate([bolt_circle_d / 2, 0, flange_t - eps])
					cylinder(h = 0.2 + eps, d = bolt_mark_d);

	/* 멈춤나사 마커 — 허브 옆면에서 봉을 반경으로 죄는 자리 */
	color(c_hole)
		translate([hub_d / 2 - 1, 0, flange_t + hub_h / 2])
			rotate([0, 90, 0])
				cylinder(h = 1 + eps, d = grub_mark_d);
}

/* --- 표준 변형(convenience) — FC8(보어 8, 가이드 로드 끝 고정) --- */
module fc8() { flange_coupling(8, 32, 5, 26, 4, 16, 8); }

fc8();
