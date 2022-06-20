#!/usr/bin/env perl
use strict;
use warnings;

my @review;
foreach my $week (@ARGV) {
    die unless defined $week;
    my $dir = "/Users/liang/坚果云/作业上交/$week";
    die unless -d $dir;
    foreach (glob "$dir/*") {
        next if $_ =~ '.xlsx';
        my ($zuoye) = (split m/\//)[-1];
        my ($id, $num) = split '-', $zuoye;
        push @review, $id;
        my ($a) = is_number($num);
        print "$zuoye $num\n" if $a == 1;
    }
}
my %classes;
my @data;
foreach (glob "作业成绩_*") {
    open (IN, "< $_") or die;
    foreach (<IN>) {
        next if $_ =~ '姓名';
        chomp;
        my @info = split m/\s+/;
        my $class = $info[3];
        $classes{$class} = 0;
        push @data, $_;
    }
    close(IN);
}
system "date";
my %check_num;
open (OUT, "> 作业数量检查.csv") or die;
print "1. 正常情况“合计”应该是9\n";
print "2. 未改数是程序自动算的，可能因为学生命名文件的原因，造成统计数量不对\n";
print OUT "学号,姓名,班级,已改数,未改数,合计\n";
foreach my $key (sort {$a cmp $b} keys %classes) {
    foreach (@data) {
        my ($xuhao, $id, $name, $class, @info) = split m/\s+/;
        next unless $class eq $key;
        my ($i, $bl)= (0, 0);
        foreach (@info) {
            $i++ unless $_ eq '未交';
        }
        $i--;
        foreach (@review) {
            $bl++ if $_ eq $id;
        }
        my $all = $i + $bl;
        print OUT "$id,$name,$class,$i,$bl,$all\n";
        next if $all >= 9;
        print "$id $name $class $all\n";
        $check_num{$class} = 0 unless defined($check_num{$class});
        $check_num{$class}++;
    }
}
close(OUT);
foreach (sort {$a cmp $b} keys %check_num) {
    print "$_ $check_num{$_}\n"
}
sub is_number {
    my $in = shift;
    my $reg1 = qr/^-?\d+(\.\d+)?$/;
    my $reg2 = qr/^-?0(\d+)?$/;
    my $out = 0;
    $out = 1 unless ($in =~ $reg1 && $in !~ $reg2);
    return $out;
    #是数字为0，不是数字为1
}
