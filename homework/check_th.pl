#!/usr/bin/env perl
use strict;
use warnings;

my $th = 6;
my ($week) = @ARGV;
die unless defined $week;
my $dir = "/Users/liang/坚果云/作业上交/$week";
die unless -d $dir;
my @review;
foreach (glob "$dir/*") {
    next if $_ =~ '.xlsx';
    my ($zuoye) = (split m/\//)[-1];
    my ($id) = split '-', $zuoye;
    push @review, $id;
}
my %classes;
my @data;
foreach (glob "作业成绩*") {
    next if $_ =~ '应电';
    open (IN, "< $_") or die;
    foreach (<IN>) {
        next if $_ =~ '姓名';
        chomp;
        my ($id, $name, $class) = split m/\s+/;
        $classes{$class} = 0;
        push @data, $_;
    }
    close(IN);
}
open (OUT, "> junk.txt") or die;
foreach my $key (sort {$a cmp $b} keys %classes) {
    print OUT "$key\n";
    my $buhege = 0;
    my $hege = 0;
    foreach (@data) {
        my ($id, $name, $class, @info) = split m/\s+/;
        next unless $class eq $key;
        my $i = 0;
        foreach (@info) {
            $i++ if $_ >= 0;
        }
        if ($i < $th) {
            $buhege++;
            my $bl = 0;
            foreach (@review) {
                $bl++ if $_ eq $id;
            }
            print OUT "$_ 未改作业：$bl\n";
        }else{
            $hege++;
        }
    }
    print OUT "合格人数：$hege 不合格人数：$buhege\n\n";
}
close(OUT);
system "cupsfilter junk.txt > a.pdf";
system "cat junk.txt";
unlink "junk.txt";
