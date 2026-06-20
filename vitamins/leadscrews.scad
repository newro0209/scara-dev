/*
 * leadscrews.scad - T8 사다리꼴(trapezoidal) 리드스크루(leadscrew) 기성품(vitamin)
 *
 * T8x2 ⌀8 리드스크루: 피치(pitch) 2mm, 리드(lead) 2mm(단일 스타트
 * single start). NopSCADLib 리드넛(lead nut) LSN8x2와 정합하는 Tr8x2
 * 메트릭 사다리꼴 규격이다. 수직 병진축(prismatic translation, J1)에서
 * 회전을 직선 운동으로 바꾸는 구동 나사(power screw)이며, 리드 2mm는
 * 작은 리드각(lead angle)으로 백드라이브(back-drive) 방지에 유리하다.
 *
 * Z 브레이크포인트(Z breakpoint) 최적화: 나사산(thread)은 사다리꼴 산마루·
 * 골이 반복되는 [r, z] 톱니 윤곽선을 단일 rotate_extrude로 돌려 만든다.
 * (헬리컬 대신 둘레 홈으로 단순화 — twist 압출의 스파이크 없이 깔끔하고
 * 가볍다.) boolean·twist 없이 한 솔리드로 끝낸다.
 *
 * 좌표계: 축(axis) = Z, 스크루는 z=0..l.
 */

include <../config.scad>

/* --- 형상 비율(cosmetic) — 사다리꼴 한 피치 내 구간 비율 --- */
root_ratio	= 0.25;	/* 골(root) 평탄 비율 */
flank_ratio	= 0.15;	/* 플랭크(flank) 1개 비율 */
/* 산마루(crest) = 1 - root - 2*flank = 0.45 */

/* --- 색상(cosmetic) --- */
c_screw		= [0.55, 0.56, 0.59];	/* 강철(steel) 연마면 */

/*
 * 리드스크루(제네릭) — 외경(d) x 길이(l), 피치(pitch). 사다리꼴 톱니
 * [r, z] 윤곽선을 만들어 축(r=0)으로 폐합한 뒤 단일 rotate_extrude.
 *   d      공칭 외경(nominal major diameter)
 *   l      스크루 길이
 *   pitch  나사 피치(pitch) — 단일 스타트면 리드와 같다
 */
module leadscrew(d, l, pitch)
{
	or	= d / 2;		/* 외경(major) 반지름 */
	rr	= or - pitch / 2;	/* 골(root) 반지름 — Tr 깊이 ≈ p/2 */
	teeth	= floor(l / pitch);	/* 나사산 개수 */

	rf	= root_ratio * pitch;		/* 골 평탄 구간 */
	fl	= flank_ratio * pitch;		/* 플랭크 구간 */

	/*
	 * 사다리꼴 톱니 윤곽선(outer) — 한 피치마다 골평탄→상승플랭크→
	 * 산마루평탄→하강플랭크. 끝은 골 반경에서 시작·종료해 깔끔히 닫힌다.
	 */
	outer = concat(
		[[rr, 0]],
		[for (i = [0 : teeth - 1]) each
			[[rr, i * pitch + rf],
			 [or, i * pitch + rf + fl],
			 [or, i * pitch + rf + fl + (1 - root_ratio
				- 2 * flank_ratio) * pitch],
			 [rr, (i + 1) * pitch]]],
		[[rr, l]]);

	color(c_screw)
		rotate_extrude(convexity = 4)
			polygon(concat(outer, [[0, l], [0, 0]]));
}

/* --- 표준 변형(convenience) --- */
module t8_leadscrew(l) leadscrew(8, l, 2);	/* T8x2 피치 2 리드 2 */

t8_leadscrew(120);
