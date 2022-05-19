#!/usr/bin/env perl
use strict;
use warnings;

foreach (glob "作业成绩*") {
    next if $_ =~ '应电';
    open (IN, "< $_") or die;
    my @data = <IN>;
    close(IN);
    my $th = 0;
    foreach (@data) {
        next if $_ =~ '姓名';
        chomp;
        my (undef, undef, undef, @info) = split m/\s+/;
        my $i = @info;
        foreach (@info) {
            $i-- if $_ < 0;
        }
        print "$_\n" if $i < 4;
    }
}
