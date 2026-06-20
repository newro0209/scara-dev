/*
 * screws.scad - 숄더 볼트(shoulder bolt) 기성품(vitamin)
 *
 * SCARA 회전 관절축(revolute axis)에서 베어링 내륜(inner race)을 끼우는
 * 매끈한 숄더(shoulder)와 소켓 헤드(socket head)를 갖는 M6 숄더 볼트
 * 시각화용 모델(ISO 7379 류). 제네릭 shoulder_bolt()는 머리·숄더·나사
 * 치수를 인자로 받아 어떤 규격이든 만든다. M6 변형은 리터럴을 채운다.
 *
 * Z 브레이크포인트(Z breakpoint) 최적화: 볼트는 회전 대칭(rotationally
 * symmetric)이라 머리→숄더→나사 [r, z] 윤곽선 하나를 축(r=0)으로 폐합해
 * 단일 rotate_extrude 솔리드로 만든다. 나사산(thread)은 윤곽선의 나사부에
 * 메트릭 V자 톱니(산·골)를 직접 넣어 표현한다 — twist·boolean 없이 깔끔.
 * 육각 소켓(hex socket)은 머리 윗면 아래로 어두운 육각 기둥을 얹어 음각
 * 리세스(recess)처럼 보이게 한다.
 *
 * 좌표계: 축(axis) = Z, 머리 윗면(top face) = z=0, 몸통(body)은 -z로
 * 진행한다(머리 -head_h → 숄더 → 나사 끝).
 */

include <../config.scad>

/* --- 색상(cosmetic) --- */
c_steel		= [0.52, 0.53, 0.56];	/* 합금강(alloy steel) 볼트 본체 */
c_socket	= [0.10, 0.10, 0.11];	/* 육각 소켓(hex socket) 음각 리세스 */

/* 미터 거친 나사 표준 피치(coarse thread pitch) — 나사 외경에서 산출 */
function coarse_pitch(d) =
	d <= 3 ? 0.5 : d <= 4 ? 0.7 : d <= 5 ? 0.8
	: d <= 6 ? 1.0 : d <= 8 ? 1.25 : 1.5;

/*
 * 숄더 볼트(제네릭) — 머리·숄더·나사 치수를 인자로 받아 만든다. 빌드
 * 헬퍼는 중첩 모듈(nested module)로 두고 difference·union 없이 솔리드를
 * 그대로 배치한다.
 *   head_d/h     소켓 헤드(socket head) 지름·높이
 *   shoulder_d/l 매끈한 숄더(shoulder) 지름·길이 — 베어링 내륜 끼움면
 *   thread_d/l   나사부(thread) 외경·길이
 */
module shoulder_bolt(head_d, head_h, shoulder_d, shoulder_l,
		     thread_d, thread_l)
{
	/* 외형 비율(cosmetic) — 규격과 무관 */
	socket_af	= head_d * 0.55;	/* 육각 소켓 맞변(across-flats) */
	socket_depth	= head_h * 0.6;		/* 소켓 리세스 깊이 */
	head_chamfer	= head_h * 0.15;	/* 머리 윗면 가장자리 모따기 */
	thread_pitch	= coarse_pitch(thread_d);	/* 나사 외경별 거친 피치 */

	/* 파생(derived) — 머리 윗면 z=0 기준, 몸통은 -z로 내려간다 */
	hr	= head_d / 2;		/* 머리 반지름 */
	sr	= shoulder_d / 2;	/* 숄더 반지름 */
	tr	= thread_d / 2;		/* 나사 외경(crest) 반지름 */
	tr_root	= tr - 0.61 * thread_pitch;	/* 나사 골(root) — 깊이 ≈0.61·피치 */
	z_sh	= -head_h;		/* 머리→숄더 경계 */
	z_th	= z_sh - shoulder_l;	/* 숄더→나사 경계 */
	z_end	= z_th - thread_l;	/* 나사 끝 */
	n_th	= floor(thread_l / thread_pitch);	/* 나사산 개수 */

	/* Z 브레이크포인트 회전체 — [r, z] 윤곽선을 축(r=0)으로 폐합 */
	module revolve(points)
		rotate_extrude(convexity = 4)
			polygon(concat(points,
					[[0, points[len(points) - 1][1]],
					 [0, points[0][1]]]));

	/*
	 * 본체 윤곽선 — 머리 윗면 모따기(chamfer) → 머리 외경 → 숄더(매끈한
	 * 끼움면) → 나사부. 나사부는 골(tr_root)·산(tr)이 교대하는 메트릭
	 * V자 톱니를 -z로 내려가며 직접 넣는다(twist 없음).
	 */
	thread = [for (i = [0 : n_th - 1]) each
			[[tr_root, z_th - i * thread_pitch],
			 [tr,      z_th - i * thread_pitch - thread_pitch / 2]]];

	color(c_steel)
		revolve(concat(
			[[hr - head_chamfer, 0], [hr, -head_chamfer],
			 [hr, z_sh], [sr, z_sh], [sr, z_th]],
			thread,
			[[tr_root, z_end]]));

	/*
	 * 육각 소켓(hex socket) — 머리 윗면(z=0) 아래로 어두운 육각 기둥을
	 * 얹어 음각 리세스(recess)처럼 보이게 한다(boolean 없음).
	 */
	color(c_socket)
		translate([0, 0, -socket_depth])
			linear_extrude(socket_depth + eps)	/* +eps: 머리 윗면(z=0)에 파묻음 */
				circle(d = socket_af / cos(30), $fn = 6);
}


/*
 * 소켓 캡스크류(socket cap screw) — FC8·스탠드오프 같은 일반 체결부를
 * 시각화한다. 좌표계는 숄더 볼트와 같이 머리 윗면(top face) = z=0,
 * 몸통은 -Z로 내려간다.
 */
module socket_cap_screw(head_d, head_h, thread_d, thread_l)
{
	socket_af	= head_d * 0.55;
	socket_depth	= head_h * 0.6;
	head_chamfer	= head_h * 0.12;
	thread_pitch	= coarse_pitch(thread_d);

	hr	= head_d / 2;
	tr	= thread_d / 2;
	tr_root	= tr - 0.61 * thread_pitch;
	z_head	= -head_h;
	z_end	= z_head - thread_l;
	n_th	= floor(thread_l / thread_pitch);

	module revolve(points)
		rotate_extrude(convexity = 4)
			polygon(concat(points,
					[[0, points[len(points) - 1][1]],
					 [0, points[0][1]]]));

	thread = [for (i = [0 : n_th - 1]) each
			[[tr_root, z_head - i * thread_pitch],
			 [tr,      z_head - i * thread_pitch - thread_pitch / 2]]];

	color(c_steel)
		revolve(concat([[hr - head_chamfer, 0], [hr, -head_chamfer],
				 [hr, z_head], [tr, z_head]], thread,
				 [[tr_root, z_end]]));

	color(c_socket)
		translate([0, 0, -socket_depth])
			linear_extrude(socket_depth + eps)
				circle(d = socket_af / cos(30), $fn = 6);
}

/* --- 표준 변형(convenience) --- */
module m3_socket_cap_screw(l) { socket_cap_screw(5.5, 3, 3, l); }	/* 조인트 허브 체결 */
module m4_socket_cap_screw(l) { socket_cap_screw(7, 4, 4, l); }	/* FC8 체결 */
module m5_socket_cap_screw(l) { socket_cap_screw(8.5, 5, 5, l); }	/* KFL08 체결 */
/* 샤프트 ⌀8, M6 나사, 머리 ⌀13×5, 나사길이 11 — 샤프트 ⌀8이 608 보어 정합 */
module m6_shoulder_bolt(shoulder_l)
	shoulder_bolt(13, 5, 8, shoulder_l, 6, 11);

m6_shoulder_bolt(20);
