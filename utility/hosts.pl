#!/usr/bin/perl

use Socket;

sub breaker
{
  print(('='x64)."\n");
}

open(L,'cat /var/log/apache/access_log | grep "GET /cgi-bin/~username/gb/"|');
while(<L>)
{
  @a=split/ /;
  $cnt++;
  $l{$a[0]}++;
}

breaker();

for(sort keys%l)
{
  $rn=gethostbyaddr(inet_aton($_),AF_INET);
  $cnt2++;
  print"$_\t| $l{$_} | $rn\n";
}

breaker();

print"\tTotal: $cnt\n\tHosts: $cnt2\n";

1
