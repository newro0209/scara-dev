/*
 * column_link.scad - COLUMN_LINK 제작 부품(printed part) + 조립체(assembly)
 *
 * SCARA_KINEMATICS.md의 COLUMN_LINK 정의를 따른다. 가이드 로드(guide rod)
 * 3개를 삼각 배치(triangular layout)한 수직 컬럼(column)으로, 3장의 가이드
 * 플레이트(guide plate)가 로드를 모두 관통한다. 모터는 MOTOR_GUIDE_PLATE에
 * 상향(upward) 설치되어 리드스크루(leadscrew)와 직결되고, 모터 몸체는
 * MOTOR_GUIDE_PLATE↔BOTTOM_GUIDE_PLATE 스탠드오프 공간에 수용된다.
 *
 * column_link()는 제작 플레이트를 항상 그리고, 기성품(hardware)은
 * show_hardware로 시각화를 토글한다(인쇄용 형상만 보려면 false).
 *
 * 좌표계: WAIST_AXIS = Z축, 컬럼 중심. 캐리지 이동 구간은 +Z(TOP) 방향.
 */

include <../config.scad>
include <base_link.scad>
use <../vitamins/flange_couplings.scad>
use <../vitamins/flange_bearing_blocks.scad>
use <../vitamins/guide_rods.scad>
use <../vitamins/leadscrews.scad>
use <../vitamins/lock_nuts.scad>
use <../vitamins/shaft_couplings.scad>
use <../vitamins/screws.scad>
use <../vitamins/standoffs.scad>
use <../vitamins/stepper_motors.scad>
use <../utils/math.scad>
use <../utils/profile.scad>

/* --- 렌더 토글(render toggle) --- */
show_hardware			= true;	/* 기성품(가이드 로드·모터·커플링 등) 시각화 on/off */

/* --- 기성품 사양(vitamin spec) --- */
leadscrew_d			= 8;	/* 리드스크루(leadscrew) 지름 — T8 */
leadscrew_l			= 300;	/* 리드스크루(leadscrew) 전체 길이 */
guide_rod_d			= 8;	/* 가이드 로드(guide rod) 지름 — 8mm */
guide_rod_l			= 300;	/* 가이드 로드(guide rod) 전체 길이 — 컬럼 높이 기준 */
nema17_frame_w			= 42.3;	/* NEMA17 프레임 한 변 */
nema17_body_l			= 59.5;	/* NEMA17 SF2424 몸체 길이(body length) */
nema17_boss_d			= 22;	/* NEMA17 파일럿 보스(pilot boss) 지름 */
nema17_boss_h			= 2;	/* NEMA17 파일럿 보스(pilot boss) 높이 */
nema17_shaft_d			= 5;	/* NEMA17 출력축(output shaft) 지름 */
nema17_bolt_pitch_d		= 31;	/* NEMA17 마운트 볼트 피치 */
nema17_bolt_hole_d		= 3;	/* NEMA17 모터 탭 홀(tapped hole) 지름 */
kfl08_d			= 48;	/* KFL08 플랜지 베어링 블록(flange bearing block) 외경 */
kfl08_bolt_n			= 2;	/* KFL08 마운트 볼트 개수 */
kfl08_bolt_pitch_d		= 37;	/* KFL08 마운트 볼트 피치 */
kfl08_bolt_hole_d		= 5;	/* KFL08 마운트 볼트 홀 지름 */
fc8_d				= 32;	/* FC8 플랜지 커플링(flange coupling) 외경 */
fc8_flange_t			= 5;	/* FC8 플랜지 두께 */
fc8_bolt_pitch_d	= 24;	/* FC8 마운트 볼트 피치 */
fc8_bolt_n			= 4;	/* FC8 마운트 볼트 개수 */
m3_standoff_d			= 6.5;	/* M3 육각 스탠드오프(hex standoff) 외경(맞변) */
m4_insert_d			= 6;	/* M4 heat-set 인서트(insert) 홀 지름 */
m4_insert_l			= 5;	/* M4 인서트 홀 깊이 */
m5_insert_d			= 8;	/* M5 heat-set 인서트(insert) 홀 지름 */
m5_insert_l			= 5;	/* M5 인서트 홀 깊이 */

/* --- 피처 사양(feature spec) --- */
travel_h			= 300;	/* 캐리지 이동 구간(travel) 높이 — TOP↔MOTOR */
guide_rod_n			= 3;	/* 로드 개수 — 삼각 배치(triangular layout) */
guide_rod_start_angle		= 90;	/* 로드 삼각 배치 시작각 — 꼭짓점을 +Y(위)로 세운다 */

/* 모터 마운트 패드(motor mount pad) — NEMA17 대각(diagonal)에 여백을 둔 중앙 원판 */
motor_mount_pad_d		= nema17_frame_w * sqrt(2) + layout_margin;
/* 로드 패드(rod pad) — FC8 플랜지 커플링 외곽에 여백을 둔 로드 지지면 */
guide_rod_pad_d			= fc8_d + layout_margin;
/* 로드 피치 원(rod pitch circle) — 모터 패드와 로드 패드가 외접하도록 배치 */
guide_rod_circle_d		= motor_mount_pad_d + guide_rod_pad_d;

function center_bore_d() = leadscrew_d + print_clearance;	/* 중앙 보어 — 리드스크루 관통(clearance 포함) */
function rod_bore_d()    = guide_rod_d + print_clearance;	/* 로드 보어 — 가이드 로드 관통(clearance 포함) */

/*
 * 플레이트 파생 치수(plate derived dimension) — 각 플레이트 두께는 인서트 깊이에
 * FDM 최소 바닥(seat_shoulder_t)을 더한다. TOP은 M4·M5 인서트 중 깊은 쪽 기준.
 */
function top_guide_plate_t()	= max(m4_insert_l, m5_insert_l) + seat_shoulder_t;
function motor_guide_plate_t()	= m4_insert_l + seat_shoulder_t;
function bottom_guide_plate_t()	= m4_insert_l + seat_shoulder_t;
/* 플레이트 외경 — 로드 피치 원 + 로드 보어·여백(현재 echo 진단에만 사용) */
function plate_d()		= guide_rod_circle_d + layout_margin + guide_rod_d + layout_margin;

echo(str("column_link: plate_t=", top_guide_plate_t(), " plate_d=", plate_d()));

/* 가이드 로드 중심 ×3 — 로드 피치 원(rod pitch circle) 삼각 배치 */
module at_guide_rods()
{
	at_circle(guide_rod_n, guide_rod_circle_d, guide_rod_start_angle)
		children();
}

/* 로드별 FC8 인서트 자리 — 로드마다 FC8 볼트 피치 패턴 */
module at_rod_mount_inserts()
{
	at_guide_rods()
		at_circle(fc8_bolt_n, fc8_bolt_pitch_d)
			children();
}

/* 중앙 KFL08 마운트 인서트 자리 — 베어링 블록 볼트 패턴 */
module at_flange_bearing_block_inserts()
{
	at_circle(kfl08_bolt_n, kfl08_bolt_pitch_d)
		children();
}

/* (= at_rod_mount_inserts와 동일 형상 — 중복, 하나로 통합 권장) */
module at_flange_coupling_inserts()
{
	at_guide_rods()
		at_circle(fc8_bolt_n, fc8_bolt_pitch_d)
			children();
}

/* NEMA17 마운트 홀 중심 4점에 children 배치 */
module at_nema17_hole_centers()
{
	for (c = nema17_hole_centers())
		translate([c[0], c[1], 0])
			children();
}

/*
 * guide_plate_2d_with_cuts — 플레이트 2D 단면(윤곽 outline + 보어 hole)을
 * 만들고, 추가로 뺄 형상 children()을 difference로 빼서 2D로 반환한다.
 * 압출(linear_extrude)은 호출부(각 플레이트 모듈)가 담당한다.
 */
module guide_plate_2d_with_cuts(center_bore_d = center_bore_d(), rod_bore_d = rod_bore_d())
{
	difference() {
		/*
		 * 외곽(outline) — 중앙 원판과 로드별 패드(rod pad)를 합치고, 합류부를
		 * 필렛(fillet)으로 둥글려 응력 집중(stress concentration)을 줄인다.
		 */
		apply_fillet(layout_margin)
		union() {
			/* 중앙 디스크 — 모터 마운트 패드(NEMA17 대각 + 여백) */
			circle(d = motor_mount_pad_d);
			/* 로드 패드 ×3 — 가이드 로드 자리 보강 */
			at_guide_rods()
				circle(d = guide_rod_pad_d);
		}
		
		/* 중앙 보어 홀(center bore hole) — 리드스크루·모터 보스가 지나는 구멍 */
		circle(d = center_bore_d);
		/* 로드 보어 홀(rod bore holes) × guide_rod_n — 가이드 로드(guide rod)가 관통하는 구멍 */
		at_guide_rods()
			circle(d = rod_bore_d);
			
		children();
	}
}


/* --- TOP_GUIDE_PLATE — 캐리지 이동 상한(upper travel limit) --- */
/*
 * 자유단 베어링 장착면(free-end bearing mount) — 리드스크루(leadscrew)를
 * 상단에서 반경방향(radial direction)으로 지지한다.
 */
module top_guide_plate()
{
	plate_t = top_guide_plate_t();

	linear_extrude(height = plate_t)
	guide_plate_2d_with_cuts() {
		at_flange_bearing_block_inserts()
			circle(d = m5_insert_d + print_clearance);

		at_flange_coupling_inserts()
			circle(d = m4_insert_d + print_clearance);
	}

	at_flange_bearing_block_inserts()
		translate([0, 0, plate_t - seat_shoulder_t])
			cylinder(d = m5_insert_d + print_clearance, h = plate_t - m5_insert_l);
		
	at_flange_coupling_inserts()
		translate([0, 0, plate_t - seat_shoulder_t])
			cylinder(d = m4_insert_d + print_clearance, h = plate_t - m4_insert_l);
}

/* --- MOTOR_GUIDE_PLATE — 캐리지 이동 하한(lower travel limit) --- */
/*
 * 모터 장착면(motor mount) / 구동단(drive end) — NEMA17을 상향 체결하고
 * 커플링(coupling)으로 리드스크루(leadscrew)와 축 정렬(alignment)을 맞춘다.
 * 이 판에는 베어링이 없다(자유단 KFL08은 TOP에 위치).
 *
 * 2층 구성: 상부 시트 층(seat layer)은 모터 마운팅 면이 닿는 솔리드 + 인서트·
 * 볼트 홀, 하부 층은 NEMA17 외형(nema17_outline_2d)을 빼 모터 몸체를 수용한다.
 */
module motor_guide_plate()
{
	plate_t = motor_guide_plate_t();

	translate([0, 0, plate_t - seat_shoulder_t])
	linear_extrude(height = seat_shoulder_t)
	guide_plate_2d_with_cuts(nema17_boss_d + print_clearance) {
		at_flange_coupling_inserts()
			circle(d = m4_insert_d + print_clearance);
		at_nema17_hole_centers()
			circle(d = nema17_bolt_hole_d + print_clearance);
	}
	
	linear_extrude(height = plate_t - seat_shoulder_t)
	guide_plate_2d_with_cuts(nema17_boss_d + print_clearance) {
		at_flange_coupling_inserts()
			circle(d = m4_insert_d + print_clearance);
		at_nema17_hole_centers()
			circle(d = nema17_bolt_hole_d + print_clearance);
		nema17_outline_2d();
	}

	at_flange_coupling_inserts()
		translate([0, 0, -plate_t + m4_insert_l + seat_shoulder_t])
			cylinder(d = m4_insert_d + print_clearance, h = plate_t - m4_insert_l);
}

/* --- BOTTOM_GUIDE_PLATE — 컬럼 최하단(column base) --- */
/*
 * 하부 플레이트(bottom plate) — 모터 몸체 수용 공간(cavity)을
 * 아래에서 닫고, 컬럼(column)의 조립 기준(assembly reference)이 된다.
 */
module bottom_guide_plate()
{
	plate_t = bottom_guide_plate_t();

	linear_extrude(height = plate_t)
	guide_plate_2d_with_cuts(0) {
		at_flange_coupling_inserts()
			circle(d = m4_insert_d + print_clearance);
	}

	translate([0, 0, plate_t])
	linear_extrude(height = seat_shoulder_t)
		difference() {
			offset(delta = seat_shoulder_t + print_clearance) nema17_outline_2d();
			nema17_outline_2d();
		}
		
	at_flange_coupling_inserts()
		translate([0, 0, -plate_t + m4_insert_l + seat_shoulder_t])
			cylinder(d = m4_insert_d + print_clearance, h = plate_t - m4_insert_l);
}

/*
 * COLUMN_LINK 조립체(assembly) — 세 가이드 플레이트(guide plate)를
 * Z축(Z axis)으로 적층한다.
 * GUIDE_RODS, LEADSCREW, STANDOFFS, STEPPER_MOTOR 등 기성품(vitamin)을 함께 배치한다.
 */
module column_link()
{
	/* --- 제작 부품(printed plates) — Z축 적층(항상 그린다) --- */
	bottom_guide_plate();
	translate([0, 0, bottom_guide_plate_t() + nema17_body_l])
		motor_guide_plate();
	translate([0, 0, guide_rod_l - top_guide_plate_t()])
		top_guide_plate();

	/* --- 기성품(hardware) — show_hardware로 시각화 토글 --- */
	if (show_hardware) {
		/*
		 * 가이드 로드(guide rod) — 세 플레이트를 관통해 컬럼(column)의
		 * 굽힘 강성(bending stiffness)과 캐리지 직선 안내(linear guide)를 만든다.
		 */
		at_guide_rods()
			guide_rod(guide_rod_l);

		/*
		 * 하부 FC8(flange coupling) — 가이드 로드 하단을 하부 플레이트에
		 * 고정해 로드 피치 원(rod pitch circle)을 조립 기준으로 잡는다.
		 */
		translate([0, 0, bottom_guide_plate_t()]) {
			at_guide_rods()
					fc8();
			at_rod_mount_inserts()
				translate([0, 0, fc8_flange_t + 4]) // m4 볼트 머리 4mm
					m4_socket_cap_screw(fc8_flange_t + m4_insert_l);
			/*
			* 상향 모터(upward motor) — 마운팅 면(mounting face)을 모터 플레이트
			* 하면에 맞춰 몸체(body)는 캐비티(cavity) 안으로 내려가게 한다.
			*/
			translate([0, 0, nema17_body_l])
				stepper_sf2424();
		}

		translate([0, 0, bottom_guide_plate_t() + nema17_body_l + nema17_boss_h + 5]) {
			coupling_5x8();
			translate([0, 0, 20])
				t8_leadscrew(leadscrew_l - bottom_guide_plate_t() -
					     nema17_body_l - nema17_boss_h - 25);
		}

		translate([0, 0, guide_rod_l - top_guide_plate_t()]) {
			rotate([0, 180, 0]){
				at_guide_rods()
					fc8();
				kfl08();
				at_flange_bearing_block_inserts()
					translate([0, 0, 4.5 + 5])
						m5_socket_cap_screw(4.5 + m5_insert_l);
				at_rod_mount_inserts()
					translate([0, 0, fc8_flange_t + 4]) // m4 볼트 머리 4mm
						m4_socket_cap_screw(fc8_flange_t + m4_insert_l);
			}
		}
	}
}

column_link();
