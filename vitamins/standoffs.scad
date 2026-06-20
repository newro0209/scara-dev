/*
 * standoffs.scad - 육각 스탠드오프(hex standoff) 기성품(vitamin)
 *
 * PCB·플레이트 사이 간격 유지(spacer)와 체결(fastening)에 쓰는 황동
 * (brass) 암-암(female-female) 육각 스탠드오프. 맞변거리(across-flats)
 * 기준 정육각형(regular hexagon) 몸체로 모델링한다.
 *
 * Z 브레이크포인트(Z breakpoint) 최적화: 몸체는 비회전(non-round)
 * 정육각형이라 단면을 linear_extrude로 한 번에 쌓는다. 보어(bore)는
 * difference로 깎지 않고 — rotate_extrude 솔리드를 깎으면 미리보기(F5)에
 * 안 보일 수 있어 — 양 끝에 어두운 디스크(dark disk) 마커로 표시한다.
 *
 * 좌표계: 축(axis) = Z, 스탠드오프 바닥 = z=0. z=0..length.
 */

include <../config.scad>

/* --- 형상 비율(cosmetic) --- */
bore_ratio	= 0.62;	/* 보어 마커 지름 = 맞변거리(af) 대비 비율 */
marker_t	= 0.4;	/* 보어 마커 디스크(disk) 두께 */

/* --- 색상(cosmetic) --- */
c_brass		= [0.78, 0.62, 0.28];	/* 황동(brass) 몸체 */
c_bore		= [0.12, 0.10, 0.05];	/* 보어(bore) 음각 마커 */

/* 맞변거리(across-flats) af → 외접원 반지름(circumradius). */
function hex_circumradius(af) = af / sqrt(3);

/*
 * 육각 스탠드오프 — 맞변거리(af)와 길이(length)를 받는다. 정육각형
 * 단면을 linear_extrude로 쌓아 몸체를 만들고, 보어(bore)는 양 끝
 * 어두운 디스크로 표시한다(boolean 없음).
 */
module hex_standoff(af, length)
{
	cr  = hex_circumradius(af);	/* 정육각형 외접원 반지름 */
	mr  = af * bore_ratio / 2;	/* 보어 마커 반지름 */

	/* 육각 몸체 — 맞변거리(af) 기준 정육각형을 전길이로 압출 */
	color(c_brass)
		linear_extrude(height = length)
			circle(r = cr, $fn = 6);

	/* 보어(bore) 마커 — 양 끝면에 어두운 디스크로 통공을 표현 */
	color(c_bore) {
		translate([0, 0, length - marker_t - eps])
			cylinder(h = marker_t, r = mr);
		translate([0, 0, eps])
			cylinder(h = marker_t, r = mr);
	}
}

/* --- 표준 변형(convenience) — M3 황동 스탠드오프 --- */
module standoff_m3(length) { hex_standoff(5.5, length); }	/* AF 5.5 */

standoff_m3(20);
