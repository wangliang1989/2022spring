#!/usr/bin/env perl
use strict;
use warnings;

#依据作业的态度给出分数
foreach my $file (glob "../list/*_official.csv") {
    my ($class) = (split m/\//, $file)[-1];
    ($class) = split '_', $class;
    my %students;
    open (IN, "< $file") or die $file;
    foreach (<IN>) {
        # 是否补修,电子邮箱,学号,姓名,性别,学院,年级,专业,班级,学生标记,辅修标记,是否重修,是否自修,手机号码
        my @info = split ",";
        $students{$info[2]} = "$info[2] $info[3] $info[8]" unless $_ =~ '姓名';
    }
    close(IN);
    my %records;
    foreach my $file (glob "jg.*.txt") {
        open (IN, "< $file") or die;
        foreach (<IN>) {
            #刘仙华 2130612001 4 1653002380 95
            my ($name, $id, $num, $time, $score) = split m/\s+/;
            next unless grep{$_ eq $id} keys %students;
            next unless $num > 2 and $num < 10;
            if (defined($records{$id})) {
                $records{$id} = "$records{$id} $score";
            }else{
                $records{$id} = $score;
            }
        }
        close(IN);
    }
    open (OUT, "> perfor3_$class.txt") or die;
    foreach (sort {$a <=> $b} keys %students) {
        print OUT "$students{$_} $records{$_}\n" if defined($records{$_});
    }
    close(OUT);
}
