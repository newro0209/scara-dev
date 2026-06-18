# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

SCARA 로봇 암. **3D 프린팅(FDM)** 제작, 기성품(NopSCADlib vitamin) 최대화.

설계 특성:
- SCARA 기구학 모델: 수직 병진(J1) + 어깨·팔꿈치·손목 회전(J2·J3·J4). 상세는 [SCARA_KINEMATICS.md](SCARA_KINEMATICS.md).
- 3D 프린팅이라 리세스·카운터보어·압입 시트(press-fit seat)를 자유롭게 쓴다.

## 기구 체인 메모

→ [SCARA_KINEMATICS.md](SCARA_KINEMATICS.md)

조립체·부품 명명은 해당 문서의 운동 체인을 기준으로 맞춘다.

## 컨벤션 우선순위

구조·스타일은 **(1) NopSCADlib 실제 구조 → TBD. 충돌하면 NopSCADlib가 이긴다.

## 파일 구조

```
config.scad        공통 사양값, 공차, 렌더 해상도;
vitamins/          NopSCADlib에 없는 로컬 vitamin — 패밀리당 한 파일로 NopSCADlib 패밀리 미러링
  screws.scad        로컬 M6_shoulder_screw (NopSCADlib screw 패밀리에 추가)
  pulleys.scad       로컬 GT2x60x8_pulley (NopSCADlib pulley 패밀리에 추가)
parts/             제작 부품 (NopSCADlib printed/ 대응) — 2D 프로파일 + 압출/포켓을 한 모듈에
  base_link.scad     로봇 베이스 링크 — BASE_LINK printed parts에 해당하는 모듈들과 접근자들
SCARA_KINEMATICS.md SCARA 기구학 모델과 명명 기준
docs/              BOM, reference images
main.scad          전체 로봇
```

## 워크플로우

TBD

## 의존성

NopSCADlib 설치 필요:
```bash
git clone https://github.com/nophead/NopSCADlib.git \
  "$HOME/Documents/OpenSCAD/libraries/NopSCADlib"
```

**이 머신 실제 설치 경로:** `C:\Program Files\OpenSCAD\libraries\NopSCADlib`

## 핵심 구조 규약

### vitamins/ 규약 (MUST)

프로젝트 `vitamins/`에는 NopSCADlib에 없는 로컬 vitamin만 둔다. NopSCADlib이 제공하는 vitamin은 래핑하지 않고 직접 include/use한다(예: `NEMA(NEMA17_40)`).

로컬 타입은 **NopSCADlib 패밀리-당-한-파일을 미러링**한다: `vitamins/pulleys.scad`가 `include <NopSCADlib/vitamins/pulleys.scad>` 후 같은 스키마로 타입을 추가한다(경로가 달라 가림 충돌 없음). 새 접근자가 필요 없으면 NopSCADlib 접근자(`pulley_*`, `screw_*`)를 그대로 쓴다.

### config.scad

공차, 렌더 해상도, 공통 레이아웃 값(`component_margin`, `seat_shoulder_thickness`, `fillet_r`)등을 관리한다. 특정 부품 패밀리의 치수·타입은 해당 파일에서 관리한다.

## OpenSCAD 코딩 컨벤션

TBD
