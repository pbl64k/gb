#!/usr/bin/perl

$me='adduser_form';

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

print $head->dump."\n";

print $tpl->process;

1
