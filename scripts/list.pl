#!/devel/perl/bin/perl
#!/usr/bin/perl
#!C:\Pavel\Web\Perl\Bin\Perl

$me='list';

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
my $ctrl=RTemplate->load('../templates/'.$me.'_control.tpl.html');
my $next=RTemplate->load('../templates/'.$me.'_nextbutton.tpl.html');
my $prev=RTemplate->load('../templates/'.$me.'_prevbutton.tpl.html');
my $msg=RTemplate->load('../templates/'.$me.'_message.tpl.html');
my $usrt=RTemplate->load('../templates/'.$me.'_user.tpl.html');

$start=($vars->{ARRAY_GET}{start}[0])+0;

my $db=RDataBase->create(%{$cf->{NORMAL}{db}});
$db->bindstatement('authorize','../queries/authorize.sql');
$db->bindstatement('messages','../queries/'.$me.'_messages.sql');
$db->bindstatement('total','../queries/'.$me.'_total.sql');
$db->bindstatement('users','../queries/'.$me.'_users.sql');

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

$db->{_STATEMENTS}{users}->execute;

my $ub='';
while($db->{_STATEMENTS}{users}->fetchrow)
{
  $ub.=$usrt->process(%{$db->{_STATEMENTS}{users}{_ROW}});
}

$db->{_STATEMENTS}{messages}->execute($start,$cf->{NORMAL}{tuning}{defaultframe}+0);

$db->{_STATEMENTS}{total}->execute;
$db->{_STATEMENTS}{total}->fetchrow;

my $body='';
my $cnt=0;
while($db->{_STATEMENTS}{messages}->fetchrow)
{
  $cnt++;
  $body.=$msg->process(%{$db->{_STATEMENTS}{messages}{_ROW}});
}

$prvbutt=($start>0)?
$prev->process(__START__=>(($start-($cf->{NORMAL}{tuning}{defaultframe})>0)?$start-($cf->{NORMAL}{tuning}{defaultframe}):0)):
'';

$nxtbutt=($start+$cnt<$db->{_STATEMENTS}{total}{_ROW}->{__SQL__}{Counter})?
$next->process(__START__=>$start+$cnt):
'';

$control=$ctrl->process(__START__=>($start+1),__FINISH__=>($start+$cnt),__TOTAL__=>($db->{_STATEMENTS}{total}{_ROW}->{__SQL__}{Counter}),__NEXT_BUTTON__=>$nxtbutt,__PREV_BUTTON__=>$prvbutt);

print $head->dump."\n";

print $tpl->process(__USR__=>$ub,__COOKIELOGIN__=>$vars->{ARRAY_COOKIE}{gastbuchlogin}[0],__COOKIEPASSWORD__=>$vars->{ARRAY_COOKIE}{gastbuchpassword}[0],__BODY__=>$hf->process(__BODY__=>$body,__HEADFOOT__=>$control));

1
