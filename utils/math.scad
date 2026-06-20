/*
 * math.scad - 공통 수학 헬퍼(math helper)
 */

function sq(x) = x * x;
function circle_point(circle_d, angle) =
	[circle_d / 2 * cos(angle), circle_d / 2 * sin(angle)];
function point_distance(a, b) =
	sqrt(sq(a[0] - b[0]) + sq(a[1] - b[1]));

/*
 * 원형 배치 헬퍼(circular placement helper) — 개수(count), 분포원 지름
 * (pitch circle diameter), 시작각(start angle)으로 반복 피처(feature)의
 * 중심을 잡아 같은 좌표 규칙을 공유한다.
 */
module at_circle(n, circle_d, start_angle = 0)
{
	for (i = [0:n - 1])
		rotate([0, 0, start_angle + 360 / n * i])
			translate([circle_d / 2, 0, 0])
				children();
}