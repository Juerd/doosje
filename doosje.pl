#!/usr/bin/perl -w

use strict;
use v5.14;
my $pi = 3.1415926;

print <<END;
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" 
  "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg xmlns="http://www.w3.org/2000/svg" version="1.1"
 width="350mm" height="210mm" viewBox="0 0 350 210">
<style type="text/css">
path { stroke: red; fill: none; }
</style>
END

# millimeters
my $innerheight = 40;
my $innerlength = 84;
my $innerwidth = 59;
my $thickness = 2;
my $fingerless = 2;
my $margin = 5;
my $fingerwidth = 4;


my $notchgap = 3 * $fingerwidth;
my $halfnotchgap = $notchgap / 2;
my $notchless = ($innerlength - $notchgap - 2 * $fingerwidth) / 2;

my $fingers = int(($innerlength - 2 * $fingerless) / $fingerwidth / 2);


$fingerless = ($innerlength - (2 * $fingers - 1) * $fingerwidth) / 2;

my $fingerspacing = $fingerwidth;
my $radius = $innerheight / 2;
my $circum = $pi * $innerheight;
my $halfcircum = $circum / 2;

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

$x = $margin + 0;
$y = $margin + $innerheight + 2 * $thickness + $margin;

say "<path d='M $x $y";
say "v $innerwidth";

say "h $halfnotchgap";
say "v -$thickness h $fingerwidth v $thickness";
say "h $notchless $halfcircum $fingerless";

say "v -$thickness h $fingerwidth v $thickness h $fingerspacing"
    for 1..($fingers - 1);
say "v -$thickness h $fingerwidth v $thickness";

say "h $fingerless $halfcircum $notchless";
say "v -$thickness h $fingerwidth v $thickness";
say "h $halfnotchgap";

say "v -$innerwidth";

say "h -$halfnotchgap";
say "v $thickness h -$fingerwidth v -$thickness";
say "h -$notchless -$halfcircum -$fingerless";

say "v $thickness h -$fingerwidth v -$thickness h -$fingerspacing"
    for 1..($fingers - 1);
say "v $thickness h -$fingerwidth v -$thickness";

say "h -$fingerless -$halfcircum -$notchless";
say "v $thickness h -$fingerwidth v -$thickness";
#say "h -$halfnotchgap";
say "z'/>";


print <<END;
"/>
</svg>
END
