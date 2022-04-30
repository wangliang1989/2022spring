#!/usr/bin/env perl
use strict;
use warnings;

my %official;# 读入教务处名单
foreach my $file (glob "*_official.csv") {
    open (IN, "< $file") or die $file;
    foreach (<IN>) {
        # 是否补修,电子邮箱,学号,姓名,性别,学院,年级,专业,班级,学生标记,辅修标记,是否重修,是否自修,手机号码
        my @info = split ",";
        $official{$info[2]} = "$info[3] $info[8]" unless $_ =~ '姓名';
    }
    close (IN);
}
my %chaoxing;# 读入超星名单
foreach my $file (glob "*_chaoxing.csv") {
    open (IN, "< $file") or die $file;
    foreach (<IN>) {
        # 学号/工号,姓名,角色,性别,邮箱,院系,专业,班级,加入时间,入学年份,学校代码,学校,
        my @info = split ",";
        $chaoxing{$info[0]} = "$info[1] $info[7]" unless $_ =~ '姓名';
    }
    close (IN);
}
# 检查超星名单是否有多余
foreach (keys %chaoxing) {
    print "超星中的 $_ $chaoxing{$_} 不存在于教务处名单\n" unless defined($official{$_});
}
# 检查超星名单是否有缺失
foreach (keys %official) {
    print "教务处名单中的 $_ $official{$_} 不存在于超星中\n" unless defined($chaoxing{$_});
}
# 检查教务处名单是否存在没有邮箱地址信息的情况
my %address;
open (IN, "< mail.csv") or die;
foreach (<IN>) {
    my ($id, $add) = split ',';
    $address{$id} = $add;
}
close(IN);
foreach (sort {$a<=>$b} keys %official) {
    print "$_ $official{$_} 没有录入邮箱\n" unless defined($address{$_});
}
