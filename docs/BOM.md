# BOM (Bill of Materials)

## 스테퍼 모터(stepper motor) — Sanyo Denki SANMOTION F2 (2-phase)

NEMA17(□42mm) 프레임, 1.8° 기본 스텝각(basic step angle), **바이폴라 결선(bipolar
winding)**, 정격 전류 1.2 A/phase. 세 모델은 스택 길이(stack length)만 달라 홀딩
토크(holding torque)가 차등된다 — 끝자리 `4 > 3 > 2` = 길이·토크 순. 출처는
디바이스마트(devicemart) 정식 판매 페이지.

> **전기 스펙 주(注)**: `-12B41`(1.2 A) 권선의 저항(resistance)·인덕턴스(inductance)는
> 디바이스마트 미공개. 동일 스택의 `-10B41`(1.0 A) 데이터시트 값을 **참고**로
> 병기하나, 권선 정격 전류가 달라 실제 R·L은 다를 수 있다. 기계 스펙(길이·질량·
> 로터 관성)은 동일 모터라 그대로 유효하다.

| 항목 | SF2424-12B41 | SF2423-12B41 | SF2422-12B41 |
|---|---|---|---|
| 축 매핑(axis) | J2 SHOULDER | J3 ELBOW | J4 WRIST |
| 홀딩 토크(holding torque) | 0.8 N·m (8 kgf·cm) | 0.56 N·m (5.6 kgf·cm) | 0.43 N·m (4.3 kgf·cm) |
| 정격 전류(rated current) | 1.2 A/phase | 1.2 A/phase | 1.2 A/phase |
| 상(phase) | 2 | 2 | 2 |
| 기본 스텝각(step angle) | 1.8° | 1.8° | 1.8° |
| 로터 관성(rotor inertia) | 0.094 ×10⁻⁴ kg·m² | 0.063 ×10⁻⁴ kg·m² | 0.046 ×10⁻⁴ kg·m² |
| 질량(mass) | 0.51 kg | 0.38 kg | 0.3 kg |
| 몸체 길이(body length) | 59.5 mm | 48 mm | 39 mm |
| 프레임(frame) | □42 mm | □42 mm | □42 mm |
| 샤프트(shaft) | ⌀5 mm D-cut | ⌀5 mm D-cut | ⌀5 mm D-cut |
| 권선 저항(resistance)¹ | 6.5 Ω | 5.3 Ω | 4.6 Ω |
| 권선 인덕턴스(inductance)¹ | 16 mH | 12.5 mH | 9.6 mH |
| 단가(unit price) | 40,700원 | 37,400원 | 35,200원 |

¹ `-10B41`(1.0 A) 데이터시트 참고값 — `-12B41` 권선의 실측치는 다를 수 있음.

허용 하중(SF2424 기준): 스러스트(thrust) 10 N, 반경(radial) 20 N. 동작 온도
−10 ~ +50 °C.

### 출처(sources)

- [SF2424-12B41 — 디바이스마트 (40,700원, Hold Torque 8 kgf·cm, 1.2 A)](https://www.devicemart.co.kr/goods/view?no=14111083)
- [SF2423-12B41 — 디바이스마트 (37,400원, Hold Torque 5.6 kgf·cm, 1.2 A)](https://www.devicemart.co.kr/goods/view?no=14111082)
- [SF2422-12B41 — 디바이스마트 (35,200원, Hold Torque 4.3 kgf·cm, 1.2 A)](https://www.devicemart.co.kr/goods/view?no=14111081)
- [SF2424-10B41 — RS (기계 스펙 참고)](https://befr.rs-online.com/web/p/stepper-motors/1833583)
- [SF2423-10B41 — Farnell (기계 스펙 참고)](https://uk.farnell.com/sanyo-denki/sf2423-10b41/stepper-motor-2-ph-1a-0-56nm/dp/3052030)
- [SF2422-10B41 — Datasheet4U (기계 스펙 참고)](https://datasheet4u.com/datasheets/Sanyo-Denki/SF2422-10B41/1317199)
- [SANMOTION F2 시리즈 데이터시트 (PDF)](https://www.tme.eu/Document/0f4956c3230e00c2b192ccc3a828a810/SANMOTION_F2_E.pdf)
