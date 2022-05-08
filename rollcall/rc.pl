#!/usr/bin/env perl
use strict;
use warnings;

my $num0 = 32;
my %event = ('事假（自请）', 2,
             '缺勤', 1,
             '事假（参军）', 0,
             '事假（疫情）', 0,
             '病假', 0,
             '事假', 0,
             );
open (IN, "< rollcall.txt") or die;
my @data;
foreach (<IN>) {
    chomp;
    my ($id, $name, $class) = split m/\s+/;
    my $i = 0;
    foreach my $file (glob "../list/*_official.csv") {
        open (IN1, "< $file") or die;
        foreach (<IN1>) {
            $i = 1 if $_ =~ $id;
            last if $i == 1;
        }
        close (IN1);
        last if $i == 1;
    }
    push @data, $_ if $i == 1;
    print "$id $name $class 不在教务处名单中\n" if $i == 0;
}
close (IN);

# 检查是否有无法处理的情况
my %errs;
foreach (@data) {
    my @info = split m/\s+/;
    my ($id, $name, $class, @info1) = @info;
    foreach (@info1) {
        my ($day, $eq) = split "-";
        $errs{$eq} = 0 unless defined$event{$eq};
    }
}
my $err = 0;
foreach (keys %errs) {
    print "无法处理的记录: $_\n";
    $err++;
}
die if $err > 0;
# 检查考勤成绩
open (OUT, "> kaoqing.txt") or die;
foreach (@data) {
    chomp;
    my $score = 100;
    my $absence = 0;
    my $strip = 0;
    my $shijia = 0;
    my $bingjia = 0;
    my $num = $num0;
    my @info = split m/\s+/;
    my ($id, $name, $class, @info1) = @info;
    foreach (@info1) {
        my ($day, $eq) = split "-";
        next if $eq eq '事假（疫情）';#按照教务处要求，疫情不做考虑
        $num = $num - 1 if $event{$eq} == 0; # 减少考察次数
    }
    foreach (@info1) {
        my ($day, $eq) = split "-";
        next if $eq eq '事假（疫情）';#按照教务处要求，疫情不做考虑
        $score = $score - (100 / $num) if $event{$eq} == 1; # 扣分
        $absence++ if $event{$eq} == 1;
        $strip++ if $event{$eq} == 2;
        $shijia++ if $eq eq '事假';
        $bingjia++ if $eq eq '病假';
    }
    $score = int ($score + 0.5);
    print OUT "$id $name $class 缺勤 $absence 次, 事假 $shijia 次, 病假 $bingjia 次, 考勤分数为 $score\n" if $absence + $bingjia + $shijia > 0;
    print OUT "$id $name $class 需要补假条 $strip 次\n" if $strip > 0;
}
print OUT "其余同学100分\n";
close(OUT);
