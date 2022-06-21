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
    open (IN, "< perfor4_$class.txt") or die;
    my @d5 = <IN>;
    close(IN);
    open (IN, "< performance.txt") or die;
    my @d4;
    foreach (<IN>) {
        push @d4, $_ unless $_ =~ '#';
    }
    close(IN);
    open (OUT, "> 课堂表现_$class.txt") or die;
    foreach (sort {$a <=> $b} keys %students) {
        my $word = $students{$_};
        my ($i1) = getscore($_, @d1); $word = "$word $i1"; ($word) = trim($word);
        my ($i2) = getscore($_, @d2); $word = "$word $i2 $i2"; ($word) = trim($word);
        my ($i3) = getscore($_, @d3); $word = "$word $i3"; ($word) = trim($word);
        my ($i4) = getscore($_, @d4); $word = "$word $i4"; ($word) = trim($word);
        my ($i5) = getscore($_, @d5); $word = "$word $i5"; ($word) = trim($word);
        print OUT "$word\n";
        print "$word\n";
    }
    close(OUT);
}
sub getscore{
    my ($id, @data) = @_;
    my $out = ' ';
    foreach (@data) {
        # 2130612001 刘仙华 21电子1 95 95
        my (undef, undef, undef, @info) = split m/\s+/;
        $out = join(' ', @info) if $_ =~ $id;
    }
    return ($out);
}
sub trim {
    my $s = shift;
    $s =~ s/^\s+|\s+$//g;
    return $s;
}
