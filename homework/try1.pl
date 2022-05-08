#!/usr/bin/env perl
use strict;
use warnings;

my %data;
foreach (glob "../performance/jg.*.txt") {
    open (IN, "< $_") or die;
    foreach (<IN>) {
        chomp;
        my ($name, $id, $num, $time, $score) = split m/\s+/;
        $data{"$id $num"} = $score unless defined($data{"$id $num"});
        $data{"$id $num"} = $score if $data{"$id $num"} < $score;
    }
    close(IN);
}
foreach my $file (glob "*_record.csv") {
    open (IN, "< $file") or die;
    my @records = <IN>;
    close(IN);
    open (OUT, "> $file") or die;
    foreach (@records) {
        chomp;
        my ($id, $name, $class, @scores) = split m/\s+/;
        foreach (keys %data) {
            my ($id1, $num) = split m/\s+/;
            my $score = $data{$_};
            next unless $id == $id1;

            #$scores[$num-1] = 0 unless defined($scores[$num-1]);
            $scores[$num-1] = "$scores[$num-1].$score" unless $score == 85;
        }
        print OUT "$id $name $class @scores\n";
    }
    close(OUT);
}
