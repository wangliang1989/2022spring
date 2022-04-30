#!/usr/bin/env perl
use strict;
use warnings;

#依据作业的上交时间给出分数
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
    open (IN, "< perfor1_$class.txt") or die;
    my @d1 = <IN>;
    close(IN);
    open (IN, "< perfor2_$class.txt") or die;
    my @d2 = <IN>;
    close(IN);
    open (IN, "< perfor3_$class.txt") or die;
    my @d3 = <IN>;
    close(IN);
    open (OUT, "> 课堂表现_$class.txt") or die;
    foreach (sort {$a <=> $b} keys %students) {
        print OUT "$students{$_}";
        my ($i1) = getscore($_, @d1); print OUT " $i1" unless $i1 eq '-12345';
        my ($i2) = getscore($_, @d2); print OUT " $i2" unless $i2 eq '-12345';
        my ($i3) = getscore($_, @d3); print OUT " $i3" unless $i3 eq '-12345';
        print OUT "\n";
    }
    close(OUT);
}
sub getscore{
    my ($id, @data) = @_;
    my $out = -12345;
    foreach (@data) {
        # 2130612001 刘仙华 21电子1 95 95
        my (undef, undef, undef, @info) = split m/\s+/;
        $out = join(' ', @info) if $_ =~ $id;
    }
    return ($out);
}
