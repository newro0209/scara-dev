/*
 * joint_hub.scad - STANDARD_JOINT_HUB 제작 부품(printed part)
 *
 * SCARA_KINEMATICS.md의 표준 조인트 체결을 따른다. J2(어깨)·J3(팔꿈치)·
 * J4(손목) 회전 관절이 공유하는 표준 조인트 허브 — 회전축을 중심으로 인접
 * 링크를 정렬하고, M3 heat-set 인서트(insert) 체결로 토크를 전달한다.
 *
 * 특징(feature): 원형 플랜지(circular flange), 직선 키 파일럿 보스(keyed pilot
 * boss), 대칭 M3 인서트 패턴, 축 보어(axis bore). 외곽은 360° 회전 여유를 위해
 * 원형으로 유지한다. 베어링 내륜 이격(standoff)은 별도 스페이서(spacer)가
 * 담당한다.
 *
 * 인터페이스는 단일 출처(single source of truth)다. 마운트가 직접 읽는 값만
 * 접근자 함수(joint_pilot_d·joint_pilot_h)로 노출하고, 모듈 내부에서만 쓰는
 * 치수는 변수로 둔다(use가 모듈을 정의 스코프에서 해석하므로 cross-file 안전).
 * parts/joint_mount.scad는 joint_hub를 use해 함수·공유 모듈(joint_disk·
 * keyed_pilot)을 읽고, 치수를 중복 정의하지 않는다.
 *
 * 좌표계: 회전축(axis) = Z, 플랜지 = z=0..flange_t, 파일럿 보스는 +z(마운트 쪽).
 */

include <../config.scad>

/* --- 인터페이스 접근자(accessor) — joint_mount.scad가 use로 직접 호출 --- */
function joint_pilot_d() = 20;			/* keyed pilot boss 외경 — 방향·중심 기준 */
function joint_pilot_h() = seat_shoulder_t;	/* pilot boss 돌출 높이 */

/* --- 형상 치수 — joint_hub 모듈 내부에서만 쓰여 변수로 둔다. use는 모듈을
 * 그 정의 스코프에서 해석하므로 cross-file(마운트)에서도 안전하다. --- */
joint_axis_bore_d = 8 + print_clearance;	/* M6 숄더 볼트 관통 보어 */
joint_pilot_key_t = 2;				/* 방향 키(key) 평면 절삭량 */
joint_bolt_n      = 6;				/* 둘레 체결 볼트 홀 개수(대칭 패턴) */
joint_bolt_head_d = 6.5;			/* 둘레 M3 캡 스크류 머리 + 여유 — 디스크 사이징 */
joint_head_d      = 13;				/* 중앙 M6 숄더 볼트 머리 — assert용 */

/*
 * 디스크 외경(disk diameter) — 중앙 파일럿(pilot_d)에 둘레 여백 하나를 두고,
 * 그 바깥으로 둘레 볼트 머리와 외곽 여백을 지름 양쪽으로((bolt_head + margin)
 * × 2) 더한다. 파일럿·볼트·외곽이 서로 layout_margin으로 이격된다.
 */
joint_disk_d = joint_pilot_d() + layout_margin
	+ (joint_bolt_head_d + layout_margin) * 2;

/* 검증 — 중앙 M6 머리가 파일럿 소켓(마운트 전 두께 관통)을 통과해야 한다. */
assert(joint_pilot_d() >= joint_head_d,
       "joint_pilot_d must be >= joint_head_d (M6 head must clear pilot socket)");

/* 체결 볼트 분포원(bolt circle) — 디스크 가장자리에서 볼트 머리 + margin 안쪽. */
joint_bolt_pitch_circle_d = joint_disk_d - joint_bolt_head_d - 2 * layout_margin;

/* --- 허브 전용 치수 --- */
insert_hole_d	= 4.2;	/* M3 heat-set brass insert 블라인드 홀 지름 */
insert_hole_h	= 5;	/* 인서트 홀 깊이 */
flange_d	= joint_disk_d;	/* 원형 플랜지 외경 — 머리 레이아웃 파생 */
flange_t	= insert_hole_h + seat_shoulder_t;	/* 인서트 블라인드 홀 + FDM 최소 바닥 */

/*
 * 방향 키(key)가 붙은 파일럿 형상 — 외경 d, 높이 h로 바로 압출한다. 한쪽
 * 평면 절삭으로 각도를 강제하며, 허브 보스(양형)·마운트 소켓(음형)이 공유해
 * 항상 일치한다.
 */
module keyed_pilot(d, h)
	linear_extrude(h)
		difference() {
			circle(d = d);
			translate([d / 2 - joint_pilot_key_t, -d])
				square([d, 2 * d]);
		}

/*
 * 허브·마운트 공유 디스크 — 디스크 외경 + 중앙 축 보어 + 볼트 피치원 홀
 * (bolt_hole_d)을 갖는 높이 h 솔리드. 두 부품이 같은 외경·축 보어·볼트원을
 * 쓴다.
 */
module joint_disk(bolt_hole_d, h)
	linear_extrude(h)
		difference() {
			circle(d = joint_disk_d);
			circle(d = joint_axis_bore_d);
			for (i = [0 : joint_bolt_n - 1])
				rotate([0, 0, i * 360 / joint_bolt_n])
					translate([joint_bolt_pitch_circle_d / 2, 0])
						circle(d = bolt_hole_d);
		}

module joint_hub()
{
	pilot_h	= joint_pilot_h();

	difference() {
		union() {
			/* keyed pilot boss — 마운트 소켓에 끼워 동심·방향 강제 */
			translate([0, 0, flange_t - eps])
				keyed_pilot(joint_pilot_d(), pilot_h + eps);

			/* 플랜지 — 공유 디스크(축 보어 + 인서트 홀 관통) */
			joint_disk(insert_hole_d, flange_t);

			/* blind 플러그 — 같은 디스크를 볼트 홀 없이(bolt_hole_d = 0)
			 * 두께에서 인서트 깊이를 뺀 만큼 깔아 인서트 홀 바닥을 메운다
			 * → 인서트 홀이 blind가 된다(축 보어는 디스크가 관통 유지). */
			joint_disk(0, flange_t - insert_hole_h);
		}

		/* 축 보어 — 플랜지·파일럿 전체 관통(M6 숄더 볼트) */
		translate([0, 0, -eps])
			cylinder(d = joint_axis_bore_d,
				 h = flange_t + pilot_h + 2 * eps);
	}
}

joint_hub();
