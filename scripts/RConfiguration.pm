
require RErrorHandler;

require RHash;

package RPlainTextConfiguration;

@ISA=qw{ RHash };

sub create
{
  my $this=shift;
  my $self=($this->SUPER::create(@_));
  return $self;
}

sub load
{
  my $this=shift;
  my $filename=shift;
  my $self=($this->SUPER::create(@_));
  if(!open(FILE,"<$filename"))
  {
    RErrorHandler->handle(1,$self,"can't open '$filename' -- FS said: '$!'");
  }
  while(<FILE>)
  {
    if(!m"^(#|;|//)")
    {
      chomp;
      @pair=split(/=/,$_,2);
      if(exists($self->{$pair[0]}))
      {
        RErrorHandler->handle(0,$self,"'$pair[0]' redefinition -- was '$self->{$pair[0]}'; will be '$pair[1]'");
      }
      $self->{$pair[0]}=$pair[1];
    }
  }
  return $self;
}

package RComplexPlainTextConfiguration;

@ISA=qw{ RPlainTextConfiguration };

my $defaultpart='_default';
my(@tags)=qw{ NORMAL PROCESSED };

sub create
{
  my $this=shift;
  my $self=($this->SUPER::create(@_));
  return $self;
}

sub load
{
  my $this=shift;
  my $filename=shift;
  my $self=($this->SUPER::create(@_));
  if(!open(FILE,"<$filename"))
  {
    RErrorHandler->handle(1,$self,"can't open '$filename' -- FS said: '$!'");
  }
  my $part=$defaultpart;
  $self->{$part}={};
  $self->{$processedtag}{$part}={};
  while(<FILE>)
  {
    if(!m"^(#.*|;.*|//.*|)$")
    {
      chomp;
      if(/^:(.*?)$/)
      {
        if(!defined($self->{$1}))
        {
          $self->{$tags[0]}{$1}={};
          $self->{$tags[1]}{$1}={};
        }
        $part=$1;
      }
      else
      {
        my @pair=split(/=/,$_,2);
        my $processed=$self->process($pair[1]);
        if(exists($self->{$tags[0]}{$part}{$pair[0]}))
        {
          RErrorHandler->handle(0,$self,"'$pair[0]' of '$part' in '$tags[0]' redefinition -- was '".$self->{$tags[0]}{$part}{$pair[0]}."'; will be '$pair[1]'");
          RErrorHandler->handle(0,$self,"'$pair[0]' of '$part' in '$tags[1]' redefinition -- was '".$self->{$tags[1]}{$part}{$pair[0]}."'; will be '$processed'");
        }
        $self->{$tags[0]}{$part}{$pair[0]}=$pair[1];
        $self->{$tags[1]}{$part}{$pair[0]}=$processed;
      }
    }
  }
  return $self;
}

sub process
{
  my $self=shift;
  my $processed=shift;
  $processed=~s/<br>/\n/gim;
  return $processed;
}

1