#!/usr/bin/env perl
use strict;
use warnings;

foreach (glob "../homework/作业成绩*") {
    my ($name) = (split m/\//)[-1];
    ($name) = split m/\./, $name;
    system "cupsfilter $_ > $name.pdf";
}
system "cupsfilter ../rollcall/kaoqing.txt > 考勤.pdf";
foreach (glob "../performance/课堂表现*") {
    my ($name) = (split m/\//)[-1];
    ($name) = split m/\./, $name;
    system "cupsfilter $_ > $name.pdf";
}
