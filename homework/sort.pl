#!/usr/bin/env perl
use strict;
use warnings;

foreach my $file (glob "*_record.csv") {
    my %hash;
    print "$file\n";
    open (IN, "< $file") or die;
    foreach (<IN>) {
        chomp;
        my ($id) = split ',';
        $hash{$id} = $_;
    }
    close(IN);
    open (OUT, "> $file") or die;
    foreach my $id (sort {$a<=>$b} keys %hash) {
        print OUT "$hash{$id}\n";
    }
    close(OUT);
}
