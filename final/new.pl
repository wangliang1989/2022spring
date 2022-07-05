#!/usr/bin/env perl
use strict;
use warnings;


foreach (glob "考试成绩_*.txt") {
    my ($class_name) = split m/\./;
    ($class_name) = (split '_', $class_name)[-1];
    my @ids;
    my %students;
    my %zuoye;
    my %zuoye_record;
    my %kaoqing;
    my %biaoxian;
    my %biaoxian_record;
    open (IN, "< $_") or die;
    foreach my $info (<IN>) {
        next if $info =~ '姓名';
        $info =~ s/^\s+|\s+$//g;
        my (undef, $id, $name, $class, $score) = split m/\s+/, $info;
        $score = -12345 unless defined $score;
        push @ids, $id;
        $students{$id} = "$name $class";
    }
    close(IN);
    open (IN, "< ../homework/作业成绩_$class_name.csv") or die;
    foreach (<IN>) {
        next if $_ =~ '姓名';
        my (undef, $id, $name, $class, @scores) = split m/\s+/;
        $zuoye{$id} = pop @scores;
        $zuoye_record{$id} = join(' ', @scores);
        $zuoye_record{$id} =~ s/未交/0/g;
        $zuoye_record{$id} =~ s/抄袭/0/g;
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
        $biaoxian{$id} = pop @scores;
        my $d = 5;
        $d = 100 - $biaoxian{$id} if $d + $biaoxian{$id} > 100;
        $biaoxian_record{$id} = $biaoxian{$id};
        my $abc = $biaoxian{$id} - $d;
        $biaoxian_record{$id} = "$biaoxian_record{$id} $abc";
        $abc = $biaoxian{$id} + $d;
        $biaoxian_record{$id} = "$biaoxian_record{$id} $abc";
        my @check = split m/\s+/, $biaoxian_record{$id};
        foreach (@check) {
            die unless $_ <= 100 and $_ >= 0;
        }
    }
    close(IN);
    open (OUT, "> 平时_$class_name.txt") or die;
    print OUT "序号 学号 姓名 班级 课程作业（40%） 课程表现（40%） 课堂考勤（20%） 成绩\n" if $class_name eq '应电';
    print OUT "序号 学号 姓名 班级 课程作业（70%） 课程表现（20%） 课堂考勤（10%） 成绩\n" unless $class_name eq '应电';
    my $i = 0;
    my $aclass;
    foreach my $id (@ids) {
        my $pingshi = int($zuoye{$id} * 0.4 + $biaoxian{$id} * 0.4 + $kaoqing{$id} * 0.2 + 0.5);
        $pingshi = int($zuoye{$id} * 0.7 + $biaoxian{$id} * 0.2 + $kaoqing{$id} * 0.1 + 0.5) unless $class_name eq '应电';
        my ($class) = (split m/\s+/, $students{$id})[-1];
        $aclass = $class unless defined($aclass);
        $i = 0 unless $aclass eq $class or $aclass eq '20土木工程1';
        $i++;
        $aclass = $class;
        print OUT "$i $id $students{$id} $zuoye_record{$id} $biaoxian_record{$id} $kaoqing{$id} $pingshi\n";
    }
    close(OUT);
}
