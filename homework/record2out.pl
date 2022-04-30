#!/usr/bin/env perl
use strict;
use warnings;

foreach (glob "../list/*_official.csv") {
    my ($name) = (split m/\//)[-1];
    ($name) = split '_', $name;
    print "$name\n";
    my @students = info_office($_);
    open (IN, "< ${name}_record.csv") or die;
    my @record = <IN>;
    close(IN);
    open (OUT, "> 作业成绩_$name.csv") or die;
    print OUT "学号,姓名,班级,1,2,3,4,5,6,7,8,9,\n";
    foreach (@students) {
        my ($id) = split ',';
        my @data;
        foreach (@record) {
            chomp;
            next unless $_ =~ $id;
            my (undef, undef, undef, @info) = split m/\s+/;
            foreach (@info) {
                push @data, $_;
            }
        }
        if (defined($data[0])) {
            my $score = join(' ', @data);
            print OUT "$_ $score\n";
        }else{
            print OUT "$_\n";
        }
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
