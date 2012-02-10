#!/usr/bin/perl -w

use strict;
use v5.14;
use POSIX qw(ceil);
use List::Util qw(max);
my $pi = 3.1415926;

# All these are in millimeters:

my $innerheight  = 33;    # Inner height; nothing special
my $innerlength  = 56;    # Inner length excluding half circles on the sides
my $innerwidth   = 89;    # Inner width of the box, between the two walls
my $thickness    =  2;    # Material thickness

my $notchspacing = 15;    # Space between the lid notches
my $fingerless   =  2;    # Space between "fingers" and half circle
my $margin       =  3;    # Margin between page boundary and between objects
my $fingerwidth  =  4;    # Width of the "fingers"
my $linespacing  =  1.5;  # Space between parallel flex lines (centre to centre)
my $linegap      =  3;    # Space between flex lines
my $kerf         =  0.03; # Cutting loss. Set to 0 if you don't know the kerf,
                          # to get the regular loose fit. Increase for a more
                          # tight fit. The kerf is typically less than 0.1 mm.
##

my $oddlinegaps = 4;      # Number of uncut gaps between the flex lines
my $extrawalls = 1;       # 0 or 1: extra vertical walls on the hinge sides?

##
my $radius = $innerheight / 2;
my $circum = $pi * $innerheight;
my $halfcircum = $circum / 2;

warn sprintf(
    "Outer dimensions of the box will be %d x %d x %d (L x W x H).\n",
    2 * $thickness + $innerlength + 2 * $radius + 2 * $extrawalls * $thickness,
    2 * $thickness + $innerwidth,
    2 * $thickness + $innerheight,
);

my $notchwidth = $fingerwidth;  # no kerf compensation, we want the looser fit
my $outerwidth = $innerwidth + 2 * $thickness;
my $fingerspacing = $fingerwidth;
my $fingerholewidth = $fingerwidth;
my $fingerholespacing = $fingerspacing;
my $fingerlength = $thickness;
my $fingerholedepth = $fingerlength;
my $halflength = $innerlength / 2;
my $outerlinegap = $linegap;
my $evenlinegaps = $oddlinegaps - 1;
my $normallines = $evenlinegaps - 1;
#my $realinnerwidth = $innerwidth;
my $realinnerlength = $innerlength;
my $stroke = $kerf || 0.1;
my $fingers = int(($realinnerlength - 2 * $fingerless) / $fingerwidth / 2);
$fingerless = ($realinnerlength - (2 * $fingers - 1) * $fingerwidth) / 2;
my $fingerholeless = $fingerless;

my $dkerf = 2 * $kerf;

$fingerwidth     += $dkerf; $fingerspacing     -= $dkerf;
$fingerholewidth -= $dkerf; $fingerholespacing += $dkerf;
$fingerlength    += $kerf;
$fingerholedepth -= $kerf;
$fingerholeless  += $kerf;
$outerwidth      += $dkerf;
$innerheight     += $dkerf;
$innerlength     += $dkerf;
$halflength      += $kerf;
$linegap         += $dkerf;

my $linelength = ($outerwidth - $oddlinegaps * $linegap) / ($oddlinegaps - 1);
my $outerlinelength = ($outerwidth - $normallines * $linelength - $evenlinegaps * $linegap) / 2;

#$linelength -= $dkerf;
#$outerlinelength -= $kerf;


my $halfnotchspacing = $notchspacing / 2;
my $notchless     = ($innerlength / 2) - $halfnotchspacing - $notchwidth;


warn sprintf(
    "Sheet size must be at least %d x %d.\n",
    my $sheetwidth = ceil(
        $extrawalls
        ? 4 * $margin + 2 * $innerheight + 2 * $innerlength + 6 * $thickness
          + $innerwidth # upper part
        : 2 * $margin + 2 * $innerlength + $circum  # part with hinges
    ),
    my $sheetheight = ceil(
        3 * $margin + $innerheight + 2 * $fingerlength + $outerwidth
    ),
);

print <<"END";
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" 
  "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg xmlns="http://www.w3.org/2000/svg" version="1.1"
 width="${sheetwidth}mm" height="${sheetheight}mm"
 viewBox="0 0 ${sheetwidth} ${sheetheight}">
END

# With CSS, inkscape forgets the properties on copy/paste
my $attr = qq[fill="none" stroke="red" stroke-width="${stroke}mm"];
my ($x, $y);

say "<g>";  # Grouping makes moving things around in Inkscape easier

# Draw flex lines first to avoid focus issues
# See http://www.thingiverse.com/thing:14267

$x = $margin + $halflength + $extrawalls * $thickness;
$y = $margin + $innerheight + 2 * $thickness + $margin;

for (1..2) {
    # Draw from outside in, to ensure symmetry
    my $xdir = $_ == 2 ? "-" : "";
    my $ydir = "-";

    say "<path $attr d='M $x $y";
    my $lines_x = ceil($halfcircum / $linespacing);

    for my $x_line (1..$lines_x) {
        $ydir = $ydir ? "" : "-";
        if ($x_line % 2) {
            say "m 0 $ydir$linegap";
            say "v $ydir$linelength m 0 $ydir$linegap" for 1..$oddlinegaps-1;
            say "m $xdir$linespacing 0";
        } else {
            say "v $ydir$outerlinelength";
            say "m 0 $ydir$linegap";
            say "v $ydir$linelength m 0 $ydir$linegap" for 1..$normallines;
            say "v $ydir$outerlinelength";
            say "m $xdir$linespacing 0";
        }
    }
    say "'/>";
    $x += $circum + $realinnerlength + $extrawalls * 2 * $thickness if $_ == 1;
}

# Then, draw the finger holes for the extra walls

if ($extrawalls) {
    my $hx = $margin + $halflength + $halfcircum + $thickness;
    my $hy = $y + ($outerwidth - $fingerholewidth) / 2;
    for (1..2) {
        say "<path $attr d='M $hx $hy";
        say "h $thickness v $fingerholewidth h -$thickness v -$fingerholewidth";
        say "'/>";
        $hx += $realinnerlength + $thickness;
    }
}

# Next, draw the big part around the flex lines.

$x = $margin + 0;

say "<path $attr d='M $x $y";

# WEST
say "v $outerwidth";

# SOUTH: West lid, with notch hole
say "h $halfnotchspacing";
say "v -$fingerholedepth h $fingerholewidth v $fingerholedepth";
say "h $notchless";
say "h $thickness" if $extrawalls;

# SOUTH: West hinge
say "h $halfcircum";

# SOUTH: Finger holes
say "h $thickness" if $extrawalls;
say "h $fingerholeless";
say "v -$fingerholedepth h $fingerholewidth v $fingerholedepth h $fingerholespacing"
    for 1..($fingers - 1);
say "v -$fingerholedepth h $fingerholewidth v $fingerholedepth";
say "h $fingerholeless";
say "h $thickness" if $extrawalls;

# SOUTH: East hinge
say "h $halfcircum";

# SOUTH: East lid, with notch hole
say "h $thickness" if $extrawalls;
say "h $notchless";
say "v -$fingerholedepth h $fingerholewidth v $fingerholedepth";
say "h $halfnotchspacing";

# WEST
say "v -$outerwidth";

# NORTH: East lid, with notch hole
say "h -$halfnotchspacing";
say "v $fingerholedepth h -$fingerholewidth v -$fingerholedepth";
say "h -$notchless";
say "h -$thickness" if $extrawalls;

# NORTH: East hinge
say "h -$halfcircum";

# NORTH: Finger holes
say "h -$thickness" if $extrawalls;
say "h -$fingerholeless";
say "v $fingerholedepth h -$fingerholewidth v -$fingerholedepth h -$fingerholespacing"
    for 1..($fingers - 1);
say "v $fingerholedepth h -$fingerholewidth v -$fingerholedepth";

say "h -$fingerholeless";
say "h -$thickness" if $extrawalls;

# NORTH: West hinge
say "h -$halfcircum";

# NORTH: West lid, with notch hole
say "h -$thickness" if $extrawalls;
say "h -$notchless";
say "v $fingerholedepth h -$fingerholewidth v -$fingerholedepth";
say "h -$halfnotchspacing" if 0;  # not needed but useful for debugging
say "z'/>";

say "</g>";


# Draw walls

$x = $margin + $innerlength + $radius + $extrawalls * 2 * $thickness;
$y = $margin + $thickness;

for (1..2) {
    # Finger holes for the extra walls. Cut first because of material drop.
    if ($extrawalls) {
        say "<g>";
        my $hx = $x - $innerlength - $extrawalls * 2 * $thickness;
        my $hy = $y + ($innerheight - $fingerholewidth) / 2;
        for (1..2) {
            say "<path $attr d='M $hx $hy";
            say "h $thickness v $fingerholewidth h -$thickness v -$fingerholewidth";
            say "'/>";
            $hx += $realinnerlength + $thickness;
        }
    }

    say "<path $attr d='M $x $y";

    # TOP: Lid notches and lid beds
    say "h -$thickness" if $extrawalls;
    say "h -$notchless";
    say "v -$fingerlength h -$notchwidth v $fingerlength";
    say "h -$notchspacing";
    say "v -$fingerlength h -$notchwidth v $fingerlength";
    say "h -$notchless";
    say "h -$thickness" if $extrawalls;

    # LEFT: Hinge arc
    say "a $radius $radius 0 0,0 0 $innerheight";

    # BOTTOM: Fingers
    say "h $thickness" if $extrawalls;
    say "h $fingerless";
    say "v $fingerlength h $fingerwidth v -$fingerlength h $fingerspacing"
        for 1..($fingers - 1);
    say "v $fingerlength h $fingerwidth v -$fingerlength";
    say "h $fingerless";
    say "h $thickness" if $extrawalls;

    # RIGHT: Hinge arc
    say "a $radius $radius 0 0,0 0 -$innerheight";

    # Close path
    say "z'/>";
    
    say "</g>" if $extrawalls;

    $x += $innerheight + $innerlength + $margin + 2 * $extrawalls * $thickness;
}

$x = $sheetwidth - $margin - $fingerlength;

for (1..$extrawalls * 2) {
    my $transform = "";
    if ($_ == 2) {
        $x = 2 * $margin + 2 * $innerlength + 4 * $thickness + $circum;
        $y = 2 * $margin + $innerheight + 3 * $thickness;
        $transform = qq[transform="rotate(-90,$x,$y)"];
    }

    say "<path $attr $transform d='M $x $y";

    # TOP
    say "h -$innerwidth";

    # LEFT: one finger
    my $halfside = ($innerheight - $fingerwidth) / 2;
    say "v $halfside";
    say "h -$fingerlength v $fingerwidth h $fingerlength";
    say "v $halfside";
    
    # BOTTOM: one finger
    my $halfbottom = ($innerwidth - $fingerwidth) / 2;
    say "h $halfbottom";
    say "v $fingerlength h $fingerwidth v -$fingerlength";
    say "h $halfbottom";

    # RIGHT: one finger
    say "v -$halfside";
    say "h $fingerlength v -$fingerwidth h -$fingerlength";
    say "v -$halfside" if 0;  # not needed but useful for debugging

    # Close path
    say "z'/>";

    # $x += $innerwidth + 2 * $fingerwidth + $margin;
}

say "</svg>";
