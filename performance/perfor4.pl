#!/usr/bin/env perl
use strict;
use warnings;

#给出判断题的分数
my %records;
open (IN, "< ../homework/panduanti.txt") or die;
foreach (<IN>) {
    chomp;
    my ($id, $num, $score) = split m/\s+/;
    $records{"$id $num"} = $score unless defined($records{"$id $num"});
    $records{"$id $num"} = $score if $records{"$id $num"} < $score;
}
close(IN);
foreach my $file (glob "../list/*_official.csv") {
    my ($class) = (split m/\//, $file)[-1];
    ($class) = split '_', $class;
    my @students;
    open (IN, "< $file") or die $file;
    foreach (<IN>) {
        # 是否补修,电子邮箱,学号,姓名,性别,学院,年级,专业,班级,学生标记,辅修标记,是否重修,是否自修,手机号码
        my @info = split ",";
        push @students, "$info[2] $info[3] $info[8]" unless $_ =~ '姓名';
    }
    close(IN);
    open (OUT, "> perfor4_$class.txt") or die;
    foreach (@students) {
        my ($id, $name, $class) = split m/\s+/;
        print OUT "$id $name";
        foreach my $num (1, 2, 3, 4) {
            my $score = 75;
            foreach (keys %records) {
                my ($id0, $num0) = split m/\s+/;
                next unless $id =~ $id0 and $num =~ $num0;
                $score = 80 + $records{$_} / 5;
            }
            print OUT " $score";
        }
        print OUT "\n";
    }
    close(OUT);
}
