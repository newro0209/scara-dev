# AGENTS.md

이 문서는 이 저장소에서 Codex, Claude Code 등 코드 에이전트가 작업할 때 따라야 할 기준을 정리한다.

## 1. 작업 원칙

- 저장소의 기존 구조와 명명 규칙을 먼저 확인한 뒤 수정한다.
- 기구 설계 의도, 조립 기준, 제작 가능성을 코드 스타일보다 우선한다.
- OpenSCAD 컴파일 성공만으로 완료하지 않고, 형상 의도와 조립 관계가 맞는지 함께 확인한다.
- 관련 없는 리팩터링, 파일 이동, 명명 변경은 사용자가 명시적으로 요청하지 않는 한 피한다.

## 2. 프로젝트 개요

이 저장소는 **3D 프린팅(FDM)** 중심으로 제작하는 SCARA 로봇 암을 다룬다.

### 2.1 설계 특성

- SCARA 기구학(kinematics) 모델은 수직 병진(prismatic translation, J1) + 어깨·팔꿈치·손목 회전(revolute rotation, J2·J3·J4) 구조를 따른다.
- 상세한 기구 체인(kinematic chain), 관절(joint), 좌표계(coordinate frame), 명명 기준은 [SCARA_KINEMATICS.md](SCARA_KINEMATICS.md)를 따른다.
- 3D 프린팅(FDM) 제작 특성을 활용해 리세스(recess), 카운터보어(counterbore), 압입 시트(press-fit seat), 숄더(shoulder) 같은 형상을 적극 사용한다.

## 3. 문서와 주석 언어

### 3.1 기본 언어

- 문서와 코드 주석은 **한국어**를 기본으로 작성한다.
- 기구학(kinematics), CAD, 기계공학(mechanical engineering), 전기전자공학(electrical and electronic engineering) 계열의 전문 용어(term)는 반드시 **한국어(영어)** 형식으로 병기한다.
- 사용자가 지정한 명명 체인, 용어 순서, 이중 언어 표현은 임의로 의역하거나 재배열하지 않는다.

### 3.2 전문 용어 병기 예시

- 순기구학(forward kinematics)
- 역기구학(inverse kinematics)
- 좌표계(coordinate frame)
- 리세스(recess)
- 카운터보어(counterbore)
- 압입 시트(press-fit seat)
- 외륜 숄더(outer-race shoulder)
- 내륜(inner race)
- 축방향 하중(axial load)

## 4. OpenSCAD 주석 규칙

OpenSCAD 모듈(module) 내부 주석은 단순 명칭만 적지 말고, 해당 구조가 어떤 기계 원리(mechanical principle)로 쓰이는지 설명한다.

- 주석은 **한국어**로 작성한다.
- 기계공학(mechanical engineering) 관련 전문 용어는 반드시 **한국어(영어)** 형식으로 병기한다.
- 주석 형식은 **`대상 용어(구) — 역할/이유(절)`** 구조를 따른다.
- 역할/이유에는 접촉(contact), 지지(support), 하중 전달(load transfer), 간섭 회피(interference avoidance), 조립 기준(assembly reference) 등 실제 설계 의도를 설명한다.
- 모든 줄에 주석을 달지 말고, 기계 원리나 조립 의도가 드러나야 하는 블록에 집중한다.

```scad
// 외륜 숄더(outer-race shoulder) — 내륜(inner race) 바깥에서만 축방향(axial direction)으로 받쳐, 회전하는 내륜(inner race)과 실드(shield)를 건드리지 않는다.
```

## 5. 컨벤션 우선순위

구조와 스타일이 충돌할 때는 아래 순서를 따른다.

1. [SCARA_KINEMATICS.md](SCARA_KINEMATICS.md)의 기구 체인과 명명 기준
2. 이 문서의 저장소 규칙
3. 파일 내부의 기존 로컬 스타일

## 6. 파일 구조

```text
config.scad          공통 사양값, 공차(tolerance), 렌더 해상도(render resolution)
vitamins/            로컬 기성품(component) 모델
  screws.scad          로컬 M6_shoulder_screw
  pulleys.scad         로컬 GT2x60x8_pulley
parts/               제작 부품(printed part)
  base_link.scad       로봇 베이스 링크(base link) 제작 부품 모듈
SCARA_KINEMATICS.md  SCARA 기구학(kinematics) 모델과 명명 기준
docs/                BOM, reference images
main.scad            전체 로봇 조립체(assembly)
```

## 7. 핵심 구조 규약

### 7.1 vitamins/ 규약

- `vitamins/`에는 로컬 기성품(component) 모델만 둔다.
- 파일은 **부품 종류-당-한-파일 구조**(예: `screws.scad`, `pulleys.scad`)를 따른다.
- 기성품은 시각화(visualization)용이므로 **Z 브레이크포인트(Z breakpoint) 방식**으로 최대한 최적화해 작성한다. 기준 구현은 [vitamins/stepper_motors.scad](vitamins/stepper_motors.scad)이다.
  - 회전 대칭(rotationally symmetric) 형상은 `[r, z]` 브레이크포인트 윤곽선 하나를 단일 `rotate_extrude`로 돌려 솔리드를 만든다 — 원기둥(cylinder)을 여러 개 `union`하지 않는다.
  - 비회전(non-round) 형상은 Z 구간(segment)별 단면을 `linear_extrude`로 쌓아 CSG 연산 수를 최소화한다.
  - 목표는 부품을 알아볼 수 있는 실루엣(silhouette)을 **최소 연산(minimal CSG)**으로 표현하는 것이다.
- 기성품은 **제네릭 모듈(generic module)** 하나(예: `ball_bearing(bore_d, od, w)`, `gt2_pulley(teeth, bore_d, hub_d, hub_h)`)로 형상을 정의하고, **표준 변형(convenience)** 모듈이 그 위에 규격별 **리터럴(literal)**을 직접 넘긴다(예: `module bearing_608() { ball_bearing(8, 22, 7); }`). 표준 변형에만 쓰는 규격 치수는 별도 사양 상수(`b608_*` 등)로 빼두지 않는다.
- 규격에 따라 달라지는 치수(프레임·피치·보어 등)는 반드시 **제네릭 모듈의 모듈 파라미터(module parameter)**로 받는다 — 특정 규격 값을 모듈 안에 리터럴로 하드코딩(hardcode)하면 그 규격 전용이 되어 다른 규격(NEMA11·17·23 등)을 못 만든다. 규격이 여러 단계로 나뉘면 변형을 계층화한다(예: 제네릭 `stepper_motor(...)` → 규격 래퍼 `nema17(body_l)` → 모델 `stepper_sf2424()`). 규격과 무관한 cosmetic 비율(인셋·분할 수 등)만 모듈 내부 파생 변수로 둔다.
- 아직 쓰지 않는 헬퍼(helper)·접근자(accessor)·규격 테이블(spec table)을 미리 만들지 않는다. 필요한 변형이 생길 때 추가한다.
- 빌드 헬퍼(build helper)는 최상위(top-level)에 두지 말고 제네릭 모듈 안에 **중첩 모듈(module-in-module)**로 두거나, 부품을 **단일 모듈(single module)**로 작성한다. 파일은 제네릭 모듈 + 표준 변형 + (필요시) 순수 함수만 노출한다.
- 회전 대칭 솔리드는 **가능한 한 단일 `rotate_extrude`**로 만든다. 색상(color)이 갈리는 솔리드만 별도 `rotate_extrude`로 나눈다.
- 따로 만든 두 솔리드가 **딱 맞닿으면**(적층 구간 경계, 면에 얹는 마커 등) 동일면(coincident face) z-파이팅이 생긴다. `config.scad`의 `eps`(=1/128)만큼 겹치게 한다 — 맞닿는 솔리드를 `eps` 늘리거나 마커를 `eps` 파묻는다.
- 주의(注): `rotate_extrude` 솔리드를 `difference`로 깎으면 OpenCSG **미리보기(F5)**에서 보이지 않을 수 있다 — 검증은 `--render`(CGAL, F6) 또는 STL 출력으로 한다.

### 7.2 config.scad 규약

`config.scad`는 공차(tolerance), 렌더 해상도(render resolution), 공통 레이아웃(layout) 값(`layout_margin`, `seat_shoulder_t`, `eps`)을 관리한다.

특정 부품 종류(part type)의 치수(dimension)는 해당 파일에서 관리한다.

## 8. OpenSCAD 코딩 컨벤션

- 모든 코드 파일(`.scad`)은 **리눅스 커널 코딩 스타일(Linux kernel coding style)**을 따른다. 기준 템플릿은 [parts/column_link.scad](parts/column_link.scad)이다.
  - 들여쓰기(indentation)는 **탭(tab)**, 8칸 폭 기준.
  - 모듈(module)·함수(function) 정의의 여는 중괄호(`{`)는 **다음 줄**에 둔다.
  - 식별자(identifier)는 `snake_case`. CamelCase 금지.
  - 블록 주석(block comment)은 `/* ... */`, 여러 줄이면 각 줄 앞에 ` *`를 둔다.
  - 한 줄은 약 80칸(column) 이내로 유지한다.
  - 파일 최상위 전역 상수(global constant) 선언은 탭으로 값 열을 정렬한다.
- OpenSCAD 값 이름은 아래 용어를 엄밀히 구분해 설명한다.
  - **전역 상수(global constant)**: 파일 최상위에서 선언한 값. 파일 전체의 공통 기준값이다.
  - **사양 상수(spec constant)**: 기성품(vitamin)의 카탈로그·실측 원치수처럼 외부 사양에서 온 전역 상수이다.
  - **피처 상수(feature constant)**: 제작 부품(printed part)에 실제로 생성되는 보어(bore), 홀(hole), 카운터보어(counterbore), 볼트 서클(bolt circle), 시트(seat) 같은 피처(feature)의 전역 상수이다.
  - **모듈 파라미터(module parameter)**: `module foo(x)`처럼 모듈(module) 호출자가 넘기는 입력값이다. 규격에 따라 달라지는 치수는 제네릭 모듈(generic module)의 모듈 파라미터로 받는다.
  - **바인딩(binding)**: `let(x = ...)` 또는 `for (i = ...)`처럼 표현식(expression) 안에서 임시로 묶인 이름이다.
  - **파생 변수(derived variable)**: 모듈 내부 또는 제한된 스코프(scope)에서 다른 값으로 계산한 지역값이다.
  - **리터럴(literal)**: `8`, `22`, `"red"`처럼 이름 없이 직접 쓴 숫자·문자열 값이다.
- 모듈(module)은 가능한 한 한 가지 제작 부품(printed part) 또는 조립 단위(assembly unit)를 표현한다.
- 2D 프로파일(profile), 압출(extrusion), 포켓(pocket), 체결부(fastener feature)는 의도가 드러나도록 논리 블록(logical block)으로 나눈다.
- 좌표와 각도는 가능하면 기구 체인(kinematic chain)의 상대 위치(relative position)와 상대 각도(relative angle)가 드러나도록 구성한다.
- 부품(part)의 치수 이름은 그 자리에 들어갈 기성품(vitamin)이 아니라, 부품에 실재하는 **피처(feature)** 기준으로 짓는다. 제작 형상에 쓰는 값은 **피처 상수(feature constant)**로 두고, 값은 그 피처가 수용하는 기성품의 **사양 상수(spec constant)**에서 정한다. 예: 숄더 볼트 머리를 받는 중앙 리세스는 `joint_head_recess_d`(피처 상수), 값 = `13`(M6 숄더 볼트 머리 사양 상수 또는 리터럴 수치). `shoulder_bolt_head_d`처럼 기성품 이름으로 피처 상수를 짓지 않는다.
- 파일 상단의 전역 상수는 **기성품 사양(vitamin spec)**과 **피처 사양(feature spec)**을 분리해 배치한다. 기성품 사양에는 카탈로그·실측 기반 원치수인 **사양 상수**(예: `nema17_boss_d`, `kfl08_bolt_pitch_d`, `fc8_bolt_circle_d`)만 둔다. 피처 사양에는 제작 부품에 실제로 적용되는 보어·클리어런스·볼트 패턴·파생 치수인 **피처 상수**를 둔다. 같은 값이라도 제작 형상에 쓰면 `*_bore_d`, `*_hole_d`, `*_bolt_circle_d`처럼 역할 중심 피처 상수로 다시 받는다.
- 평판형(plate·disk) 부품이나 짝을 이루는 부품들이 **외형·홀 패턴을 공유**하면, 홀 지름을 모듈 파라미터로 받는 **공유 2D 프로파일 모듈**(예: `joint_disk_2d(bolt_hole_d)`)로 단일 출처(single source)를 만들고, 이를 Z층으로 `linear_extrude` 적층해 피처를 구성한다. 홀별 `difference`를 따로 쌓지 않는다. 기준 구현은 [parts/joint_hub.scad](parts/joint_hub.scad)·[parts/joint_mount.scad](parts/joint_mount.scad)이다.
  - **블라인드 홀(blind hole)**: 홀 관통 압출 + (두께 − 깊이)만큼의 솔리드 플러그 층을 함께 배치해 바닥을 메운다.
  - **단차 카운터보어(stepped counterbore)**: 큰 홀 지름 층(바깥·깊이)과 작은 홀 지름 층(나머지)을 쌓아 단차를 만든다.
  - 맞물리는 형상(키 보스↔소켓 등)도 2D 단면 모듈 하나(예: `keyed_2d`)를 양형·음형으로 공유해 항상 일치시킨다.
- 모듈 내부 주석은 이 문서의 **4. OpenSCAD 주석 규칙**을 따른다.
- 디버그 출력(`echo`)은 리눅스 커널 `pr_debug("%s: ...", __func__)` 스타일을 따른다 — `함수명: key=val key=val` 형식. 공백으로 구분하고, 콤마·마침표·`=` 좌우 공백을 넣지 않는다. 예: `echo(str("top_guide_plate: plate_t=", plate_t, " insert_h=", insert_hole_h));`
- 전역 상수, 피처 상수, 사양 상수, 모듈 파라미터, 바인딩, 파생 변수 이름의 접미사(suffix)는 아래 단축어(abbreviation)를 사용한다.

| 접미사 | 의미 |
|---|---|
| `_t` | 두께(thickness) |
| `_h` | 높이(height) |
| `_d` | 지름(diameter) |
| `_r` | 반지름(radius) |
| `_w` | 너비(width) |
| `_l` | 길이(length) |
| `_n` | 개수(count) |
