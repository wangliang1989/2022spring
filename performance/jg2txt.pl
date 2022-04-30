#!/usr/bin/env perl
use strict;
use warnings;

foreach my $file (glob "jg.*.csv") {
    my %times;
    my %scores;
    open (IN, "< $file") or die;
    foreach (<IN>) {
        #骆秋英 2130823054 4 2022-04-17T10:37:56 85
        my ($name, $id, $num, $origin, $score) = split m/\s+/;
        next if $num <= 2;
        my ($time) = origin2sec($origin);
        if(defined($times{"$name $id $num"})){
            $times{"$name $id $num"} = $time if $times{"$name $id $num"} > $time;
        }else{
            $times{"$name $id $num"} = $time;
        }
        if(defined($scores{"$name $id $num"})){
            $scores{"$name $id $num"} = $score if $times{"$name $id $num"} < $score;
        }else{
            $scores{"$name $id $num"} = $score;
        }
    }
    close(IN);
    $file =~ s/csv/txt/g;
    open (OUT, "> $file") or die;
    print OUT "$_ $times{$_} $scores{$_}\n" foreach (keys %times);
    close(OUT);
}
sub origin2sec {
    use Time::Local;
    my @out;
    foreach (@_) {
        my ($date, $time) = split "T";
        my ($year, $mon, $day) = split "-", $date;
        my ($hour, $min, $sec) = split ":", $time;
        my $t = timegm($sec, $min, $hour, $day, $mon, $year);
        push @out, $t;
    }
    return @out;
}
