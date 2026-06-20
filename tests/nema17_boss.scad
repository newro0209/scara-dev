include <../config.scad>
use <../vitamins/stepper_motors.scad>

linear_extrude(height = seat_shoulder_t)
    difference() {
        offset(delta = seat_shoulder_t + print_clearance) nema17_outline_2d();
        nema17_outline_2d();
    }