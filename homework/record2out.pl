#!/usr/bin/env perl
use strict;
use warnings;

open (IN, "< panduanti.txt") or die;
my @panduan = <IN>;
close(IN);
foreach (glob "../list/*_official.csv") {
    my ($name) = (split m/\//)[-1];
    ($name) = split '_', $name;
    print "$name\n";
    my @students = info_office($_);
    open (IN, "< ${name}_record.txt") or die "cannot open ${name}_record.txt";
    my @record = <IN>;
    close(IN);
    my @out;
    foreach (@students) {
        my ($id) = split m/\s+/;
        my @data;
        foreach (@record) {
            chomp;
            next unless $_ =~ $id;
            my (undef, undef, undef, @info) = split m/\s+/;
            foreach (@info) {
                push @data, int $_;
            }
        }
        if (defined($data[0])) {
            my $score = join(' ', @data);
            if ($name eq '应电') {
                foreach my $i (1, 2, 3, 4, 5) {
                    foreach (@panduan) {
                        #江金璐 2141327042 21应电班 5 100
                        my ($name2, $id2, $class2, $i2, $score2) = split m/\s+/;
                        $score = "$score $score2" if $id2 eq $id and $i == $i2;
                    }
                }
                $score = "$score 100";
            }
            my @fenshu = split m/\s+/, $score;
            my $meijiao = 9 - @fenshu;
            while ($meijiao > 0) {
                $score = "$score -1";
                $meijiao = $meijiao - 1;
            }
            push @out, "$_ $score";
        }else{
            push @out, "$_\n";
        }
    }
    open (OUT, "> 作业成绩_$name.csv") or die;
    print OUT "学号,姓名,班级,1,2,3,4,5,6,7,8,9\n";
    foreach (@out) {
        my @info = split m/\s+/;
        my $record = "$info[0] $info[1] $info[2]";
        my $i = 0;
        foreach (@info) {
            $i++;
            next if $i < 4;
            $record = "$record $_";
        }
        print OUT "$record\n";
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
