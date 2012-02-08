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
my $notchspacing = 15;
my $fingerless = 2;
my $margin = 5;
my $fingerwidth = 4;
my $linespacing = 1.5;
my $linegap = 3;
my $kerf = 0;

##

my $oddlinegaps = 3;
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
my $stroke = $kerf || 0.1;

my $dkerf = 2 * $kerf;

$fingerwidth     += $dkerf; $fingerspacing     -= $dkerf;
$fingerholewidth -= $dkerf; $fingerholespacing += $dkerf;
$fingerlength    += $kerf;
$fingerholedepth -= $kerf;
$innerwidth      += $dkerf;
$innerheight     += $dkerf;
$halflength      += $kerf;
$linegap         += $dkerf; $linelength        -= $dkerf;

my $outerlinelength = ($innerwidth - $normallines * $linelength - $evenlinegaps * $linegap) / 2;

$outerlinegap    += $kerf;  $outerlinelength   -= $kerf;

my $halfnotchspacing = $notchspacing / 2;
my $notchless = ($innerlength / 2) - $halfnotchspacing - $fingerholewidth;

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
path { stroke: red; fill: none; stroke-width: ${stroke}mm; }
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

say "h $halfnotchspacing";
say "v -$thickness h $fingerholewidth v $thickness";
say "h $notchless $halfcircum $fingerless";

say "v -$thickness h $fingerholewidth v $thickness h $fingerholespacing"
    for 1..($fingers - 1);
say "v -$thickness h $fingerholewidth v $thickness";

say "h $fingerless $halfcircum $notchless";
say "v -$thickness h $fingerholewidth v $thickness";
say "h $halfnotchspacing";

say "v -$innerwidth";

say "h -$halfnotchspacing";
say "v $thickness h -$fingerholewidth v -$thickness";
say "h -$notchless -$halfcircum -$fingerless";

say "v $thickness h -$fingerholewidth v -$thickness h -$fingerholespacing"
    for 1..($fingers - 1);
say "v $thickness h -$fingerholewidth v -$thickness";

say "h -$fingerless -$halfcircum -$notchless";
say "v $thickness h -$fingerholewidth v -$thickness";
#say "h -$halfnotchspacing";
say "z'/>";


$x = $margin + $halflength;

for (1..2) {
    say "<path d='M $x $y";
    my $lines_x = ceil($halfcircum / $linespacing) + 1;

    for my $x_line (1..$lines_x) {
        if ($x_line % 2) {
            say "m 0 $linegap";
            say "v $linelength m 0 $linegap" for 1..$oddlinegaps-1;
        } else {
            say "v $outerlinelength";
            say "m 0 $outerlinegap";
            say "v $linelength m 0 $linegap" for 1..$evenlinegaps-2;
            say "v $linelength";
            say "m 0 $outerlinegap v $outerlinelength";
        }
        say "";
        say "m $linespacing -$realinnerwidth";
    }
    say "'/>";
    $x += $halfcircum + $innerlength;
}

print <<"END";
</g>
</svg>
END
