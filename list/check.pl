#!/usr/bin/env perl
use strict;
use warnings;

# 检查超星和教务处的名单是否有对应的名单
check_class ('chaoxing', 'office');
check_class ('office', 'chaoxing');

# 检查超星名单是否有多余
foreach (glob "*_chaoxing.csv") {
    my ($office_file) = split '_';
    my @chaoxing = info_chaoxing($_);
    my @office = info_office("${office_file}_office.csv");
    foreach (@chaoxing) {
        my ($id1, $name1, $class1) = split m/\s+/;
        my $i = 0;
        foreach (@office) {
            my ($id2, $name2, $class2) = split m/\s+/;
            $i++ if $id1 eq $id2;
        }
        print "超星名单中的$id1 $name1 $class1 在教务处名单没有\n" if $i == 0;
    }
    foreach (@office) {
        my ($id1, $name1, $class1) = split m/\s+/;
        my $i = 0;
        foreach (@chaoxing) {
            my ($id2, $name2, $class2) = split m/\s+/;
            $i++ if $id1 eq $id2;
        }
        print "教务处名单中的$id1 $name1 $class1 在超星名单没有\n" if $i == 0;
    }
}
# 检查超星名单是否有缺少

sub check_class {
    my ($a, $b) = @_;
    foreach (glob "*_$a.csv") {
        my ($class) = split '_';
        print "no $b file for $_\n" unless -e "${class}_$b.csv";
    }
}
sub info_chaoxing {
    my ($file) = @_;
    my @out;
    open (IN, "< $file") or die $file;
    foreach (<IN>) {
        # 学号/工号,姓名,角色,性别,邮箱,院系,专业,班级,加入时间,入学年份,学校代码,学校,
        # 1810612066,鲍少兴,学生,,,人工智能学院（现代产业学院）,电子信息工程,21电子1,2022-02-23,2021,3437,贺州学院,
        next if $_ =~ '姓名';
        my @info = split ",";
        push @out, "$info[0] $info[1] $info[7]";
    }
    close (IN);
    return @out;
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
