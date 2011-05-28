#!/devel/perl/bin/perl
#!/usr/bin/perl
#!C:\Pavel\Web\Perl\Bin\Perl

$me='cookie';

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
$db->bindstatement('total','../queries/'.$me.'_total.sql');

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

$db->{_STATEMENTS}{total}->execute;
$db->{_STATEMENTS}{total}->fetchrow;

$start=int(rand($db->{_STATEMENTS}{total}{_ROW}{__SQL__}{Counter}));

$db->{_STATEMENTS}{messages}->execute($start,1);

my $body='';
my $cnt=0;
while($db->{_STATEMENTS}{messages}->fetchrow)
{
  $cnt++;
  $body.=$msg->process(%{$db->{_STATEMENTS}{messages}{_ROW}});
}

print $head->dump."\n";

print $tpl->process(__COOKIELOGIN__=>$vars->{ARRAY_COOKIE}{gastbuchlogin}[0],__COOKIEPASSWORD__=>$vars->{ARRAY_COOKIE}{gastbuchpassword}[0],__BODY__=>$hf->process(__BODY__=>$body));

1
