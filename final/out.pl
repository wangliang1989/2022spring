#!/usr/bin/env perl
use strict;
use warnings;

foreach (glob "考试成绩_*.txt") {
    my ($class_name) = split m/\./;
    ($class_name) = (split '_', $class_name)[-1];
    my @ids;
    my %students;
    my %kaoshi;
    my %zuoye;
    my %kaoqing;
    my %biaoxian;
    open (IN, "< $_") or die;
    foreach (<IN>) {
        next if $_ =~ '姓名';
        my (undef, $id, $name, $class, $score) = split m/\s+/;
$score = 0;
        push @ids, $id;
        $students{$id} = "$name $class";
        $kaoshi{$id} = $score;
    }
    close(IN);
    open (IN, "< ../homework/作业成绩_$class_name.csv") or die;
    foreach (<IN>) {
        next if $_ =~ '姓名';
        my (undef, $id, $name, $class, @scores) = split m/\s+/;
        $zuoye{$id} = $scores[-1];
    }
    close(IN);
    open (IN, "< ../rollcall/$class_name.csv") or die;
    foreach (<IN>) {
        chomp;
        next if $_ =~ '姓名';
        my (undef, $id, $name, $class, @scores) = split ',';
        $kaoqing{$id} = $scores[-1];
    }
    close(IN);
    open (IN, "< ../performance/课堂表现_$class_name.txt") or die;
    foreach (<IN>) {
        next if $_ =~ '姓名';
        my ($id, $name, $class, @scores) = split m/\s+/;
        $biaoxian{$id} = $scores[-1];
    }
    close(IN);
    open (OUT, "> 成绩_$class_name.txt") or die;
    my $j = 0;
    print OUT "序号 学号 姓名 班级 作业 表现 考勤 平时 考试 成绩\n";
    foreach my $id (@ids) {
        $j++;
        my $pingshi = int($zuoye{$id} * 0.4 + $biaoxian{$id} * 0.4 + $kaoqing{$id} * 0.2 + 0.5);
        my $score = int($kaoshi{$id} * 0.7 + $pingshi * 0.3);
        my $deadline = int((60 - $pingshi * 0.3) / 70 * 100 + 1);
        print OUT "$j $id $students{$id} $zuoye{$id} $biaoxian{$id} $kaoqing{$id} $pingshi $kaoshi{$id} $score\n";
        print "$j $id $students{$id} $deadline\n";
    }
    close(OUT);
}
