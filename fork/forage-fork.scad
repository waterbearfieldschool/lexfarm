// ---------------------------------------------------------------------------
// Forage fork  --  a sawbuck-style browse rack for goats
//
// Two X-frames ("crosses") made from 2x4s. Branches lie in the V-trough above
// the crossings, cradled by 1x4 rails run along the inside faces of the arms.
// A 2x4 wedged into the gap BELOW the crossings stops the X from scissoring.
//
// Units: INCHES.  Lumber is nominal-named but modelled at actual sizes.
//
// The two primary parameters are:
//   cross_angle  -- the included angle of the X where the legs cross
//   fork_height  -- finished height, ground to the top of the arms
// ---------------------------------------------------------------------------

/* [Primary] */

// Included angle between the two legs of each cross (degrees).
// Small = tall narrow V; large = wide splayed V.
cross_angle = 60;      // [20:5:80]

// Finished height, ground to top of the arms (inches).
fork_height = 34;      // [24:1:48]

/* [Secondary] */

// Overall length of the rack, outside face to outside face of the end frames.
fork_length = 60;

// Where the legs cross, as a fraction of the total height.
// Larger = crossing sits higher = shallower trough, narrower stance.
cross_frac = 0.5;      // [0.35:0.01:0.8]

// Half-lap the crossing (notch both legs flush) instead of bolting
// the boards face-to-face. Face-to-face is easier to build.
half_lap = false;

/* [Cradle rails] */

// The upper pair sits level, near the tops of the arms. The inset is measured
// from the top of the arm, down along the board, to the rail's upper edge.
upper_rail_inset = 2;

// The lower pair is staggered rather than level. Sliding a rail down its arm
// carries it toward the vertex, where the narrowing V pinches it -- and two
// rails at the same height jam against each other at the centreline before
// either gets near the crook. Dropping them one at a time gets both much
// lower: the first seats when its inner corner lands on the opposite leg,
// and the second comes to rest on the first one's exposed face.
//
// These lift each rail back up its arm from where it seats.
crook_rail_lift  = 0;
second_rail_lift = 0;

/* [Stop block] */

// A 2x4 running the length of the rack, below the crossings. Each cross is a
// single bolt -- a hinge -- so without this the frame is free to scissor.
//
// It lies with a wide face flat against the underside of the two INNER legs,
// parallel to them, and its square-cut ends butt the inside surfaces of the
// two OUTER legs. So it lands on both boards of both crosses, which is what
// triangulates the hinge.
stop_block = true;

// How far to slide the stop down the inner leg from its seated position. At 0
// its ends sit square on the outer legs. Sliding it down gives a wider, and so
// stiffer, triangle, but the legs diverge as you go down and the ends quickly
// stop landing on anything.
stop_drop = 0;         // [0:0.5:12]

/* [Display] */

show_branches = false;

// Shade the boards by stock rather than by part: every 2x4 gray, every 1x4
// white. Reads on a black-and-white printout, where the usual timber colours
// all come out the same grey.
shade_by_stock = false;

/* [Hidden] */

// Actual dressed lumber dimensions
LEG_T = 1.5;   LEG_W = 3.5;    // 2x4
RAIL_T = 0.75; RAIL_W = 3.5;   // 1x4

BIG = 1000;    // trim-solid size
EXT = 8;       // how far to overshoot before trimming ends

// Part colours. In shade_by_stock mode the stop joins the legs, because it is
// a 2x4 like them -- the point is to show the stock, not the part.
SHADE_2X4 = "gray";
SHADE_1X4 = "white";

col_leg  = shade_by_stock ? SHADE_2X4 : "burlywood";
col_rail = shade_by_stock ? SHADE_1X4 : "tan";
col_stop = shade_by_stock ? SHADE_2X4 : "peru";
col_wood = shade_by_stock ? "darkgray" : "olivedrab";

// ---------------------------------------------------------------------------
// Derived geometry
// ---------------------------------------------------------------------------

a   = cross_angle / 2;              // each leg's tilt from vertical
H   = fork_height;
h_x = cross_frac * H;               // height of the crossing point

arm_len  = (H - h_x) / cos(a);      // crossing -> top, along the board
foot_len = h_x / cos(a);            // crossing -> ground, along the board

frame_t = half_lap ? LEG_T : 2 * LEG_T;   // thickness of one X-frame

// Height at which the two inner faces meet: the actual bottom of the trough.
v_vertex = h_x + LEG_W / (2 * sin(a));

// Below the crossing the legs swap sides and the gap between them widens
// downward. Its apex, directly under the crossing, mirrors the trough vertex.
lower_apex = h_x - LEG_W / (2 * sin(a));

// The stop lies on the inner leg's underside face, so work in that leg's own
// frame: local x is measured off the leg's face, local z runs along the board
// from the crossing. Laid on its wide face, the stop is LEG_T proud of the
// leg and covers LEG_W along it.
//
// Sliding the stop along the inner leg sweeps its square end across the outer
// leg's cross-section. The two legs meet at 2a, so the end presents this much
// width measured across the outer leg:
stop_end_width = LEG_T * cos(2 * a) + LEG_W * sin(2 * a);

// Centre the end on the outer leg, so as much of it as possible bears on that
// leg. That butt joint is what "connects" the two, and it lands just under the
// crossing -- further down the legs diverge and the end meets nothing at all.
stop_seat_z = (LEG_W * sin(2 * a) - (LEG_W + LEG_T) * cos(2 * a))
              / (2 * sin(2 * a));

// How much of the end actually lands on the outer leg. The end is wider than
// a 2x4 once the cross angle opens up much past 40 deg, so this saturates.
stop_bearing = min(stop_end_width, LEG_W);

stop_z_local = stop_seat_z - stop_drop;
stop_length  = fork_length - 2 * LEG_T;

// Global height of the stop's highest and lowest corners.
stop_high_z = h_x - (LEG_W / 2) * sin(a) + stop_z_local * cos(a);
stop_low_z  = h_x - (LEG_W / 2 + LEG_T) * sin(a)
                  + (stop_z_local - LEG_W) * cos(a);

// Rail positions along the board, measured from the crossing.
upper_rail_z = arm_len - RAIL_W / 2 - upper_rail_inset;

// How far a rail's inner face stands off its own leg's centreline.
RAIL_REACH = LEG_W / 2 + RAIL_T;

// Seating the staggered lower pair. Going between the two arms' frames is a
// rotation by 2a in the (x, z) plane, which turns each contact into a one-line
// solve. The first rail's lower inner corner lands on the opposite leg's inner
// face; the second's lands on the first rail's inner face, one RAIL_T further
// into the V, which is what holds it a little higher.
crook_rail_z  = RAIL_W / 2 + crook_rail_lift
                + (LEG_W / 2 + RAIL_REACH * cos(2 * a)) / sin(2 * a);
second_rail_z = RAIL_W / 2 + second_rail_lift
                + RAIL_REACH * (1 + cos(2 * a)) / sin(2 * a);

// How far a rail on one arm reaches toward the centreline. Two rails set level
// with each other collide when this goes negative.
function rail_inner_x(z_local) = -RAIL_REACH * cos(a) + z_local * sin(a);

// Height of a rail's lowest corner.
function rail_low_z(z_local) = h_x + (LEG_W / 2) * sin(a)
                                   + (z_local - RAIL_W / 2) * cos(a);

upper_rail_gap  = 2 * rail_inner_x(upper_rail_z);
crook_gap       = upper_rail_z - crook_rail_z  - RAIL_W;   // along the +1 arm
second_gap      = upper_rail_z - second_rail_z - RAIL_W;   // along the -1 arm
crook_rail_h    = rail_low_z(crook_rail_z);
second_rail_h   = rail_low_z(second_rail_z);

leg_stock  = H / cos(a) + LEG_W * tan(a);   // long-point length of one leg
// The outer legs finish flush with the ends of the rack; the inner legs are
// set in by one board thickness. Each rail is cut to its own leg so both pairs
// finish flush rather than one running past.
rail_stock_outer = fork_length;
rail_stock_inner = half_lap ? fork_length : fork_length - 2 * LEG_T;

foot_spread = 2 * h_x * tan(a) + LEG_W / cos(a);   // outside of foot to outside
top_spread  = 2 * (H - h_x) * tan(a) + LEG_W / cos(a);

// ---------------------------------------------------------------------------
// Parts
// ---------------------------------------------------------------------------

// One leg, overshooting both ends (trimmed later by the ground/top planes).
// dir = +1 leans toward +x going up;  dir = -1 leans toward -x.
module leg_solid(dir, y0) {
    translate([0, y0, h_x])
        rotate([0, dir * a, 0])
            translate([-LEG_W / 2, 0, -(foot_len + EXT)])
                cube([LEG_W, LEG_T, foot_len + arm_len + 2 * EXT]);
}

// A leg, half-lapped at the crossing if requested.
module leg(dir, y0) {
    difference() {
        leg_solid(dir, y0);
        if (half_lap)
            intersection() {
                leg_solid(-dir, y0);
                // keep only the far half of the board's thickness
                translate([-BIG / 2,
                           dir > 0 ? y0 + LEG_T / 2 : y0 + LEG_T / 2 - BIG,
                           -BIG / 2])
                    cube(BIG);
            }
    }
}

// One end frame. `flip` puts the +1 leg on the outboard side, so that on
// both frames the same-leaning boards share a plane and the rails land flat.
module end_frame(y0, flip = false) {
    y_pos = half_lap ? y0 : (flip ? y0 + LEG_T : y0);
    y_neg = half_lap ? y0 : (flip ? y0 : y0 + LEG_T);
    leg(+1, y_pos);
    leg(-1, y_neg);
}

// A 1x4 lying flat against the inside face of one leg, running the length of
// the rack. The +1 leg's inside face is its local -x face, hence face = -dir.
module rail_on_leg(dir, z_local) {
    // dir = +1 lands on the outer legs, dir = -1 on the inner ones
    len = (dir > 0) ? rail_stock_outer : rail_stock_inner;
    translate([0, 0, h_x])
        rotate([0, dir * a, 0])
            translate([-dir * (LEG_W / 2 + RAIL_T / 2),
                       fork_length / 2,
                       z_local])
                cube([RAIL_T, len, RAIL_W], center = true);
}

module rails() {
    rail_on_leg(+1, upper_rail_z);
    rail_on_leg(-1, upper_rail_z);
    rail_on_leg(+1, crook_rail_z);      // down in the crook
    rail_on_leg(-1, second_rail_z);     // resting on top of it
}

// The 2x4 that stops the cross from scissoring. Built in the inner (-1) leg's
// own frame so it lands flat on that leg's underside face, and cut to length
// so its square ends butt the inside surfaces of the two outer legs.
module stop() {
    translate([0, 0, h_x])
        rotate([0, -a, 0])
            translate([-LEG_W / 2 - LEG_T, LEG_T, stop_z_local - LEG_W])
                cube([LEG_T, stop_length, LEG_W]);
}

// ---------------------------------------------------------------------------
// Assembly
// ---------------------------------------------------------------------------

module trimmed() {
    difference() {
        children();
        translate([0, 0, -BIG / 2]) cube([BIG, BIG, BIG], center = true);   // ground
        translate([0, 0, H + BIG / 2]) cube([BIG, BIG, BIG], center = true); // top
    }
}

module forage_fork() {
    color(col_leg)
        trimmed() {
            end_frame(0);
            end_frame(fork_length - frame_t, flip = true);
        }

    color(col_rail) rails();

    if (stop_block) color(col_stop) stop();
}

// Rough branches resting in the trough, for scale/intent only.
module branches() {
    floor_z = v_vertex;
    stack = [[ 0.0, 2.4, 4.0],
             [-3.4, 5.6, 3.0],
             [ 3.6, 6.4, 3.2],
             [ 0.4, 9.6, 2.6],
             [-2.6, 12.2, 2.0]];
    color(col_wood, 0.85)
        for (b = stack)
            translate([b[0], -6, floor_z + b[1]])
                rotate([-90, 0, 0])
                    cylinder(h = fork_length + 20, d = b[2], $fn = 12);
}

forage_fork();
if (show_branches) branches();

// ---------------------------------------------------------------------------
// Cut list and clearance checks
// ---------------------------------------------------------------------------

echo(str("== Forage fork =================================="));
echo(str("  cross angle .......... ", cross_angle, " deg"));
echo(str("  height ............... ", H, " in"));
echo(str("  length ............... ", fork_length, " in"));
echo(str("  crossing height ...... ", h_x, " in"));
echo(str("  trough bottom ........ ", v_vertex, " in"));
echo(str("  stance (foot to foot) . ", foot_spread, " in"));
echo(str("  top opening .......... ", top_spread, " in"));
echo(str("-- cut list ------------------------------------"));
echo(str("  4 x  2x4  legs   @ ", leg_stock, " in long point,",
         " both ends cut at ", a, " deg off square"));
echo(str("  2 x  1x4  rails  @ ", rail_stock_outer, " in (on the outer legs)"));
echo(str("  2 x  1x4  rails  @ ", rail_stock_inner, " in (on the inner legs)"));
if (stop_block)
    echo(str("  1 x  2x4  stop   @ ", stop_length, " in, square ends"));
echo(str("  joint at crossing: ", half_lap ? "half-lap" : "face-to-face, bolted"));
if (shade_by_stock)
    echo(str("  shading: gray = 2x4 (legs + stop), white = 1x4 (rails)"));
echo(str("-- clearances ----------------------------------"));
echo(str("  between the two upper rails ..... ", upper_rail_gap, " in"));
echo(str("  crook rail bottoms out at ....... ", crook_rail_h,
         " in (trough vertex is at ", v_vertex, ")"));
echo(str("  second rail rests at ............ ", second_rail_h, " in"));
echo(str("  clear arm above crook rail ...... ", crook_gap, " in"));
echo(str("  clear arm above second rail ..... ", second_gap, " in"));
if (stop_block) {
    echo(str("  stop spans ", stop_low_z, " to ", stop_high_z,
             " in above ground (crossing is at ", h_x, ")"));
    echo(str("  stop end bears ", stop_bearing, " in of its ",
             stop_end_width, " in width on the outer leg"));
}
if (upper_rail_gap <= 0)
    echo("  *** WARNING: the two upper rails run into each other.",
         " Reduce upper_rail_inset, or open up cross_angle.");
if (crook_gap <= 0 || second_gap <= 0)
    echo("  *** WARNING: a lower rail overlaps the upper rail on its arm.",
         " Increase upper_rail_inset, or lift the lower rail less.");
if (stop_block && stop_low_z <= 0)
    echo("  *** WARNING: the stop reaches the ground.",
         " Reduce stop_drop, or raise cross_frac.");
echo(str("================================================"));
