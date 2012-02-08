#!/usr/bin/perl -w

use strict;
use v5.14;
use POSIX qw(ceil);
use List::Util qw(max);
my $pi = 3.1415926;

# All these are in millimeters:

my $innerheight  = 40;    # Inner height; nothing special
my $innerlength  = 80;    # Inner length excluding half circles on the sides
my $innerwidth   = 60;    # Inner width of the box, between the two walls
my $thickness    =  2;    # Material thickness

my $notchspacing = 15;    # Space between the lid notches
my $fingerless   =  2;    # Space between "fingers" and half circle
my $margin       =  5;    # Margin between page boundary and between objects
my $fingerwidth  =  4;    # Width of the "fingers"
my $linespacing  =  1.5;  # Space between parallel flex lines (centre to centre)
my $linegap      =  3;    # Space between flex lines
my $kerf         =  0.1;  # Cutting loss. Set to 0 if you don't know the kerf,
                          # to get the regular loose fit. Increase for a more
                          # tight fit. The kerf is typically much less than
                          # 0.5 mm.
##

my $oddlinegaps = 3;      # Number of uncut gaps between the flex lines

##
my $radius = $innerheight / 2;
my $circum = $pi * $innerheight;
my $halfcircum = $circum / 2;

warn sprintf(
    "Outer dimensions of the box will be %d x %d x %d (L x W x H).\n",
    2 * $thickness + $innerlength + 2 * $radius,
    2 * $thickness + $innerwidth,
    2 * $thickness + $innerheight,
);

my $fingerspacing = $fingerwidth;
my $fingerholewidth = $fingerwidth;
my $fingerholespacing = $fingerspacing;
my $fingerlength = $thickness;
my $fingerholedepth = $fingerlength;
my $halflength = $innerlength / 2;
my $outerlinegap = $linegap;
my $linelength = ($innerwidth - $oddlinegaps * $linegap) / ($oddlinegaps - 1);
my $evenlinegaps = $oddlinegaps - 1;
my $normallines = $evenlinegaps - 1;
my $realinnerwidth = $innerwidth;
my $realinnerlength = $innerlength;
my $stroke = $kerf || 0.1;

my $dkerf = 2 * $kerf;

$fingerwidth     += $dkerf; $fingerspacing     -= $dkerf;
$fingerholewidth -= $dkerf; $fingerholespacing += $dkerf;
$fingerlength    += $kerf;
$fingerholedepth -= $kerf;
$innerwidth      += $dkerf;
$innerheight     += $dkerf;
$innerlength     += $dkerf;
$halflength      += $kerf;
$linegap         += $dkerf;

my $outerlinelength = ($innerwidth - $normallines * $linelength - $evenlinegaps * $linegap) / 2;

$linelength      -= $dkerf;


my $halfnotchspacing = $notchspacing / 2;
my $notchless = ($innerlength / 2) - $halfnotchspacing - $fingerholewidth;

my $fingers = int(($realinnerlength - 2 * $fingerless) / $fingerwidth / 2);

$fingerless = ($realinnerlength - (2 * $fingers - 1) * $fingerwidth) / 2;


warn sprintf(
    "Sheet size must be at least %d x %d.\n",
    my $sheetwidth = ceil(
        ceil(2 * $margin + 2 * $innerlength + $circum),
    ),
    my $sheetheight = ceil(
        3 * $margin + $innerheight + 2 * $fingerlength + $innerwidth
    ),
);

print <<"END";
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" 
  "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg xmlns="http://www.w3.org/2000/svg" version="1.1"
 width="${sheetwidth}mm" height="${sheetheight}mm"
 viewBox="0 0 ${sheetwidth} ${sheetheight}">
<style type="text/css">
path { stroke: red; fill: none; stroke-width: ${stroke}mm; }
</style>
END

my ($x, $y);

say "<g>";  # Grouping makes moving things around in Inkscape easier

# Draw flex lines first to avoid focus issues
# See http://www.thingiverse.com/thing:14267

$x = $margin + $halflength;
$y = $margin + $innerheight + 2 * $thickness + $margin;

for (1..2) {
    say "<path d='M $x $y";
    my $lines_x = ceil($halfcircum / $linespacing) + 1;

    for my $x_line (1..$lines_x) {
        if ($x_line % 2) {
            say "m 0 $linegap";
            say "v $linelength m 0 $linegap" for 1..$oddlinegaps-1;
            say "m $linespacing -$realinnerwidth";
        } else {
            say "v $outerlinelength";
            say "m 0 $linegap";
            say "v $linelength m 0 $linegap" for 1..$normallines;
            say "v $outerlinelength";
            say "m $linespacing -$innerwidth";
        }
    }
    say "'/>";
    $x += $halfcircum + $realinnerlength;
}

# Next, draw the big part around the flex lines.

$x = $margin + 0;

say "<path d='M $x $y";

# WEST
say "v $innerwidth";

# SOUTH: West lid, with notch hole
say "h $halfnotchspacing";
say "v -$fingerholedepth h $fingerholewidth v $fingerholedepth";
say "h $notchless";

# SOUTH: West hinge
say "h $halfcircum";

# SOUTH: Finger holes
say "h $fingerless";
say "v -$fingerholedepth h $fingerholewidth v $fingerholedepth h $fingerholespacing"
    for 1..($fingers - 1);
say "v -$fingerholedepth h $fingerholewidth v $fingerholedepth";
say "h $fingerless";

# SOUTH: East hinge
say "h $halfcircum";

# SOUTH: East lid, with notch hole
say "h $notchless";
say "v -$fingerholedepth h $fingerholewidth v $fingerholedepth";
say "h $halfnotchspacing";

# WEST
say "v -$innerwidth";

# NORTH: East lid, with notch hole
say "h -$halfnotchspacing";
say "v $fingerholedepth h -$fingerholewidth v -$fingerholedepth";
say "h -$notchless";

# NORTH: East hinge
say "h -$halfcircum";

# NORTH: Finger holes
say "h -$fingerless";
say "v $fingerholedepth h -$fingerholewidth v -$fingerholedepth h -$fingerholespacing"
    for 1..($fingers - 1);
say "v $fingerholedepth h -$fingerholewidth v -$fingerholedepth";

say "h -$fingerless";

# NORTH: West hinge
say "h -$halfcircum";

# NORTH: West lid, with notch hole
say "h -$notchless";
say "v $fingerholedepth h -$fingerholewidth v -$fingerholedepth";
say "h -$halfnotchspacing" if 0;  # not needed but useful for debugging
say "z'/>";

say "</g>";


# Draw walls

$x = $margin + $notchless + $fingerwidth + $radius;
$y = $margin + $thickness;

for (1..2) {
    say "<path d='M $x $y";

    # TOP: Left lid notch and lid bed
    say "v -$fingerlength h -$fingerwidth v $fingerlength";
    say "h -$notchless";

    # LEFT: Hinge arc
    say "a $radius $radius 0 0,0 0 $innerheight";

    # BOTTOM: Fingers
    say "h $fingerless";
    say "v $fingerlength h $fingerwidth v -$fingerlength h $fingerspacing"
        for 1..($fingers - 1);
    say "v $fingerlength h $fingerwidth v -$fingerlength";
    say "h $fingerless";

    # RIGHT: Hinge arc
    say "a $radius $radius 0 0,0 0 -$innerheight";

    # TOP: Right lid notch and lid bed
    say "h -$notchless";
    say "v -$fingerlength h -$fingerwidth v $fingerlength";

    # Close path
    say "h -$notchspacing" if 0;  # not needed but useful for debugging
    say "z'/>";

    $x += $innerheight + $innerlength + $margin;
}

say "</svg>";
