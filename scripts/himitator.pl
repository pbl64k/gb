#!/usr/bin/perl

$me='himitator';

use RErrorHandler;

use RConfiguration;
use RHTTPVariables;
use RHTTPHeader;
use RTemplate;
use RDataBase;

my $cf=RComplexPlainTextConfiguration->load('../configuration/gastbuch.cf');

my $vars=RHTTPVariables->load;
my $head=RHTTPHeader->create;

my $tpl=RTemplate->load('../templates/'.$me.'_main.tpl.html');
my $redir=RTemplate->load('../templates/'.$me.'_redirectlogin.tpl.html');
my $hf=RTemplate->load('../templates/'.$me.'_headfoot.tpl.html');
my $msg=RTemplate->load('../templates/'.$me.'_message.tpl.html');

my $db=RDataBase->create(%{$cf->{NORMAL}{db}});
$db->bindstatement('authorize','../queries/authorize.sql');
$db->bindstatement('messages','../queries/'.$me.'_messages.sql');
$db->bindstatement('user','../queries/'.$me.'_user.sql');

$db->{_STATEMENTS}{authorize}->execute(
$vars->{ARRAY_COOKIE}{gastbuchlogin}[0],
$vars->{ARRAY_COOKIE}{gastbuchpassword}[0]
);

if(!($db->{_STATEMENTS}{authorize}->fetchrow))
{
  print STDOUT $head->dump."\n";

  print STDOUT $redir->process;
  exit;
}

$db->{_STATEMENTS}{user}->execute($vars->{ARRAY_GET}{uid}[0]);
$db->{_STATEMENTS}{user}->fetchrow;

$db->{_STATEMENTS}{messages}->execute($vars->{ARRAY_GET}{uid}[0]);

my $body='';
my $cnt=0;
while($db->{_STATEMENTS}{messages}->fetchrow)
{
  $cnt++;
  $body.=($db->{_STATEMENTS}{messages}{_ROW}->{messages}{subject}.' '.
          $db->{_STATEMENTS}{messages}{_ROW}->{messages}{message}.' ');
}

# accept following characters:
my$filter='abcdefghijklmnopqrstuvwxyz'.
          ' .,:;-!?';
my@filter=split//,$filter;

# upper case
my$uc='ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
      ' .,:;-!?';
my @uc=split//,$uc;

# letters only
my$letters='abcdefghijklmnopqrtsuvwxyz';
my@letters=split//,$letters;

# window size
$winsize=$vars->{ARRAY_GET}{window}[0];

# length
my$len=$vars->{ARRAY_GET}{length}[0];

# read by char
$/=\1;

my%freq;
my@z,@zz;
my@result;
my$cntr;

$body=~s/[\t\r\n0-9<>]/ /g;

my$cnt=0;
my@x=split//,$body;

for($cntr=0;$cntr<$winsize-1;$cntr++)
{
  do{$zz[$cntr]=$z[$cntr]=$x[$cnt++];$z[$cntr]=~s/\n/ /;$z[$cntr]=~tr/A-Z/a-z/;}while((index($filter,$z[$cntr])<0)&&$x[$cnt]);
}
while($_=$x[$cnt++])
{
  s/\n/ /;
  $_=~tr/A-Z/a-z/;
  next if(index($filter,$_)<0);
  $freq{join'',@z}{$_}++;
  @z=(@z[1..$#z],$_);

}

my@seeds=keys%freq;
@result=split//,$seeds[int(rand($#seeds+1))];
$len-=($winsize-1);
while(--$len)
{
  my$total,$gadzook;
  for(sort keys%{$freq{join'',@result[($#result-$winsize+2)..$#result]}})
  {
    $total+=$freq{join'',@result[($#result-$winsize+2)..$#result]}{$_};
  }
  $gadzook=int(rand($total));
  $total=0;
Z:for(sort keys%{$freq{join'',@result[($#result-$winsize+2)..$#result]}})
  {
    $total+=$freq{join'',@result[($#result-$winsize+2)..$#result]}{$_};
    if($total>$gadzook)
    {
      $result[++$#result]=$_;
      last Z;
    }
  }
}
$result[++$#result]='.';
my$rs=join'',@result;

$rs=~s/^\s+//;
$rs=~s/\s+/ /g;
$rs=~s/([\.\!\?]\s+|^)(.)/$1.$uc[index($letters,$2)]/eg;

print $head->dump."\n";

print $tpl->process(__COOKIELOGIN__=>$vars->{ARRAY_COOKIE}{gastbuchlogin}[0],__COOKIEPASSWORD__=>$vars->{ARRAY_COOKIE}{gastbuchpassword}[0],__BODY__=>$hf->process(__BODY__=>$msg->process(__BODY__=>$rs,__USER__=>$db->{_STATEMENTS}{user}{_ROW}->{users}{realname})));

1
