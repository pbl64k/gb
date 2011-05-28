#!/devel/perl/bin/perl
#!/usr/bin/perl
#!C:\Pavel\Web\Perl\Bin\Perl

$me='adduser';

use RErrorHandler;

use RConfiguration;
use RHTTPVariables;
use RHTTPHeader;
use RTemplate;
use RDataBase;

my $cf=RComplexPlainTextConfiguration->load('../configuration/gastbuch.cf');

my $vars=RHTTPVariables->load;
my $head=RHTTPHeader->create;

my $tpl=RTemplate->load('../templates/'.$me.'_goback.tpl.html');
my $permden=RTemplate->load('../templates/'.$me.'_permden.tpl.html');
my $pwddnm=RTemplate->load('../templates/'.$me.'_pwddonotmatch.tpl.html');
my $ok=RTemplate->load('../templates/'.$me.'_ok.tpl.html');

my $db=RDataBase->create(%{$cf->{NORMAL}{db}});
$db->bindstatement('authorize','../queries/'.$me.'_authorize.sql');
$db->bindstatement('add','../queries/'.$me.'_add.sql');
$db->{_STATEMENTS}{authorize}->execute($vars->{ARRAY_POST}{adminlogin}[0],$vars->{ARRAY_POST}{adminpassword}[0]);

my $body='';
if($db->{_STATEMENTS}{authorize}->fetchrow)
{
  if($vars->{ARRAY_POST}{password}[0] eq $vars->{ARRAY_POST}{confirmpassword}[0])
  {
    $db->{_STATEMENTS}{add}->execute($vars->{ARRAY_POST}{login}[0],$vars->{ARRAY_POST}{password}[0],$vars->{ARRAY_POST}{realname}[0],$vars->{ARRAY_POST}{email}[0],$vars->{ARRAY_POST}{url}[0]);
    $body=$ok->process;
  }
  else
  {
    $body=$pwddnm->process;
  }
}
else
{
  $body=$permden->process;
}

print $head->dump."\n";

print $tpl->process(__BODY__=>$body,__GOBACK__=>$ENV{HTTP_REFERER});

1
