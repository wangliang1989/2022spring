#!/usr/bin/env perl
use strict;
use warnings;

foreach (glob "*.xlsx") {
    my ($name) = split m/\./;
    print "$_ -> $name.csv\n";
    system "xlsx2csv $_ $name.csv";
}
