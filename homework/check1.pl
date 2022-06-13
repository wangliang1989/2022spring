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
system "date";
my %check_num;
open (OUT, "> 本科作业成绩检查.csv") or die;
print OUT "学号,姓名,班级,已改数,未改数,合计(此列小于6者不可参加考试),分数为0的数量(此列大于0者期末成绩影响很大)\n";
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
        print OUT "$id,$name,$class,$i,$bl,$all,$j\n";
        next if $all >= 6;
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
