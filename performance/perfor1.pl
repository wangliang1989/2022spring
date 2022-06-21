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
        next if ($_ =~ '姓名');
        my @info = split m/\s+/;
        my $record = "$info[1] $info[2] $info[3]";
        my $i = 0;
        foreach my $score (@info) {
            $i++;
            next if $i < 5;
            if ($i == 14) {
                #$record = "$record $score";
                next;
            }
            if ($score eq '未交' or $score eq '抄袭') {
                $record = "$record 50";
            }else{
                print "$record\n" unless defined($factors{$i - 4});
                $score = $score * $factors{$i - 4};
                $score = 70 if $score < 70;
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
        next unless defined($info[$i + 3]);
        next if $info[$i + 3] eq '未交' or $info[$i + 3] eq '抄袭';
        $max = $info[$i + 3] if $info[$i + 3] > $max;
    }
    close(IN);
    my $factor = 0;
    $factor = 95 / $max if $max > 0;
    return($factor);
}
