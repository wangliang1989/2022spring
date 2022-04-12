#!/usr/bin/env perl
use strict;
use warnings;

foreach (glob "../homework/*_out.csv") {
    my ($name) = (split m/\//)[-1];
    ($name) = split m/\./, $name;
    system "cupsfilter $_ > $name.pdf";
}
system "cupsfilter ../rollcall/kaoqing.txt > 考勤.pdf";
