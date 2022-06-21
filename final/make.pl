#!/usr/bin/env perl
use strict;
use warnings;

die;
foreach (glob "../list/*_official.csv") {
    my ($name) = (split m/\//)[-1];
    ($name) = split '_', $name;
    my @students = info_office($_);
    open (OUT, "> 考试成绩_$name.txt") or die;
    my $j = 0;
    print OUT "序号 学号 姓名 班级 分数\n";
    foreach (@students) {
        my @info = split m/\s+/;
        $j++;
        print OUT "$j $info[0] $info[1] $info[2] \n";
    }
    close(OUT);
}

sub info_office {
    my ($file) = @_;
    my @out;
    open (IN, "< $file") or die $file;
    foreach (<IN>) {
        # 是否补修,电子邮箱,学号,姓名,性别,学院,年级,专业,班级,学生标记,辅修标记,是否重修,是否自修,手机号码
        next if $_ =~ '姓名';
        my @info = split ",";
        push @out, "$info[2] $info[3] $info[8]";
    }
    close (IN);
    return @out;
}
