#!/usr/bin/env perl
use strict;
use warnings;

my %official;# 读入教务处名单
foreach my $file (glob "../list/*_official.csv") {
    open (IN, "< $file") or die $file;
    foreach (<IN>) {
        # 是否补修,电子邮箱,学号,姓名,性别,学院,年级,专业,班级,学生标记,辅修标记,是否重修,是否自修,手机号码
        my @info = split ",";
        $official{$info[2]} = "$info[3] $info[8]" unless $_ =~ '姓名';
    }
}
my %homework;# 读入作业成绩
foreach my $file (glob "../homework/*_out.csv") {
    open (IN, "< $file") or die $file;
    foreach (<IN>) {
        next if $_ =~ '姓名';
        chomp;
        my ($id, $name, $class, @score) = split ',';
        my $i = 0;
        foreach (@score) {
            next unless ($_ == $_ + 0);
            $i++;
            my $txt = "          第${i}次: $_\n";
            if (defined($homework{$id})) {
                $homework{$id} = "$homework{$id}$txt";
            }else{
                $homework{$id} = $txt;
            }
        }
        $homework{$id} = "          无记录\n" unless defined($homework{$id});
    }
    close(IN);
}
my %rollcall;# 读入考勤成绩
open (IN, "< ../rollcall/kaoqing.txt") or die;
foreach (<IN>) {
    # 2130823053 黄浩文 21数据2 缺勤 2 次,考勤分数为 94
    my ($id, $name, $class, @info) = split m/\s+/;
    $rollcall{$id} = "@info";
}
close(IN);
my %performance;# 读入课堂表现成绩
open (IN, "< ../performance/performance.txt") or die;
foreach (<IN>) {
    # 2130612015 韦嘉欢 21电子1 自觉改正错题
    my ($id, $name, $class, @event) = split m/\s+/;
    if (defined($performance{$id})) {
        $performance{$id} = "$performance{$id}@event";
    }else{
        $performance{$id} = "@event";
    }
}
close(IN);
my %finalexam;# 读入期考成绩
foreach my $id (keys %official) {
    my ($day1, $day2) = getday();
    my ($name, $class) = split m/\s+/, $official{$id};
    mkdir $day1;
    open (OUT, "> $day1/$id.$day1.notice") or die;
    print OUT "$name同学：\n";
    print OUT "     你好！\n";
    print OUT "  你的大学物理课程成绩如下\n";
    print OUT "1. 作业：\n";
    print OUT $homework{$id};
    print OUT "2. 考勤：\n";
    print OUT "          $rollcall{$id}\n" if defined ($rollcall{$id});
    print OUT "          100\n" unless defined ($rollcall{$id});
    print OUT "3. 课堂表现：\n";
    print OUT "          $performance{$id}\n" if defined ($performance{$id});
    print OUT "          无记录\n" unless defined ($performance{$id});
    open (IN, "< notice.txt") or die;
    foreach (<IN>) {
        last if $_ =~ '#';
        print OUT $_;
    }
    close(IN);
    print OUT $day2;
    close(OUT);
}
sub getday {
    my($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst)
            = localtime();
    $year = $year + 1900;
    $mon = $mon + 1;
    $mon = "0$mon" if $mon < 10;
    $mday = "0$mday" if $mday < 10;
    my $day2 = "${year}年${mon}月${mday}日${hour}时${min}分${sec}秒";
    $day2 = "                                                $day2\n";
    return ("$year$mon$mday", $day2);
}
=pod
my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
$year = $year + 1900;
$mon = $mon + 1;
$mon = "0$mon" if $mon < 10;
$mday = "0$mday" if $mday < 10;
print "$sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst\n";
print "$year$mon$mday\n";

foreach my $id (keys %official) {
    open (OUT, "> $id")
}
open (OUT, "> ")
foreach (glob "*_out.csv") {
    my ($name) = split '_';
    print "$name\n";
    open (IN, "< $_") or die;
    my @data = <IN>;
    close(IN);
    my $th = 0;
    foreach (@data) {
        next if $_ =~ '姓名';
        chomp;
        my (undef, undef, undef, @info) = split ',';
        my $up = 0;
        foreach (@info) {
            $up++ unless ",$_," eq ",,";
        }
        $th = $up if $th < $up;
    }
    foreach (@data) {
        next if $_ =~ '姓名';
        chomp;
        my (undef, undef, undef, @info) = split ',';
        my $up = 0;
        foreach (@info) {
            $up++ unless ",$_," eq ",,";
        }
        print "$_\n" if $th > $up;
    }
}
