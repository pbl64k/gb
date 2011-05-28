#!/devel/perl/bin/perl
#!/usr/bin/perl
#!C:\Pavel\Web\Perl\Bin\Perl

$me='login';

use RErrorHandler;

use RConfiguration;
use RHTTPVariables;
use RHTTPHeader;
use RTemplate;
use RDataBase;

my $cf=RComplexPlainTextConfiguration->load('../configuration/gastbuch.cf');

my $vars=RHTTPVariables->load;
my $head=RHTTPHeader->create(
Status=>'301 Moved Permanently',
Location=>$vars->{ARRAY_POST}{goto}[0],
'Set-Cookie'=>'gastbuchlogin='.$vars->{ARRAY_POST}{login}[0]."\n".'set-cookie: gastbuchpassword='.$vars->{ARRAY_POST}{password}[0]
);

$u=`date`;
chomp$u;
open(ACCESS_LOG,'>>../utility/access_log');
print ACCESS_LOG $ENV{REMOTE_ADDR}.' '.$u.' '.$vars->{ARRAY_POST}{login}[0].' '.$vars->{ARRAY_POST}{password}[0]."\n";

print $head->dump."\n\n";

1
