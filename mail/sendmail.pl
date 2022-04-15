#!/usr/bin/perl -w
use warnings;
use strict;
use Net::SMTP;
use MIME::Base64;

@ARGV == 1 or die "Usage: perl mail-files\n";
my ($dir) = @ARGV;
# 读取邮箱地址
my %address;
open (IN, "< ../list/mail.csv") or die;
foreach (<IN>) {
    my ($id, $add) = split ',';
    $address{$id} = $add;
}
close(IN);
# 获取邮件发送的关键信息
my $host;       # host domain
my $sender;     # my email
my $passwd;     # password
open(PRI,'< private') or die;
foreach (<PRI>) {
    chomp;
    my @info = split /\s+/;
    if ($info[0] eq 'host') {
        $host = $info[1];# host domain
    }elsif ($info[0] eq 'sender') {
        $sender = $info[1];# my email
    }elsif ($info[0] eq 'passwd') {
        $passwd = $info[1];# password
    }
}
close(PRI);

chdir $dir or die;
foreach (glob "*.*.*") {
    my ($id, $day, $q) = split m/\./;
    my $recipient = $address{$id};
    my $subject;
    $subject = "大学物理课程成绩通知($day)" if $q eq 'notice';
    unless (defined($recipient) and defined($subject)) {
        open (OUT, ">> err.txt") or die;
        print OUT "A $_ B $recipient C $subject\n";
        close(OUT);
        next;
    }
    # 设定发信参数
    my $smtp = Net::SMTP->new(
        Host    =>   $host,
        Timeout =>   30,
        Debug   =>   1,
    );
    # 登录
    $smtp -> command ('AUTH LOGIN') -> response ();
    my $userpass = encode_base64 ($sender);
    chomp ($userpass);
    $smtp -> command ($userpass) -> response();
    $userpass = encode_base64 ($passwd);
    chomp ($userpass);
    $smtp -> command ($userpass) -> response();
    # 发送邮件
    $smtp -> mail ($sender);
    $smtp -> to ($recipient);
    $smtp -> data ();
    $smtp -> datasend ("Subject:$subject\n");
    $smtp -> datasend ("From:$sender\n");
    $smtp -> datasend ("To:$recipient\n");
    $smtp -> datasend ("\n");
    open(IN, "< $_") or die $_;
    $smtp -> datasend($_) foreach (<IN>);
    close(IN);
    $smtp -> dataend();
    $smtp -> quit;
    sleep(60);
}
