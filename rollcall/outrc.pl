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
             '早退', 3,
             );
my %log = ('缺勤', '✗',
             '事假', '☐',
             '病假', '✚',
             '早退', '△',
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
# 输出考勤成绩
foreach (glob "../list/*_official.csv") {
    my ($csv) = (split m/\//)[-1];
    my ($class) = split '_', $csv;
    open (IN, "< $_") or die;
    open (OUT, "> $class.csv") or die;
    my $txt = ',';
    for (my $i = 1; $i<=32; $i++) {
        $txt = "$txt$i,";
    }
    my $j = 0;
    print OUT "序号,学号,姓名,班级${txt}总评\n";
    foreach (<IN>) {
        next if $_ =~ '姓名';
        my @info = split ",";
        my ($id, $name, $class) = ($info[2], $info[3], $info[8]);
        my $txt = ',';
        for (my $i = 1; $i<=32; $i++) {
            my $out = '✓';
            foreach (@data) {
                my @info = split m/\s+/;
                my ($id1, $name1, $class1, @info1) = @info;
                next unless $id1 eq $id;
                foreach (@info1) {
                    my ($day, $eq) = split "-";
                    next unless $day == $i;
                    $out = $log{$eq} unless $eq eq '事假（疫情）';#按照教务处要求，疫情不做考虑
                }
            }
            $txt = "$txt$out,";
        }
        my ($score, $num) = (100, 32);
        foreach (@data) {
            my @info = split m/\s+/;
            my ($id1, $name1, $class1, @info1) = @info;
            next unless $id1 == $id;
            foreach (@info1) {
                my ($day, $eq) = split "-";
                next if $eq eq '事假（疫情）';#按照教务处要求，疫情不做考虑
                $num = $num - 1 if $event{$eq} == 0; # 减少考察次数
            }
            foreach (@info1) {
                my ($day, $eq) = split "-";
                next if $eq eq '事假（疫情）';#按照教务处要求，疫情不做考虑
                $score = $score - (100 / $num) if $event{$eq} == 1; # 扣分
                $score = $score - (100 / $num) * 0.5 if $event{$eq} == 3; # 扣分
            }
        }
        $score = int ($score + 0.5);
        $j++;
        print OUT "$j,$id,$name,$class$txt$score\n";
    }
    close(IN);
    close(OUT);
}
