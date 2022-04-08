#!/usr/bin/env perl
use strict;
use warnings;

foreach (glob "*_out.csv") {
    my ($name) = split '_';
    print "$name\n";
    open (IN, "< $_") or die;
    my @data = <IN>;
    close(IN);
    my $th = 0;
    foreach (@data) {
        next if $_ =~ '姓名';
        chomp;
        my (undef, undef, undef, @info) = split ',';
        my $up = 0;
        foreach (@info) {
            $up++ unless ",$_," eq ",,";
        }
        $th = $up if $th < $up;
    }
    foreach (@data) {
        next if $_ =~ '姓名';
        chomp;
        my (undef, undef, undef, @info) = split ',';
        my $up = 0;
        foreach (@info) {
            $up++ unless ",$_," eq ",,";
        }
        print "$_\n" if $th > $up;
    }
}
