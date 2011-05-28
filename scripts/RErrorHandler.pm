
package RErrorHandler;

@severities=("Warning","Error","Fatal Error","Crash");

my $crashdotcom="crash.pl?msg=";

sub handle
{
  my($self,$severity,$source,$error)=@_;
  if($severity<3)
  {
    warn("$severities[$severity]: $source: $error<br>\n");
  }
  else
  {
    sub r
    {
# legacy code
      my $r='';
      for(split//,@_[0])
      {
        $r.='%'.unpack"H2",$_
      }
      return $r;
    }
# HTTP processing hardcoded to get rid of cross-dependencies
    print STDOUT "Status: 301 Moved Permanently\n";
    print STDOUT "Location: $crashdotcom".r($error)."\n\nAn error has occured\n";
# end of hardcoded HTTP processing
  }
  return $severity;
}

1
