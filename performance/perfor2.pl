#!/usr/bin/env perl
use strict;
use warnings;

#依据作业的上交时间给出分数
foreach my $file (glob "../list/*_official.csv") {
    my ($class) = (split m/\//, $file)[-1];
    ($class) = split '_', $class;
    my %xiugai;
    my %students;
    open (IN, "< $file") or die $file;
    foreach (<IN>) {
        # 是否补修,电子邮箱,学号,姓名,性别,学院,年级,专业,班级,学生标记,辅修标记,是否重修,是否自修,手机号码
        my @info = split ",";
        $students{$info[2]} = "$info[2] $info[3] $info[8]" unless $_ =~ '姓名';
        $xiugai{$info[3]} = $info[2] unless $_ =~ '姓名';
    }
    close(IN);
    my %medians;
    my %top_line;
    ($medians{$_}, $top_line{$_}) = get_th($_, keys %students) for (3, 4, 5, 6, 7, 8, 9);
    my %records;
    foreach (glob "time/*.csv") {
        open (IN, "< $_") or die;
        foreach (<IN>) {
            #刘仙华 2130612001 4 1653002380 95
            my ($name, $id, $num, $origin, undef) = split m/\s+/;
            unless (defined($students{$id})) {
                #print "$name $id $xiugai{$name}\n" if (defined($xiugai{$name}));
                $id = $xiugai{$name} if (defined($xiugai{$name}));
            }
            next unless defined($students{$id});
            next unless $num > 2 and $num < 10;
            die $num unless defined ($medians{$num});
            my ($time) = origin2sec($origin);
            my $score = int(85 + ($medians{$num} - $time) / 43200 + 0.5);
            $score = 95 if $time <= $top_line{$num} and $score < 95;
            $score = 100 if $score > 100;
            $score = 65 if $score < 65;
            if (defined($records{"$id $num"})) {
                $records{"$id $num"} = $score if $records{"$id $num"} < $score;
            }else{
                $records{"$id $num"} = $score;
            }
        }
        close(IN);
    }
    open (OUT, "> perfor2_$class.txt") or die;
    foreach my $id (sort {$a <=> $b} keys %students) {
        print OUT "$students{$id}";
        foreach my $num (3, 4, 5, 6, 7, 8, 9) {
            foreach (keys %records) {
                print OUT " $records{$_}" if ($_ eq "$id $num");
            }
        }
        print OUT "\n";
    }
    close(OUT);
}
sub origin2sec {
    use Time::Local;
    my @out;
    foreach (@_) {
        my ($date, $time) = split "T";
        my ($year, $mon, $day) = split "-", $date;
        my ($hour, $min, $sec) = split ":", $time;
        $mon -= 1;
        my $t = timegm($sec, $min, $hour, $day, $mon, $year);
        push @out, $t;
    }
    return @out;
}
sub get_th{
    my ($i, @students) = @_;
    my $max = 0;
    my %records;
    foreach (glob "time/*.csv") {
        open (IN, "< $_") or die;
        foreach (<IN>) {
            #刘仙华 2130612001 4 1653002380 95
            my ($name, $id, $num, $origin, undef) = split m/\s+/;
            next unless grep{$_ eq $id} @students;
            next unless $num == $i;

            my ($time) = origin2sec($origin);
            $records{$id} = $time unless defined($records{$id});
            $records{$id} = $time unless $records{$id} > $time;
        }
        close(IN);
    }
    my $median = 0;
    my $th = 0;
    my $j = 0;
    my @times;
    foreach (keys %records) {
        push @times, $records{$_};
    }
    foreach (sort {$a <=> $b} @times) {
        $j++;
        $th = $_ if $j <= 15;
        $median = $_ if $j <= @times / 2;
    }
    return ($median, $th);
}
