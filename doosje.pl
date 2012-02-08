#!/usr/bin/perl -w

use strict;
use v5.14;
use POSIX qw(ceil);
my $pi = 3.1415926;


# millimeters

my $innerheight = 40;
my $innerlength = 100;
my $innerwidth = 80;
my $thickness = 2;
my $fingerless = 2;
my $margin = 5;
my $fingerwidth = 4;
my $linespacing = 1.5;
my $linegap = 3;
my $kerf = 0.1;

##

my $fingerspacing = $fingerwidth;

my $fingerholewidth = $fingerwidth;
my $fingerholespacing = $fingerspacing;

my $halflength = $innerlength / 2;

$fingerwidth     += $kerf; $fingerspacing     -= $kerf;
$fingerholewidth -= $kerf; $fingerholespacing += $kerf;
$innerwidth      += $kerf;
$innerheight     += $kerf;
$halflength      += $kerf;
$linegap         += $kerf;

my $linegaps = 3;
my $notchgap = 3 * $fingerwidth;
my $halfnotchgap = $notchgap / 2;
my $notchless = $halflength - ($notchgap - 2 * $fingerwidth) / 2;

my $fingers = int(($innerlength - 2 * $fingerless) / $fingerwidth / 2);

$fingerless = ($innerlength - (2 * $fingers - 1) * $fingerwidth) / 2;

my $radius = $innerheight / 2;
my $circum = $pi * $innerheight;
my $halfcircum = $circum / 2;

print <<"END";
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" 
  "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg xmlns="http://www.w3.org/2000/svg" version="1.1"
 width="350mm" height="210mm" viewBox="0 0 350 210">
<style type="text/css">
path { stroke: red; fill: none; stroke-width: ${kerf}mm; }
</style>
END

my $x = $margin + $notchless + $fingerwidth + $radius;
my $y = $margin + $thickness;

for (1..2) {
    say "<path d='M $x $y";
    say "v -$thickness h -$fingerwidth v $thickness";
    say "h -$notchless";

    say "a $radius $radius 0 0,0 0 $innerheight";

    say "h $fingerless";
    say "v $thickness h $fingerwidth v -$thickness h $fingerspacing"
        for 1..($fingers - 1);
    say "v $thickness h $fingerwidth v -$thickness";
    say "h $fingerless";

    say "a $radius $radius 0 0,0 0 -$innerheight";

    say "h -$notchless";
    say "v -$thickness h -$fingerwidth v $thickness";

    say "z'/>";

    $x += $innerheight + $innerlength + $margin;
}

say "<g>";
$x = $margin + 0;
$y = $margin + $innerheight + 2 * $thickness + $margin;

say "<path d='M $x $y";
say "v $innerwidth";

say "h $halfnotchgap";
say "v -$thickness h $fingerholewidth v $thickness";
say "h $notchless $halfcircum $fingerless";

say "v -$thickness h $fingerholewidth v $thickness h $fingerholespacing"
    for 1..($fingers - 1);
say "v -$thickness h $fingerholewidth v $thickness";

say "h $fingerless $halfcircum $notchless";
say "v -$thickness h $fingerholewidth v $thickness";
say "h $halfnotchgap";

say "v -$innerwidth";

say "h -$halfnotchgap";
say "v $thickness h -$fingerholewidth v -$thickness";
say "h -$notchless -$halfcircum -$fingerless";

say "v $thickness h -$fingerholewidth v -$thickness h -$fingerholespacing"
    for 1..($fingers - 1);
say "v $thickness h -$fingerholewidth v -$thickness";

say "h -$fingerless -$halfcircum -$notchless";
say "v $thickness h -$fingerholewidth v -$thickness";
#say "h -$halfnotchgap";
say "z'/>";


$x = $margin + $halflength;

for (1..2) {
    say "<path d='M $x $y";
    my $lines_x = ceil($halfcircum / $linespacing) + 1;

    for my $x_line (1..$lines_x) {
        my $linelength = ($innerwidth - $linegaps * $linegap) / ($linegaps - 1);
        if ($x_line % 2) {
            say "m 0 $linegap";
            say "v $linelength m 0 $linegap" for 1..$linegaps-1;
        } else {
            my $gaps = $linegaps - 1;
            my $normallines = $gaps - 1;
            my $outerlinelength = ($innerwidth - $normallines * $linelength - $gaps * $linegap) / 2;
            say "v $outerlinelength";
            say "m 0 $linegap";
            say "v $linelength m 0 $linegap" for 1..$gaps-1;
            say "v $outerlinelength";
        }
        say "";
        say "m $linespacing -$innerwidth";
    }
    say "'/>";
    $x += $halfcircum + $innerlength;
}

print <<"END";
</g>
</svg>
END
