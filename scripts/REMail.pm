
require RErrorHandler;

require REntityHeader;

# Socket.pm is use()d in send() method so it's really obsolete here
require Socket;

package REMail;

@ISA=qw{ REntityHeader };

my(%defaulthead)=('__mailserver__'=>'127.0.0.1',
                  '__port__'=>25,
                  '__protocol__'=>tcp);

my $filter='^__.*?__$';

sub create
{
  my $this=shift;
  my(%newhead)=(@_);
  undef local @_;
  if(%newhead)
  {
    my $self=($this->SUPER::create(%newhead));
  }
  else
  {
    my $self=($this->SUPER::create(%defaulthead));
  }
}

sub send
{
  my $self=shift;

# Shit happens trying to getprotobyname() if Socket.pm wasn't
# use()d within the scope it's called from.
  use Socket;

  if(!socket(SMTP,PF_INET,SOCK_STREAM,getprotobyname($self->{__protocol__})))
  {
    RErrorHandler->handle(0,$self,"can't open socket for protocol '".$self->{'__protocol__'}."' -- networking said: '$!'");
  }
  if(!connect(SMTP,sockaddr_in($self->{'__port__'},inet_aton($self->{'__mailserver__'}))))
  {
    RErrorHandler->handle(0,$self,"can't connect to '".$self->{'__mailserver__'}.":".$self->{'__port__'}."' -- networking said: '$!'");
  }
  select SMTP;
  local $|=1;
  $answer=<SMTP>;
  if($answer!~/^2/)
  {
    RErrorHandler->handle(0,$self,"mailserver '".$self->{__mailserver__}."' refused to greet properly -- SMTP said: '$answer'\n");
  }
  print "HELO ".$self->{__domain__}."\n";
  $answer=<SMTP>;
  if($answer!~/^2/)
  {
    RErrorHandler->handle(0,$self,"mailserver '".$self->{__mailserver__}."' refused to accept source domain '".$self->{__domain__}."' -- SMTP said: '$answer'\n");
  }
  print "MAIL FROM:<".$self->{__from__}.">\n";
  $answer=<SMTP>;
  if($answer!~/^2/)
  {
    RErrorHandler->handle(1,$self,"mailserver '".$self->{__mailserver__}."' refused to accept send '".$self->{__from__}."' -- SMTP said: '$answer'\n");
  }
  print "RCPT TO:<".$self->{__to__}.">\n";
  $answer=<SMTP>;
  if($answer!~/^2/)
  {
    RErrorHandler->handle(1,$self,"mailserver '".$self->{__mailserver__}."' refused to accept recipient '".$self->{__to__}."' -- SMTP said: '$answer'\n");
  }
  print "DATA\n";
  $answer=<SMTP>;
  if($answer!~/^3/)
  {
    RErrorHandler->handle(1,$self,"mailserver '".$self->{__mailserver__}."' refused to start mail message transfer -- SMTP said: '$answer'\n");
  }
  print $self->dump($filter);
  print "\n";
  print $self->{__body__};
  print "\n.\n";
  $answer=<SMTP>;
  if($answer!~/^2/)
  {
    RErrorHandler->handle(1,$self,"mailserver '".$self->{__mailserver__}."' refused to accept message for delivery -- SMTP said: '$answer'\n");
  }
  print "QUIT\n";
  $answer=<SMTP>;
  if($answer!~/^2/)
  {
    RErrorHandler->handle(0,$self,"mailserver '".$self->{__mailserver__}."' refused to break connection properly -- SMTP said: '$answer'\n");
  }
  select STDOUT;
}
