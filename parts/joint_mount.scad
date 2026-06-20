/*
 * joint_mount.scad - STANDARD_JOINT_MOUNT 제작 부품(printed part)
 *
 * SCARA_KINEMATICS.md의 표준 조인트 체결을 따른다. UPPER_ARM_LINK·
 * FOREARM_LINK·TOOL_LINK 모듈 쪽에서 STANDARD_JOINT_HUB를 받아 정렬하고
 * 체결하는 수용부(receiving feature). 링크 플레이트에 통합되는 인터페이스
 * 디스크(disk)로, 실제 부품에서는 이 형상을 플레이트에 합쳐 쓴다.
 *
 * 특징(feature): 키 파일럿 소켓(keyed pilot socket, 전 두께 관통 — 파일럿
 * 수용 겸 중앙 M6 머리·락너트 회피), M3 캡스크류 클리어런스 홀(clearance hole).
 *
 * 인터페이스 치수는 joint_hub.scad를 use하여 함수(joint_pilot_d 등)와 공유
 * 모듈(joint_disk·keyed_pilot)로 읽는다 — 허브가 단일 출처(single source)이며
 * 마운트는 치수를 중복 정의하지 않아 두 부품이 항상 정합한다.
 *
 * 좌표계: 회전축(axis) = Z. 허브 대면(소켓) = z=0, 바깥면 = z=mount_t.
 */

include <../config.scad>
use <joint_hub.scad>

/* --- 마운트 전용 치수 --- */
screw_clear_d	= 3.4;	/* M3 캡스크류 관통 홀 */

/* 판 두께 — 파일럿 수용 + FDM 최소 바닥(전 두께 소켓 위 머리 회피 여유) */
mount_t		= joint_pilot_h() + seat_shoulder_t;

module joint_mount()
{
	/* 키 소켓 — FDM 여유 헐겁게(joint_hub 함수에서 읽음) */
	socket_d = joint_pilot_d() + print_clearance;

	difference() {
		/* 본체 — 공유 디스크(둘레 클리어런스 홀) 한 장 */
		joint_disk(screw_clear_d, mount_t);

		/* keyed pilot 소켓 — 전 두께 관통으로 파서 파일럿 수용 +
		 * 중앙 머리·락너트 회피를 겸한다(비원형이라 difference). */
		translate([0, 0, -eps])
			keyed_pilot(socket_d, mount_t + 2 * eps);
	}
}

joint_mount();
