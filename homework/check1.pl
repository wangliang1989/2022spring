#!/usr/bin/env perl
use strict;
use warnings;

my ($week) = @ARGV;
die unless defined $week;
my $dir = "/Users/liang/坚果云/作业上交/$week";
die unless -d $dir;
my @review;
foreach (glob "$dir/*") {
    next if $_ =~ '.xlsx';
    my ($zuoye) = (split m/\//)[-1];
    my ($id) = split '-', $zuoye;
    push @review, $id;
}
my %classes;
my @data;
foreach (glob "作业成绩*") {
    next if $_ =~ '应电';
    open (IN, "< $_") or die;
    foreach (<IN>) {
        next if $_ =~ '姓名';
        chomp;
        my ($id, $name, $class) = split m/\s+/;
        $classes{$class} = 0;
        push @data, $_;
    }
    close(IN);
}
open (OUT, "> 本科作业成绩检查.csv") or die;
print OUT "学号,姓名,班级,已改数,未改数,合计(此列小于6者不可参加考试),分数极低数量(此列大于0者期末成绩影响很大)\n";
foreach my $key (sort {$a cmp $b} keys %classes) {
    foreach (@data) {
        my ($id, $name, $class, @info) = split m/\s+/;
        next unless $class eq $key;
        my ($i, $j, $bl)= (0, 0, 0);
        foreach (@info) {
            $i++ if $_ >= 0;
            $j++ if $_ == 0;
        }
        foreach (@review) {
            $bl++ if $_ eq $id;
        }
        my $all = $i + $bl;
        print OUT "$id,$name,$class,$i,$bl,$all,$j\n"
    }
}
close(OUT);
print "1. 作业成绩没有问题，平时成绩就不会有问题\n";
print "2. 红色意味着你所交的作业数量不足6次，不可参加考试\n";
print "3. 黄色意味着你的作业成绩里有极度低的分数，需要重视\n";
print "4. 如果是我统计有误，请与我QQ联系，截止是6月13日\n";
print "5. 联系时，不必发“你好，谢谢”之类的，直接说自己的学号和问题\n";
