# SCARA 로봇 기구학 모델 (SCARA Robot Kinematic Model)

## 목적

조립체·부품 명명은 이 문서의 SCARA 기구학 모델을 기준으로 맞춘다.
기구학 모델은 **관절(joint)**, **축(axis)**, **링크(link)**, **실존 부품(parts)**을 분리해서 표현한다.

## 참조 이미지

![SCARA 구조 참조](docs/images/scara_structure_reference.webp)

![SCARA DH 기구 다이어그램](docs/images/scara_kinematic_dh.jpg)

## 기구학 연결 모델

| 개념 | 실존성 | 역할 |
|---|---|---|
| `*_AXIS` | 순수 추상 — 수학적 선(line)/방향 | 관절의 병진 방향 또는 회전 중심선 정의 |
| `*_JOINT` | 순수 추상 — 운동 허용 관계 | 두 링크(link) 사이 자유도(DOF) 정의 |
| `*_LINK` | 반추상 — 실존 부품들의 집합 | 함께 움직이는 물리 부품을 묶는 단위 |
| `parts` | 완전 실존 — CAD 파일, 출력물 | 실제 제작·조립 대상 |

`*_JOINT`는 두 링크를 연결하는 기구학적 관절이다.
`*_AXIS`는 해당 관절의 병진 방향 또는 회전 중심선이다.
`*_LINK`는 같은 관절 상태에서 함께 움직이는 실존 부품들의 집합이다.

```text
WAIST_JOINT (J0) connects BASE_LINK -> COLUMN_LINK
  type: revolute
  axis: WAIST_AXIS

VERTICAL_JOINT (J1) connects COLUMN_LINK -> CARRIAGE_LINK
  type: prismatic
  axis: VERTICAL_AXIS

SHOULDER_JOINT (J2) connects CARRIAGE_LINK -> UPPER_ARM_LINK
  type: revolute
  axis: SHOULDER_AXIS

ELBOW_JOINT (J3) connects UPPER_ARM_LINK -> FOREARM_LINK
  type: revolute
  axis: ELBOW_AXIS

WRIST_JOINT (J4) connects FOREARM_LINK -> TOOL_LINK
  type: revolute
  axis: WRIST_AXIS
```

## 링크와 실존 부품

실제 OpenSCAD 부품·조립체 이름은 각 링크의 `parts`로 둔다.
부품명은 반드시 추상 링크명과 1:1로 대응하지 않아도 된다.

### JOINTS

관절(joint) 엔티티 목록. `parent`·`child`는 LINKS 참조 — URDF 조인트 트리 관례(parent → child).

| joint | id | type | axis | parent | child | description |
|---|---|---|---|---|---|---|
| WAIST_JOINT | J0 | revolute | WAIST_AXIS | BASE_LINK | COLUMN_LINK | 컬럼 전체를 수직축(vertical axis) 기준으로 회전시키는 허리 관절. 산업용 로봇 축 1(Axis 1) 대응. WAIST_AXIS는 VERTICAL_AXIS와 공선(collinear) — BASE_LINK 원점을 지나는 Z축. **현재 임시 고정(fixed) 제작 — 구동기(actuator) 미정** |
| VERTICAL_JOINT | J1 | prismatic | VERTICAL_AXIS | COLUMN_LINK | CARRIAGE_LINK | 리드스크루(leadscrew) 구동으로 캐리지를 수직 병진(vertical translation)시키는 관절 |
| SHOULDER_JOINT | J2 | revolute | SHOULDER_AXIS | CARRIAGE_LINK | UPPER_ARM_LINK | 상완 전체를 수평면에서 회전(horizontal rotation)시키는 어깨 관절 |
| ELBOW_JOINT | J3 | revolute | ELBOW_AXIS | UPPER_ARM_LINK | FOREARM_LINK | 전완을 수평면에서 회전시키는 팔꿈치 관절 |
| WRIST_JOINT | J4 | revolute | WRIST_AXIS | FOREARM_LINK | TOOL_LINK | 툴 플랜지(tool flange)를 수평면에서 회전시키는 손목 관절 |

### LINKS & PARTS

링크(link) 엔티티와 소속 실존 부품(part) 목록.

**BASE_LINK** — 고정 기준 링크(fixed reference link). 로봇이 실제로 고정되는 지면/마운팅 포인트. WAIST_JOINT(J0) 608 베어링 하우징을 포함한다. J0는 현재 임시 고정형(provisional fixed)으로 제작하며 구동기는 미정.

| category | part | description |
|---|---|---|
| vitamin | WAIST_BEARINGS | WAIST_JOINT(J0) 회전 지지 608 베어링 ×2 (8×22×7) — COLUMN_LINK를 수직축 기준 회전시킨다. |
| vitamin | WAIST_BOLT | 컬럼 축 스택(axial stack)을 조이는 M6 축 볼트. |
| vitamin | LOCK_NUT | WAIST_BOLT 풀림 방지 락너트(lock nut). |

**COLUMN_LINK** — 가이드 로드(guide rod) 3개를 삼각 배치(triangular layout)한 수직 컬럼(column) 링크. WAIST_JOINT(J0)로 BASE_LINK 위에서 수평 회전. 가이드 로드는 3장의 가이드 플레이트(guide plate)를 모두 관통해 컬럼 강성을 확보. 모터는 중단(MOTOR_GUIDE_PLATE)에 상향 설치되어 리드스크루와 직결되며, 모터 몸체는 MOTOR_GUIDE_PLATE↔BOTTOM_GUIDE_PLATE 스탠드오프 공간에 수용된다.

```
[TOP_GUIDE_PLATE]     — 캐리지 이동 상한. 리드스크루 자유단(free end) KFL08 장착면.
    │ GUIDE_RODS + LEADSCREW  (캐리지 이동 구간)
[MOTOR_GUIDE_PLATE]   — 캐리지 이동 하한. 모터 마운팅 (상향). 리드스크루 구동단(fixed end) KFL08 장착면.
    │ GUIDE_RODS (관통) + STANDOFFS  (모터 몸체 수용 공간)
[BOTTOM_GUIDE_PLATE]  — 컬럼 최하단. WAIST_AXIS 회전 저널(journal) — 현재 고정.
```

| category | part | description |
|---|---|---|
| printed | TOP_GUIDE_PLATE | 캐리지 이동 상한. 리드스크루 자유단(free end) KFL08 장착면. |
| printed | MOTOR_GUIDE_PLATE | 캐리지 이동 하한. 모터 상향 마운팅 + 리드스크루 구동단(fixed end) KFL08 장착면. |
| printed | BOTTOM_GUIDE_PLATE | 컬럼 최하단. WAIST_AXIS 회전 저널(journal, 현재 고정). 모터 몸체 수용 공간 하판. |
| vitamin | GUIDE_RODS | 3개 삼각 배치 직선 가이드 로드 — 캐리지 직선 운동(linear motion) 안내, 3판 관통 강성. |
| vitamin | LEADSCREW | 회전을 수직 병진(vertical translation)으로 변환하는 리드스크루 (T8, 8mm). |
| vitamin | STANDOFFS | MOTOR↔BOTTOM 플레이트 간격 고정 + 모터 몸체 수용 공간 형성. |
| vitamin | STEPPER_MOTOR | J1 구동 스테퍼 모터 — 상향 설치, 리드스크루 직결. |
| vitamin | SHAFT_COUPLING | 모터축↔리드스크루 직결 커플링(shaft coupling). |
| vitamin | FLANGE_BEARING_BLOCKS | 리드스크루 양단 KFL08 플랜지 베어링 유닛(8mm bore, 셀프얼라인) — 반경 지지. |

**CARRIAGE_LINK** — 수직 병진(prismatic) 관절을 따라 움직이는 캐리지 링크(carriage link). 오픈 프레임으로 J2 어깨축 베어링 스팬(bearing span)을 확보. J2 구동 모터는 CARRIAGE_TOP_PLATE 후방 슬롯 시트(slot seat)에 마운팅되어 전후 이동으로 벨트 장력을 조절하며, 20T→60T GT2 6mm 벨트로 어깨축을 구동(표준 벨트 구동).

```
[CARRIAGE_TOP_PLATE]    — J2 상부 608 시트. 선형 베어링 ×3. J2 모터 슬롯 시트 (후방 돌출).
    │ STANDOFFS   (스팬 = 풀리 스택 높이)
[CARRIAGE_BOTTOM_PLATE] — J2 하부 608 시트. 선형 베어링 ×3. 리드넛.
```

| category | part | description |
|---|---|---|
| printed | CARRIAGE_TOP_PLATE | J2 상부 608 시트 + 선형 베어링 ×3 + J2 모터 슬롯 시트(slot seat, 후방 돌출). |
| printed | CARRIAGE_BOTTOM_PLATE | J2 하부 608 시트 + 선형 베어링 ×3 + 리드넛. |
| vitamin | LINEAR_BEARINGS | 가이드 로드용 선형 베어링 ×6 (상·하판 각 3개, 로드 3개) — 캐리지 직선 운동 안내. |
| vitamin | LEADNUT | 리드스크루 맞물림 리드넛 — 회전을 수직 병진으로 변환. |
| vitamin | STANDOFFS | 상·하판 베어링 스팬(bearing span) 확보 — 풀리 스택 높이만큼 이격. |
| vitamin | J2_STEPPER | J2 어깨축 구동 스테퍼 모터 — 슬롯 시트 장착, 전후 이동으로 벨트 장력 조절. |
| vitamin | PULLEY_20T | J2 모터축 20T 구동 풀리(drive pulley). |
| vitamin | PULLEY_60T | 어깨축 60T 종동 풀리 — 3:1 감속(reduction). |
| vitamin | GT2_BELT | 20T↔60T 연결 GT2 6mm 타이밍 벨트. |
| vitamin | AXIS_BEARINGS | 어깨축 608 베어링 ×2 (8×22×7) — 반경/모멘트 하중 지지. |
| vitamin | SHOULDER_BOLT | 어깨축 스택 체결 M6 숄더 볼트. |
| vitamin | LOCK_NUT | SHOULDER_BOLT 풀림 방지 락너트. |

**UPPER_ARM_LINK** — 어깨 관절(shoulder joint) 이후 함께 회전하는 상완 링크(upper arm link). 오픈 프레임으로 J3 팔꿈치축 베어링 스팬 확보. ARM_TOP_PLATE가 J2 hub_pivot에서 STANDARD_JOINT_MOUNT로 체결. J3 구동 모터를 슬롯 시트(slot seat)에 싣고 20T→60T GT2 6mm 벨트로 팔꿈치축을 구동(표준 벨트 구동). FOREARM_LINK와 길이(arm length)만 다르고 동일 설계.

```
[ARM_TOP_PLATE]    — J3 상부 608 시트. J2 mount_pivot (STANDARD_JOINT_MOUNT). J3 모터 슬롯 시트.
    │ STANDOFFS
[ARM_BOTTOM_PLATE] — J3 하부 608 시트.
```

| category | part | description |
|---|---|---|
| printed | ARM_TOP_PLATE | J3 상부 608 시트 + J2 mount_pivot (STANDARD_JOINT_MOUNT) + J3 모터 슬롯 시트(slot seat). |
| printed | ARM_BOTTOM_PLATE | J3 하부 608 시트. |
| vitamin | STANDOFFS | 상·하판 J3 베어링 스팬 확보. |
| vitamin | J3_STEPPER | J3 팔꿈치축 구동 스테퍼 모터 — 슬롯 시트 장착, 전후 이동으로 벨트 장력 조절. |
| vitamin | PULLEY_20T | J3 모터축 20T 구동 풀리. |
| vitamin | PULLEY_60T | 팔꿈치축 60T 종동 풀리 — 3:1 감속(reduction). |
| vitamin | GT2_BELT | 20T↔60T 연결 GT2 6mm 타이밍 벨트. |
| vitamin | AXIS_BEARINGS | J3 팔꿈치축 608 베어링 ×2 (8×22×7). |
| vitamin | ELBOW_BOLT | 팔꿈치축 스택 체결 M6 숄더 볼트. |
| vitamin | LOCK_NUT | ELBOW_BOLT 풀림 방지 락너트. |

**FOREARM_LINK** — 팔꿈치 관절(elbow joint) 이후 함께 회전하는 전완 링크(forearm link). 오픈 프레임으로 J4 손목축 베어링 스팬 확보. FORE_TOP_PLATE가 J3 hub_pivot에서 STANDARD_JOINT_MOUNT로 체결. J4 구동 모터를 슬롯 시트(slot seat)에 싣고 20T→60T GT2 6mm 벨트로 손목축을 구동(표준 벨트 구동). UPPER_ARM_LINK와 길이(arm length)만 다르고 동일 설계.

```
[FORE_TOP_PLATE]    — J4 상부 608 시트. J3 mount_pivot (STANDARD_JOINT_MOUNT). J4 모터 슬롯 시트.
    │ STANDOFFS
[FORE_BOTTOM_PLATE] — J4 하부 608 시트.
```

| category | part | description |
|---|---|---|
| printed | FORE_TOP_PLATE | J4 상부 608 시트 + J3 mount_pivot (STANDARD_JOINT_MOUNT) + J4 모터 슬롯 시트(slot seat). |
| printed | FORE_BOTTOM_PLATE | J4 하부 608 시트. |
| vitamin | STANDOFFS | 상·하판 J4 베어링 스팬 확보. |
| vitamin | J4_STEPPER | J4 손목축 구동 스테퍼 모터 — 슬롯 시트 장착, 전후 이동으로 벨트 장력 조절. |
| vitamin | PULLEY_20T | J4 모터축 20T 구동 풀리. |
| vitamin | PULLEY_60T | 손목축 60T 종동 풀리 — 3:1 감속(reduction). |
| vitamin | GT2_BELT | 20T↔60T 연결 GT2 6mm 타이밍 벨트. |
| vitamin | AXIS_BEARINGS | J4 손목축 608 베어링 ×2 (8×22×7). |
| vitamin | WRIST_BOLT | 손목축 스택 체결 M6 숄더 볼트. |
| vitamin | LOCK_NUT | WRIST_BOLT 풀림 방지 락너트. |

**TOOL_LINK** — 손목 관절(wrist joint) 이후 함께 회전하는 말단 링크(tool link). 오픈 프레임으로 J4 mount_pivot 마운팅. TOOL_FLANGE가 WRIST_BOTTOM_PLATE에 체결되어 엔드 이펙터(end-effector) 인터페이스 제공.

```
[WRIST_TOP_PLATE]    — J4 mount_pivot (STANDARD_JOINT_MOUNT).
    │ STANDOFFS
[WRIST_BOTTOM_PLATE] — TOOL_FLANGE 체결면.
[TOOL_FLANGE]        — 엔드 이펙터 장착 플랜지. WRIST_BOTTOM_PLATE 하면에 체결.
```

| category | part | description |
|---|---|---|
| printed | WRIST_TOP_PLATE | J4 mount_pivot (STANDARD_JOINT_MOUNT). |
| printed | WRIST_BOTTOM_PLATE | TOOL_FLANGE 체결면. |
| printed | TOOL_FLANGE | 엔드 이펙터(end-effector) 장착 플랜지. |
| vitamin | STANDOFFS | 상·하판 간격 확보. |

## 표준 조인트 체결

J2부터 말단까지의 회전 관절은 같은 `STANDARD_JOINT_HUB`와 `STANDARD_JOINT_MOUNT`를 쓴다.
링크 모듈은 이 체결 기준을 따라야 하며, 개별 부품 형상은 이 기준을 깨지 않는 범위에서 바꿀 수 있다.

```text
STANDARD_JOINT_HUB
  applies to: SHOULDER_JOINT (J2), ELBOW_JOINT (J3), WRIST_JOINT (J4)
  role: 회전축을 중심으로 인접 링크를 정렬하고 M3 인서트 체결로 토크를 전달한다.
  features: circular flange, inner-race centering boss, straight keyed pilot boss, symmetric M3 brass insert pattern, axis bore

STANDARD_JOINT_MOUNT
  applies to: UPPER_ARM_LINK, FOREARM_LINK, TOOL_LINK
  role: 링크 모듈 쪽에서 STANDARD_JOINT_HUB를 받아 정렬하고 체결한다.
  features: keyed pilot socket, matching screw clearance holes, M3 screw head counterbores, M6 axis fastener relief, axis bore
```

회전 관절의 `joint hub`는 **standard modular joint flange**로 본다.
즉, 축·베어링·풀리와 링크 모듈 사이에서 동심 정렬, 체결, 방향 기준을 제공하는 표준 인터페이스 부품이다.
외곽은 360도 회전 여유를 해치지 않도록 원형으로 유지하고, 방향 기준은 `keyed pilot boss`와 `keyed pilot socket`의 맞물림으로 강제한다.
허브 쪽 체결 홀은 M3 heat-set brass insert용 블라인드 홀로 두고, 마운트 쪽은 M3 캡스크류 관통 홀과 스크류 머리 카운터보어를 둔다.
스크류 머리는 기본적으로 허브 접촉면의 반대쪽에 묻히도록 배치해 허브 플랜지와 마운트 면이 직접 맞닿게 한다.
숄더 볼트 머리와 락너트용 카운터보어는 표준 허브에 두지 않는다.
M6 숄더 볼트와 락너트는 허브의 축 스택을 직접 조이고, `STANDARD_JOINT_MOUNT`는 socket side 중앙에 `axis fastener relief`를 두어 이 체결부를 피한다.
허브 내측면의 `inner-race centering boss`는 608 내륜만 접촉하도록 하여, 축방향 클램프가 외륜이나 파츠 포켓으로 전달되지 않게 한다.

실존 파츠 기준은 아래 파일에 둔다.

```text
parts/joint_hub.scad  J2부터 말단까지 공유하는 양면 STANDARD_JOINT_HUB
parts/joint_mount.scad  링크 모듈 쪽에서 허브를 받는 STANDARD_JOINT_MOUNT
```

## 표준 벨트 구동

J2·J3·J4 회전 관절은 동일한 벨트 감속 구동(belt reduction drive)을 공유한다.
각 링크는 자신의 원위 관절(distal joint)을 구동하는 모터를 싣는다.

```text
drive: motor 20T -> hub axis 60T   (3:1 reduction)
belt:  GT2 6mm timing belt
mount: 모터 슬롯 시트(slot seat) — 전후로 미끄러뜨려 벨트 장력(belt tension) 조절
applies to:
  SHOULDER_JOINT (J2) <- CARRIAGE_LINK
  ELBOW_JOINT    (J3) <- UPPER_ARM_LINK
  WRIST_JOINT    (J4) <- FOREARM_LINK
```

회전 관절축(revolute axis)은 모두 **608 베어링**(8×22×7)을 상·하 2개로 지지한다. WAIST_JOINT(J0)도 동일.
병진 관절(prismatic, J1)만 선형 베어링(linear bearing)을 쓴다.

UPPER_ARM_LINK와 FOREARM_LINK는 길이(arm length)만 다르고 판재·구동·베어링 구성이 동일하다.

## 피벗 방향

링크의 양끝은 hub를 제공하는 쪽을 `hub_pivot`, mount로 체결하는 쪽을 `mount_pivot`으로 부른다.

```text
[mount_pivot] ── link body ── [hub_pivot]
```

각 링크의 원위(distal) 끝은 자신의 원위 관절(J2~J4)에 `hub_pivot`을 제공하고, 근위(proximal) 끝은 `mount_pivot`으로 이전 링크의 hub를 받는다.

| 관절 | hub_pivot (parent) | mount_pivot (child) |
|---|---|---|
| SHOULDER (J2) | CARRIAGE_LINK 원위 | ARM_TOP_PLATE |
| ELBOW (J3) | UPPER_ARM_LINK 원위 | FORE_TOP_PLATE |
| WRIST (J4) | FOREARM_LINK 원위 | WRIST_TOP_PLATE |

J0 WAIST는 표준 조인트가 아니라 BASE_LINK의 608 저널 구조를 쓰므로 `hub_pivot`/`mount_pivot` 용어를 적용하지 않는다.

## 용어집

| 용어 | 의미 | 사용 기준 |
|---|---|---|
| `joint` | 두 링크를 연결하고 상대 운동을 허용하는 기구학적 관절 | 연결 관계를 표현할 때 사용한다. |
| `axis` | 관절의 병진 방향 또는 회전 중심선 | 운동 방향이나 회전선을 표현할 때 사용한다. |
| `link` | 같은 관절 상태에서 함께 움직이는 실존 부품들의 집합 | 로봇 기구학 모델의 운동 단위로 사용한다. |
| `parts` | 실제 OpenSCAD 부품 또는 조립체 | CAD 파일, 출력 부품, 브래킷, 판재, 샤프트 등에 사용한다. |
| `prismatic` | 직선 병진 관절 | `VERTICAL_JOINT (J1)`에 사용한다. |
| `revolute` | 회전 관절 | `WAIST_JOINT`, `SHOULDER_JOINT`, `ELBOW_JOINT`, `WRIST_JOINT`에 사용한다. |
| `joint hub` | 회전 관절축 주변의 모듈 교환용 표준 플랜지 | 축·베어링·풀리와 링크 모듈을 정렬하고 볼트로 체결한다. |
| `joint mount` | `joint hub`와 체결되는 링크 쪽 수용부 | 링크 모듈이 표준 허브와 호환되도록 하는 장착부이다. |
| `inner-race centering boss` | 608 내륜만 누르는 허브 중앙 보스 | 허브와 베어링 사이 간격을 만들고, 축방향 조임력이 외륜으로 흐르지 않게 한다. |
| `keyed pilot boss` | 방향 키가 붙은 직선 센터링 보스 | 허브가 올바른 각도일 때만 마운트 소켓에 들어가도록 한다. |
| `keyed pilot socket` | 방향 키 형상을 받는 여유 있는 센터링 소켓 | 링크 모듈 쪽에서 허브의 방향과 중심을 동시에 맞춘다. FDM 출력 여유, 입구 relief, 코너 relief를 둔다. |
| `brass insert hole` | M3 heat-set brass insert를 받는 허브 쪽 블라인드 홀 | 나사산을 출력물에 직접 만들지 않고 인서트로 반복 조립성을 확보한다. |
| `counterbore` | 스크류 머리를 묻히는 원통형 자리 | 마운트 바깥쪽에서 캡스크류 머리가 돌출되거나 접촉면에 끼지 않도록 한다. |
| `axis fastener relief` | M6 숄더 볼트 머리 또는 락너트를 피하는 마운트 중앙 포켓 | 허브와 축 체결부가 먼저 성립하고, 마운트는 그 주변에서 허브에 체결되도록 한다. |
| `slot seat` | 전후로 길게 열린 모터 장착 슬롯(slotted seat) | 모터를 미끄러뜨려 벨트 장력(belt tension)을 조절한다. 표준 벨트 구동 J2·J3·J4에 쓴다. |
| `hub_pivot` | 링크가 hub를 제공하는 쪽 끝점 | 다음 링크 방향(tool 쪽)으로 STANDARD_JOINT_HUB 인터페이스를 제공한다. |
| `mount_pivot` | 링크가 mount로 체결하는 쪽 끝점 | 이전 링크 방향(base 쪽)의 STANDARD_JOINT_HUB를 STANDARD_JOINT_MOUNT로 받아 체결한다. |
| `bearing span` | 두 베어링 사이 축방향(axial) 거리 | 스팬이 넓을수록 모멘트 하중(moment load) 저항 증가. 오픈 프레임의 상·하판 간격이 이를 결정한다. |
| `open frame` | 상·하판 + 스탠드오프(standoff)로 구성되는 듀얼 플레이트 구조 | 베어링 스팬 확보와 FDM 무서포트 출력을 동시에 만족한다. |
| `channel` | 측면 벽을 가진 판재 형태 — U자 또는 C자 단면 | 스탠드오프 없이 측벽이 구조 강성과 간격을 동시 제공한다. U-브라켓(U-bracket)이라고도 한다. |
| `fairing` | 내부 부품(베어링·관절 마운트 등)을 덮는 외형·미관 커버 | 기능적 보호보다 외형 마감 목적. 기능적 보호는 `cover`로 구분한다. |
