#!/usr/bin/env perl
use strict;
use warnings;

my $yibai = 0;
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
    my @result;
    foreach (sort {$a <=> $b} keys %students) {
        my ($i1) = getscore($_, @d1);
        my ($i2) = getscore($_, @d2);
        my ($i3) = getscore($_, @d3);
        my ($i4) = getscore($_, @d4);
        my ($i5) = getscore($_, @d5);
        my ($word) = trim("$students{$_} $i1 $i2 $i2 $i2 $i3 $i4 $i5");
        push @result, $word;
    }
    open (OUT, "> 课堂表现_$class.txt") or die;
    my $cishu = 1;
    for (my $i = 2; $i <= 32; $i++) {
        $cishu = "$cishu $i";
    }
    print OUT "学号 姓名 班级 $cishu 总评\n";
    foreach (@result) {
        my ($id, $name, $class, @info) = split m/\s+/;
        @info = (@info, @info);
        die if @info < 32;
        while () {
            last if @info == 32;
            @info = delete_one('min', @info);
            last if @info == 32;
            @info = delete_one('max', @info);
            last if @info == 32;
        }
        die unless @info == 32;
        #@info = jiafen(5, @info);
        #print "$class\n";
        @info = jiafen(0.5, $id, @info);#####################################
        @info = jiafen(1, $id, @info) if $class eq '21应电（专）';##############
        my @paichu = get_paichu($id);
        my ($mean, $i, $l) = (0, 0, 0);
        print OUT "$id $name $class";
        @info = i_int(@info);
        foreach (@info) {
            $i++;
            my $j = 0;
            foreach (@paichu) {
                $j++ if $i == $_;
            }
            if ($j > 0) {
                print OUT " -";
                next;
            }else{
                print OUT " $_";
            }
            $mean = $mean + $_;
            $l++;
        }
        $mean = int($mean / $l + 0.5);
        print OUT " $mean\n";
        print "$id $name $class $mean\n" if $mean > 99;
        $yibai++  if $mean > 99;
    }
    close(OUT);
}
print "$yibai\n";
sub i_int {
    my @out;
    foreach (@_) {
        push @out, int($_ + 0.5);
    }
    return @out;
}
sub jiafen {
    my ($jiafen, $id, @in) = @_;
    my @out;
    my $i = 0;
    foreach (@in) {
        $i++;
        my ($score, $s) = (0, $jiafen);
        $s = $s * 1.7 if $i / 3 == int($i / 3);
        if ($id / 2 == int($id / 2)) {
            $score = $_ + $s if $i / 2 == int($i / 2);
            $score = $_ unless $i / 2 == int($i / 2);
        }else{
            $score = $_ if $i / 2 == int($i / 2);
            $score = $_ + $s unless $i / 2 == int($i / 2);
        }
        $score = 100 if $score > 100;
        push @out, $score;
    }
    return @out;
}
sub get_paichu {
    my $id = shift;
    my @out;
    open (IN, "< ../rollcall/rollcall.txt") or die;
    foreach (<IN>) {
        my ($id0, undef, undef, @info) = split m/\s+/;
        next unless $id == $id0;
        foreach (@info) {
            my ($num, $eq) = split '-';
            push @out, $num unless $eq =~ '疫情';
        }
    }
    close(IN);
    return (@out);
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
sub delete_one {
    my @in = @_;
    my $m = shift @in;
    my $check;
    foreach (@in) {
        $check = $_ unless defined($check);
        if ($m eq 'max') {
            $check = $_ if $check < $_;
        }
        if ($m eq 'min') {
            $check = $_ if $check > $_;
        }
    }
    my @out;
    my $i = 0;
    foreach (@in) {
        if ($i == 0 and $_ == $check) {
            $i++;
            next;
        }
        push @out, $_;
    }
    return(@out);
}
