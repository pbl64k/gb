
require RErrorHandler;

require RHash;

package REntityHeader;

@ISA=qw{ RHash };

my(%defaulthead)=();

sub create
{
  my $this=shift;
  my(%newhead)=(@_);
  undef local @_;
  my $self=($this->SUPER::create());
  if(%newhead)
  {
    $self->batch(%newhead);
  }
  else
  {
    $self->batch(%defaulthead);
  }
  return $self;
}

sub add
{
  my $self=shift;
  my $head=lc(shift);
  my $value=shift;
  if(defined($self->{$head}))
  {
    RErrorHandler->handle(0,$self,"'$head' already exists -- ignoring new value");
  }
  else
  {
    $self->{$head}=$value;
  }
}

sub replace
{
  my $self=shift;
  my $head=lc(shift);
  my $value=shift;
  if(!defined($self->{$head}))
  {
    #RErrorHandler->handle(0,$self,"'$head' does not exist -- adding instead");
    $self->add($head,$value);
  }
  else
  {
    $self->{$head}=$value;
  }
}

sub append
{
  my $self=shift;
  my $head=lc(shift);
  my $value=shift;
  if(!defined($self->{$head}))
  {
    RErrorHandler->handle(0,$self,"'$head' does not exists -- adding instead");
    $self->add($head,$value);
  }
  else
  {
    $self->{$head}.=$value;
  }
}

sub batch
{
  my $self=shift;
  my(%heads)=(@_);
  for(keys%heads)
  {
    $self->replace($_,$heads{$_});
  }
}

sub dump
{
  my $self=shift;
  my $filter=shift;
  my $header='';
  for(keys%$self)
  {
    if(!$filter||($_!~/$filter/))
    {
      $header.="$_: $self->{$_}\n";
    }
  }
  return $header;
}

1
