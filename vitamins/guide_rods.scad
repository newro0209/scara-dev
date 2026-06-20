/*
 * guide_rods.scad - 매끈한 선형 가이드 로드(smooth linear guide rod) 기성품(vitamin)
 *
 * LM8 계열 ⌀8 경화강(hardened steel) 직선 봉(linear shaft). 선형 부시
 * (linear bushing)나 LM 베어링이 미끄러지는 마찰면(running surface)을
 * 제공한다. 제네릭 smooth_rod()가 어떤 지름(LM6·LM8·LM10 등)이든 만들고,
 * 변형 guide_rod()가 LM8 리터럴을 넘긴다.
 *
 * Z 브레이크포인트(Z breakpoint) 최적화: 로드는 회전 대칭(rotationally
 * symmetric)이라 [r, z] 윤곽선 하나를 단일 rotate_extrude로 돌려 솔리드를
 * 만든다. 양 끝 모따기(chamfer)는 윤곽선 자체에 포함해 difference·union을
 * 쓰지 않는다.
 *
 * 좌표계: 축(axis) = Z, 봉은 z=0..l.
 */

include <../config.scad>

/* --- 형상 비율(cosmetic) --- */
chamfer_ratio	= 0.6;	/* 끝 모따기(chamfer) 깊이 = 지름 대비 비율 */

/* --- 색상(cosmetic) --- */
c_rod		= [0.55, 0.56, 0.59];	/* 경화강(hardened steel) 연마면 */

/*
 * 매끈한 로드(제네릭) — 지름(d) x 길이(l). 양 끝은 부시(bushing) 삽입을
 * 돕는 도입 모따기(lead-in chamfer)로 둔다. [r, z] 단면을 단일
 * rotate_extrude로 돌린다(중첩 모듈 revolve).
 */
module smooth_rod(d, l)
{
	r	= d / 2;			/* 봉 반지름 */
	ch	= r * chamfer_ratio;		/* 모따기 깊이(축방향) */

	/* Z 브레이크포인트 회전체 — [r, z] 윤곽선을 축으로 폐합해 단일 회전 */
	module revolve(points)
		rotate_extrude(convexity = 2)
			polygon(concat(points,
					[[0, points[len(points) - 1][1]],
					 [0, points[0][1]]]));

	/*
	 * 끝 모따기(chamfer) — 양 끝을 비스듬히 깎아 부시(bushing)·LM
	 * 베어링 삽입 시 모서리 걸림(edge catch)을 막는 도입부로 쓴다.
	 */
	color(c_rod)
		revolve([[r - ch, 0],  [r, ch],
			 [r, l - ch], [r - ch, l]]);
}

/* --- 표준 변형(convenience) --- */
module guide_rod(l) smooth_rod(8, l);	/* LM8 ⌀8 선형 가이드 */

guide_rod(120);
