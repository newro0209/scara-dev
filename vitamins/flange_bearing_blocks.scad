/*
 * flange_bearing_blocks.scad - 플랜지 베어링 블록(flange bearing block) vitamin
 *
 * SCARA_KINEMATICS.md의 FLANGE_BEARING_BLOCKS(리드스크루 양단 지지)·
 * docs/BOM.md를 따른다. 2볼트 다이아몬드(rhombus) 아연합금 플랜지 +
 * 자동조심(self-aligning) 구형 인서트(spherical insert).
 *
 * Z 브레이크포인트(Z breakpoint) 최적화: 인서트(슬리브 + 구형 외륜 + 보어)는
 * 환형(annular) 단면 한 개의 rotate_extrude로 만든다 — union·difference 없음.
 * 플랜지는 세 원(중앙 + 양 귀)의 hull 한 번을 linear_extrude 한다.
 *
 * 좌표계: 보어 축(axis) = Z, 유닛 중심 = 원점. 마운팅 면 = z=0.
 */

include <../config.scad>

/* --- 색상(cosmetic) --- */
c_housing	= [0.74, 0.75, 0.77];	/* 아연합금(zinc) 하우징 */
c_insert	= [0.50, 0.51, 0.54];	/* 인서트 — 크롬강(steel) */
c_screw		= [0.30, 0.30, 0.32];	/* 셋 스크루(set screw) */

/*
 * 플랜지 베어링 블록 — 보어·다이아몬드 플랜지·마운팅 홀·높이를 받는다.
 * 하우징·인서트를 중첩 모듈(nested module)로 나눠 부모의 지역 치수를
 * 공유한 뒤 그대로 배치한다.
 */
module flange_bearing_block(bore_d, flange_l, flange_t, bolt_pitch,
			    bolt_hole_d, housing_d, height)
{
	ex	 = bolt_pitch / 2;		/* 귀(ear) 중심 x */
	ear_r	 = (flange_l - bolt_pitch) / 2;	/* 귀 모서리 반지름 */
	sleeve_d = bore_d + 4;			/* 인너 슬리브(sleeve) 외경 */
	ball_d	 = bore_d + 9;			/* 구형 외륜(race) 최대 외경 */
	seat_d	 = bore_d + 6;			/* 인서트 시트(seat) 보어 */
	ss_d	 = 3;				/* 셋 스크루 — M3 */

	/* 아연 하우징 — 다이아몬드 플랜지 + 마운팅 홀·시트 음각 */
	module housing()
	{
		color(c_housing)
		difference() {
			linear_extrude(flange_t)
				hull() {
					circle(d = housing_d);
					translate([ ex, 0]) circle(r = ear_r);
					translate([-ex, 0]) circle(r = ear_r);
				}

			for (x = [ex, -ex])
				translate([x, 0, -1])
					cylinder(h = flange_t + 2, d = bolt_hole_d);

			translate([0, 0, -1])
				cylinder(h = flange_t + 2, d = seat_d);
		}
	}

	/* 자동조심 인서트 — 환형 단면 단일 회전체 + 셋 스크루 */
	module insert()
	{
		zc = flange_t / 2;	/* 인서트 중심 높이 */
		hz = height / 2;

		color(c_insert)
			rotate_extrude(convexity = 4)
				polygon([[bore_d / 2,    zc - hz],
					 [sleeve_d / 2, zc - hz],
					 [sleeve_d / 2, zc - 2.5],
					 [ball_d / 2,   zc - 1],
					 [ball_d / 2,   zc + 1],
					 [sleeve_d / 2, zc + 2.5],
					 [sleeve_d / 2, zc + hz],
					 [bore_d / 2,    zc + hz]]);

		color(c_screw)
			for (ang = [0, 90])
				rotate([0, 0, ang])
					translate([sleeve_d / 2 - 0.5, 0,
						   zc + hz - 1.5])
						rotate([0, 90, 0])
							cylinder(h = 1.6, d = ss_d);
	}

	housing();
	insert();
}

/* --- 표준 변형(convenience) --- */
/* KFL08 — bore 8, a 48, 두께 4.5, 볼트 피치 37, 홀 ⌀5, 하우징 ⌀26, Z 11.5 */
module kfl08() { flange_bearing_block(8, 48, 4.5, 37, 5, 26, 11.5); }

kfl08();
