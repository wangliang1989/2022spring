#!/usr/bin/env perl
use strict;
use warnings;

my $all = 0;
my $zonggong = 0;
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
    foreach my $info (<IN>) {
        next if $info =~ '姓名';
        $info =~ s/^\s+|\s+$//g;
        my (undef, $id, $name, $class, $score) = split m/\s+/, $info;
        $score = -12345 unless defined $score;
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
        my (undef, $id, $name, @scores) = split m/\s+/;
        $biaoxian{$id} = $scores[-1];
    }
    close(IN);
    open (OUT, "> 成绩_$class_name.txt") or die;
    open (OUT1, "> 录分_$class_name.txt") or die;
    my $j = 0;
    print OUT "序号 学号 姓名 班级 课程作业（40%） 课程表现（40%） 课堂考勤（20%） 总评\n";
    my $lost = 0;
    my $dd = 0;
    my ($a1, $a2, $a3, $a4, $a5) = (0, 0, 0, 0, 0);
    foreach my $id (@ids) {
        $j++;
        $zonggong++;
        my $pingshi = int($zuoye{$id} * 0.4 + $biaoxian{$id} * 0.4 + $kaoqing{$id} * 0.2 + 0.5);
        $pingshi = int($zuoye{$id} * 0.7 + $biaoxian{$id} * 0.2 + $kaoqing{$id} * 0.1 + 0.5) unless $class_name eq '应电';
        my $score = int($kaoshi{$id} * 0.7 + $pingshi * 0.3 + 0.5);
        next if $score < 0;
        print OUT "$j $id $students{$id} $zuoye{$id} $biaoxian{$id} $kaoqing{$id} $pingshi $kaoshi{$id} $score\n";
        print OUT1 "$j $id $students{$id} $pingshi $kaoshi{$id} $score\n";
        print "$j $id $students{$id} $zuoye{$id} $biaoxian{$id} $kaoqing{$id} $pingshi $kaoshi{$id} $score\n" if $score < 60;
        if ($kaoshi{$id} < 50 and $score >= 60) {
            #print "$j $id $students{$id} $zuoye{$id} $biaoxian{$id} $kaoqing{$id} $pingshi $kaoshi{$id} $score\n";
        }
        if ($kaoshi{$id} >= 50 and $score <= 60) {
            #print "$j $id $students{$id} $zuoye{$id} $biaoxian{$id} $kaoqing{$id} $pingshi $kaoshi{$id} $score\n";
        }
        $lost++ if $score < 60;
        $dd++ if $kaoshi{$id} < 50;
        $a1++ if $kaoshi{$id} < 60;
        $a2++ if $kaoshi{$id} >= 60 and $kaoshi{$id} < 70;
        $a3++ if $kaoshi{$id} >= 70 and $kaoshi{$id} < 80;
        $a4++ if $kaoshi{$id} >= 80 and $kaoshi{$id} < 90;
        $a5++ if $kaoshi{$id} >= 90;
    }
    close(OUT);
    close(OUT1);
    $all = $all + $lost;
    print "$class_name $lost $dd\n";
    #print "$class_name $a1 $a2 $a3 $a4 $a5\n";
}
print "$all $zonggong\n";
