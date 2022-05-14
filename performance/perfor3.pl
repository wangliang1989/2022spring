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
    open (IN, "< ../homework/${class}_record.txt") or die;
    foreach (<IN>) {
        #2130612001 刘仙华 21电子1 100 99 100 100.100 100.100.95
        my ($id, $name, undef, undef, undef, @scores) = split m/\s+/;
        foreach (@scores) {
            my (undef, $score) = split m/\./;
            $score = 85 unless defined($score);
            if (defined($records{$id})) {
                $records{$id} = "$records{$id} $score";
            }else{
                $records{$id} = $score;
            }
        }
    }
    close(IN);
    open (OUT, "> perfor3_$class.txt") or die;
    foreach (sort {$a <=> $b} keys %students) {
        print OUT "$students{$_} $records{$_}\n" if defined($records{$_});
    }
    close(OUT);
}
