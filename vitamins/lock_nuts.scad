/*
 * lock_nuts.scad - 나일록 락너트(nyloc lock nut) 기성품(vitamin)
 *
 * SCARA 회전 관절축(revolute axis)에서 숄더 볼트(shoulder bolt)를 풀림
 * 방지(self-locking)로 고정하는 M6 나일록 락너트 시각화용 모델. 제네릭
 * lock_nut()은 육각(hex) 맞변거리·높이·나사 지름을 인자로 받아 어떤
 * 규격이든 만든다. M6 변형은 그 규격의 리터럴을 채운다.
 *
 * Z 브레이크포인트(Z breakpoint) 최적화: 육각 금속부(non-round)는 정육각
 * 단면 한 개를 linear_extrude로 한 번에 쌓는다. 그 위 나일론 칼라(nylon
 * collar)는 회전 대칭(rotationally symmetric)이라 사각 단면 한 개의
 * 단일 rotate_extrude 링으로 만든다. 보어(bore)는 difference로 깎지 않고
 * 어두운 마커로 표현한다 — 음각은 미리보기(F5)에서 안 보이기 때문이다.
 *
 * 좌표계: 축(axis) = Z, 너트 아랫면(bottom face) = z=0. 육각부는
 * z=0..height, 나일론 칼라는 그 위에 얹힌다.
 */

include <../config.scad>

/* --- 색상(cosmetic) --- */
c_steel		= [0.52, 0.53, 0.56];	/* 아연도금강(zinc-plated steel) */
c_nylon		= [0.92, 0.92, 0.88];	/* 나일론 칼라(nylon collar) */
c_bore		= [0.12, 0.12, 0.13];	/* 보어(bore) 음각 마커 */

/*
 * 락너트(제네릭) — 육각 맞변거리(across-flats)·높이·나사 지름을 인자로
 * 받아 육각 금속부 + 나일론 칼라로 만든다. 빌드 헬퍼는 중첩 모듈로 두고
 * difference·union 없이 솔리드를 그대로 배치한다.
 *   af        육각 맞변거리(across-flats) — 렌치 물림면 거리
 *   height    육각 금속부(hex metal body) 높이
 *   thread_d  나사 지름(thread diameter) — 보어 마커 지름
 */
module lock_nut(af, height, thread_d)
{
	/* 외형 비율(cosmetic) — 규격과 무관 */
	collar_h	= height * 0.35;	/* 나일론 칼라(collar) 높이 */
	collar_t	= af * 0.10;		/* 칼라 링(ring) 반경 두께 */
	bore_t		= 0.2;			/* 보어 마커 음각 표시 두께 */

	/* 파생(derived) */
	hex_r	= af / sqrt(3);		/* 외접원(circumscribed) 반지름 */
	br	= thread_d / 2;		/* 보어 반지름 */
	cr	= br + collar_t;	/* 나일론 칼라 외반경 */

	/* Z 브레이크포인트 사각 링 — 반경 r0..r1, 높이 z0..z1 단일 회전체 */
	module ring(r0, r1, z0, z1)
		rotate_extrude(convexity = 2)
			polygon([[r0, z0], [r1, z0], [r1, z1], [r0, z1]]);

	/* 육각 금속부(hex metal body) — 렌치 물림면(wrench flat) */
	color(c_steel)
		linear_extrude(height)
			circle(r = hex_r, $fn = 6);

	/*
	 * 나일론 칼라(nylon collar) — 나사산을 파고드는 자체 풀림 방지
	 * (self-locking) 링. 보어 둘레만 얇게 얹는다.
	 */
	color(c_nylon)
		ring(br, cr, height - eps, height + collar_h);

	/* 보어(bore) — difference 음각 대신 어두운 마커 */
	color(c_bore)
		ring(0, br + eps, height + collar_h - bore_t,
		     height + collar_h + 0.01);
}

/* --- 표준 변형(convenience) --- */
module m4_lock_nut() { lock_nut(7, 3.2, 4); }	/* 스탠드오프 체결 */
module m6_lock_nut() { lock_nut(10, 5, 6); }	/* 회전 관절축 */

m6_lock_nut();
