/*
 * profile.scad - 공통 2D 프로파일(profile) 헬퍼
 */

module apply_fillet(fillet_r)
{
	offset(r = -fillet_r) offset(delta = fillet_r)
		children();
}