#!/usr/bin/env perl
use strict;
use warnings;

#依据作业的成绩给出分数
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
    my %factors;
    ($factors{$_}) = get_factor($_, $class) for (1, 2, 3, 4, 5, 6, 7, 8, 9);
    open (OUT, "> perfor1_$class.txt") or die;
    open (IN, "< ../homework/作业成绩_$class.csv") or die;
    foreach (<IN>) {
        chomp;
        if ($_ =~ '姓名') {
            print OUT "$_\n";
            next;
        }
        my @info = split m/\s+/;
        my $record = "$info[0] $info[1] $info[2]";
        my $i = 0;
        foreach my $score (@info) {
            $i++;
            next if $i < 4;
            if ($score == -1) {
                $record = "$record 40 40 40";
            }elsif ($score == 0) {
                $record = "$record 60 60 60";
            }else{
                $score = int($score * $factors{$i - 3} + 0.5);
                $record = "$record $score";
            }
        }
        print OUT "$record\n";
    }
    close(OUT);
    close(IN);
}
sub get_factor{
    my ($i, $class) = @_;
    my $max = 0;
    open (IN, "< ../homework/作业成绩_$class.csv") or die;
    foreach (<IN>) {
        next if $_ =~ '姓名';
        #1810612066 鲍少兴 21电子1 100 95
        my @info = split m/\s+/;
        next unless defined($info[$i + 2]);
        $max = $info[$i + 2] if $info[$i + 2] > $max;
    }
    close(IN);
    my $factor = 0;
    $factor = 95 / $max if $max > 0;
    return($factor);
}
