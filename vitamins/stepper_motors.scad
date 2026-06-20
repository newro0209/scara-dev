/*
 * stepper_motors.scad - NEMA17 스테퍼 모터(stepper motor) 기성품(vitamin)
 *
 * Sanyo Denki SANMOTION F2 (SF2422/2423/2424) 시각화용 모델.
 * 제네릭 stepper_motor()는 프레임·보스·샤프트·마운팅 치수를 인자로 받아
 * 어떤 NEMA 규격(NEMA11·17·23 등)이든 만든다. NEMA 규격별 래퍼(nema17 등)가
 * 그 규격의 리터럴을 채우고, SF 모델 변형은 본체 길이만 넘긴다.
 * 실측은 docs/BOM.md를 따른다.
 *
 * Z 브레이크포인트(Z breakpoint) 최적화: 회전체(파일럿 보스 + 출력축)는
 * [r, z] 브레이크포인트 프로파일 한 개를 rotate_extrude로 한 번에 돌려
 * 단일 솔리드로 만든다. 사각 몸체는 Z 구간(rear bell / 적층 스택 / front
 * bell) 3개의 옥타곤(octagon) 압출로 쌓아 CSG 연산을 최소화한다.
 *
 * 좌표계: 마운팅 면(mounting face) = z=0, 몸체는 -z, 출력축은 +z로 돌출.
 */

include <../config.scad>

/*
 * 스테퍼 외형 2D(제네릭) — 정사각 프레임을 외접원(circumscribed circle)으로
 * 깎은 단면. 모서리는 직선 모따기가 아니라 대각 원호(corner arc)다 — 실제
 * NEMA 프레임 그대로. 시트(seat)·리세스(recess)·카운터보어(counterbore) 등
 * 모터를 받는 형상이 공유한다.
 *   w         프레임 한 변(frame width)
 *   corner_r  모서리 원호 반지름(corner arc radius) — 대각 치수/2
 */
module stepper_outline_2d(w, corner_r)
	intersection() {
		square([w, w], center = true);
		circle(r = corner_r, $fn = 128);	/* 코너 원호 매끈하게(전역 $fn 무시) */
	}

/*
 * 마운팅 홀 중심(제네릭) — 정사각 피치(square pitch) 패턴의 네 모서리 [x, y]
 * 좌표를 반환한다. 시트(seat)·리세스(recess)·체결 홀(fastening hole) 배치가
 * 같은 좌표 규칙을 공유한다.
 *   hole_pitch  마운팅 홀 피치(중심 간 거리)
 */
function stepper_hole_centers(hole_pitch) =
	[for (x = [-1, 1], y = [-1, 1]) [x * hole_pitch / 2, y * hole_pitch / 2]];

/* --- 색상(cosmetic) --- */
c_bell		= [0.78, 0.79, 0.81];	/* 알루미늄 엔드 벨 */
c_stack		= [0.24, 0.24, 0.27];	/* 적층 스택(steel) */
c_shaft		= [0.82, 0.82, 0.85];	/* 출력축·보스 */
c_bolt		= [0.15, 0.15, 0.16];	/* 타이로드 볼트 머리 */

/*
 * 스테퍼 모터(제네릭) — NEMA 규격 치수를 인자로 받아 어떤 프레임이든
 * 만든다. 빌드 헬퍼는 모두 중첩 모듈(nested module)로 두고, 만든 피처를
 * 그대로 배치한다(difference·union 없음).
 *   frame_w  프레임 한 변   corner_r    모서리 원호 반지름     bell_h 엔드 벨 높이
 *   boss_d/h 파일럿 보스    shaft_d/l   출력축 지름·길이      dcut_l D컷 길이
 *   hole_pitch/d 마운팅 홀  body_l      본체 길이
 */
module stepper_motor(frame_w, corner_r, bell_h, boss_d, boss_h,
		     shaft_d, shaft_l, dcut_l, hole_pitch, hole_d, body_l)
{
	/* 외형 비율(cosmetic) — NEMA 규격과 무관 */
	stack_inset	= 0.6;	/* 적층 스택(lamination stack) 인셋 */
	dcut_t		= 0.5;	/* D컷 평면 절삭량 */
	seg		= 24;	/* D 단면 분할 수 */

	/* 파생(derived) */
	r	= shaft_d / 2;			/* 축 반지름 */
	flat	= r - dcut_t;			/* D컷 평면까지 거리 */
	z_dcut	= boss_h + shaft_l - dcut_l;	/* round→D컷 경계 */
	tf	= acos(flat / r);		/* 평면 현(chord) 반각 */
	astep	= (360 - 2 * tf) / seg;

	/* Z 브레이크포인트 회전체 — [r, z] 윤곽선을 축으로 폐합해 단일 회전 */
	module revolve(points)
		rotate_extrude(convexity = 4)
			polygon(concat(points,
					[[0, points[len(points) - 1][1]],
					 [0, points[0][1]]]));

	/* 사각 몸체 — rear bell / 적층 스택 / front bell Z 구간 적층 */
	module body()
	{
		color(c_bell)
			translate([0, 0, -body_l])
				linear_extrude(bell_h + eps)	/* +eps: 적층 스택과 경계 겹침 */
					stepper_outline_2d(frame_w, corner_r);
		color(c_stack)
			translate([0, 0, -body_l + bell_h])
				linear_extrude(body_l - 2 * bell_h + eps)	/* +eps: front bell과 경계 겹침 */
					stepper_outline_2d(frame_w - 2 * stack_inset,
						corner_r);
		color(c_bell)
			translate([0, 0, -bell_h])
				linear_extrude(bell_h)
					stepper_outline_2d(frame_w, corner_r);
	}

	/* 파일럿 보스 + 출력축 — 단일 회전체 + D 단면 압출 */
	module shaft()
	{
		color(c_shaft)
			revolve([[boss_d / 2, 0], [boss_d / 2, boss_h],
				 [r, boss_h], [r, z_dcut]]);
		color(c_shaft)
			translate([0, 0, z_dcut])
				linear_extrude(dcut_l)
					polygon([for (i = [0 : seg])
						let (a = tf + i * astep)
							[r * cos(a), r * sin(a)]]);
	}

	/* 마운팅 홀 마커 + 뒤판 베어링 보스 + 타이로드 볼트 머리 */
	module detail()
	{
		color(c_bolt)
			for (c = stepper_hole_centers(hole_pitch))
				translate([c[0], c[1], -eps])		/* -eps: 마운팅 면(z=0)에 파묻음 */
					cylinder(h = 0.2 + eps, d = hole_d);
		color(c_shaft)
			translate([0, 0, -body_l - 1])
				cylinder(h = 1.5, d = 12);
		color(c_bolt)
			for (c = stepper_hole_centers(hole_pitch))
				translate([c[0], c[1], -body_l - 0.6])
					cylinder(h = 0.8, d = 4);
	}

	body();
	shaft();
	detail();
}

/* --- NEMA17 프레임 래퍼 — □42.3, 대각 53.6, 보스 ⌀22, 축 ⌀5, 마운팅 31 피치 --- */
module nema17(body_l)
	stepper_motor(42.3, 53.6 / 2, 8, 22, 2, 5, 24, 15, 31, 3.2, body_l);

/* NEMA17 외형 2D — 시트·리세스용(□42.3, 대각 53.6) */
module nema17_outline_2d()
	stepper_outline_2d(42.3, 53.6 / 2);

/* NEMA17 마운팅 홀 중심 — 시트·체결 홀 배치용(31 피치) */
function nema17_hole_centers() = stepper_hole_centers(31);

/* --- SF24 모델 변형 — 본체 길이만 다름(docs/BOM.md) --- */
module stepper_sf2422() { nema17(39); }		/* J4 WRIST */
module stepper_sf2423() { nema17(48); }		/* J3 ELBOW */
module stepper_sf2424() { nema17(59.5); }	/* J2 SHOULDER / J1 */

stepper_sf2424();
