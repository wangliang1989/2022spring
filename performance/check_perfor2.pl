#!/usr/bin/env perl
use strict;
use warnings;

my %hash;
foreach my $file (glob "../homework/*_record.txt") {
    open (IN, "< $file") or die;
    foreach (<IN>) {
        my ($id, $name, $class, @info) = split m/\s+/;
        $hash{$id} = 0;
        foreach (@info) {
            $hash{$id}++ if $_ >= 0;
        }
    }
    close(IN);
}
open (OUT, "> perfor4.txt") or die;
foreach my $file (glob "perfor2*.txt") {
    open (IN, "< $file") or die;
    foreach (<IN>) {
        my ($id, $name, $class, @info) = split m/\s+/;
        my $num = 0;
        $num = @info if defined($info[0]);
        my $i = $hash{$id} - 2 - $num;
        next if $i <= 0;
        print OUT "$id $name $class";
        while ($i > 0){
            print OUT " 85";
            $i--;
        }
        print OUT "\n";
    }
    close(IN);
}
close(OUT);
