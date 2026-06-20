// SCARA 로봇 공통 사양(specification) — 모든 부품 파일에서 include해 사용한다.

$fn = 48;

// ── 공차(tolerance) ──
print_clearance = 0.2;   // FDM 출력 끼워맞춤(fit) 여유 — 압입(press-fit) 자리 제외
eps             = 1/128; // 미세 겹침(epsilon) — 접하는 솔리드를 살짝 겹쳐 동일면(coincident face) z-파이팅 방지

// ── FDM 출력 사양(print specification) ──
fdm_layer_h       = 0.28;   // 레이어 높이(layer height) — 슬라이서(slicer) 설정값과 일치시킨다.
fdm_shoulder_layers = 6;   // 숄더(shoulder) 최소 레이어 수 — FDM 최소 구조 벽(0.4mm 노즐 3겹 ~1.2mm) 기준 하한값.

// ── 레이아웃(layout) ──
// layout_margin — 플레이트 위 부품 배치 공통 여백(margin). 부품 외곽선에서
// 사방으로 주는 값 → 부품끼리는 2*margin 이격, 외곽 가장자리도 margin 확보.
layout_margin = 4;

// ── 시트 형상(seat geometry) ──
// seat_shoulder_t — fdm_layer_h · fdm_shoulder_layers 파생. 슬라이서 설정 변경 시 자동 연동.
seat_shoulder_t = fdm_layer_h * fdm_shoulder_layers;
