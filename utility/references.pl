#!/usr/bin/perl

use Socket;

sub breaker
{
  print(('='x64)."\n");
}

open(L,'cat /var/log/apache/access_log | grep "GET /cgi-bin/~username/gb/"|');
while(<L>)
{
  @a=split/\"/;
  $cnt++;
  $l{lc($a[3])}++;
}

breaker();

for(sort keys%l)
{
  $cnt2++;
  print"$l{$_}\t| ".substr($_,0,53)."\n";
}

breaker();

print"\tTotal: $cnt\n\t Refs: $cnt2\n";

1
