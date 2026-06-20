/*
 * shaft_couplings.scad - 샤프트 커플링(shaft coupling) 기성품(vitamin)
 *
 * SCARA 수직 병진축(prismatic axis, J1)에서 모터축(motor shaft)과
 * 리드스크루(leadscrew)를 잇는 알루미늄(aluminum) 강성 커플링(rigid
 * coupling). 양단 보어(bore)가 서로 달라(모터 5mm·스크루 8mm) 토크
 * (torque)를 축방향(axial)으로 전달한다.
 *
 * Z 브레이크포인트(Z breakpoint) 최적화: 커플링은 회전 대칭
 * (rotationally symmetric)이라 외곽(OD)과 양단 보어(bore)가 이루는
 * 단(step)을 환형(annular) [r, z] 단면 하나로 묶어 단일 rotate_extrude로
 * 만든다. union·difference 없이 솔리드 하나로 끝낸다. 셋 스크루(set
 * screw) 머리는 양단 옆면에 마커로 배치한다(boolean 없음).
 *
 * 좌표계: 축(axis) = Z, 커플링 바닥 = z=0. z=0..length. 보어 a(모터)가
 * 아래(z=0), 보어 b(스크루)가 위.
 */

include <../config.scad>

/* --- 형상 비율(cosmetic) --- */
set_inset	= 5;	/* 셋 스크루(set screw) 끝면에서 안쪽 거리 */
set_pitch	= 5;	/* 한 보어쪽 두 셋 스크루의 축방향(axial) 간격 */
set_head_d	= 3;	/* 셋 스크루 머리 마커 지름 */
set_head_h	= 1.5;	/* 셋 스크루 머리 마커 돌출 높이 */

/* --- 색상(cosmetic) --- */
c_coupling	= [0.74, 0.75, 0.77];	/* 알루미늄(aluminum) 몸체 */
c_set		= [0.15, 0.15, 0.16];	/* 세트 스크루(set screw) 머리 */

/*
 * 샤프트 커플링 — 외경(od)·길이(length)·양단 보어(bore_a 바닥,
 * bore_b 상단)를 받는다. 외곽과 양단 보어가 만드는 단(step)을 환형
 * 단면 하나로 묶어 rotate_extrude로 돌린다. 보어가 가운데서 만나
 * 막힌 단(blind step)을 이루므로 프로파일만으로 표현된다.
 */
module shaft_coupling(od, length, bore_a, bore_b)
{
	or  = od / 2;		/* 외경 반지름 */
	ar  = bore_a / 2;	/* 바닥 보어(모터축) 반지름 */
	br  = bore_b / 2;	/* 상단 보어(스크루) 반지름 */
	zm  = length / 2;	/* 양단 보어가 만나는 중앙 단(step) */

	/*
	 * 환형 단면: 바깥 벽(아래→위) 후 상단 보어 벽→중앙 단→바닥 보어
	 * 벽 순으로 안쪽 윤곽을 그려 폐합한다. 양단 보어 반경이 달라
	 * 중앙(zm)에서 반경이 꺾이는 막힌 단(blind step)을 이룬다.
	 */
	color(c_coupling)
		rotate_extrude(convexity = 4)
			polygon([[ar, 0],  [or, 0],
				 [or, length], [br, length],
				 [br, zm], [ar, zm]]);

	/*
	 * 셋 스크루(set screw) 머리 — 리지드 커플링(rigid coupling)은
	 * 양단 보어(bore)를 각각 2개 셋 스크루로 무두질(grub)해 축(shaft)을
	 * 눌러 토크(torque)를 전달한다. 보어쪽마다 축방향(axial)으로
	 * set_pitch만큼 떨어뜨린 마커 2개씩(총 4개)을 옆면에 얹는다.
	 */
	color(c_set) {
		translate([or - set_head_h - eps, 0, set_inset])
			rotate([0, 90, 0])
				cylinder(h = set_head_h + eps, d = set_head_d);
		translate([or - set_head_h - eps, 0, set_inset + set_pitch])
			rotate([0, 90, 0])
				cylinder(h = set_head_h + eps, d = set_head_d);
		translate([or - set_head_h - eps, 0, length - set_inset - set_pitch])
			rotate([0, 90, 0])
				cylinder(h = set_head_h + eps, d = set_head_d);
		translate([or - set_head_h - eps, 0, length - set_inset])
			rotate([0, 90, 0])
				cylinder(h = set_head_h + eps, d = set_head_d);
	}
}

/* --- 표준 변형(convenience) — 모터 5mm ↔ 스크루 8mm --- */
module coupling_5x8() { shaft_coupling(12.5, 25, 5, 8); }

coupling_5x8();
