
require RErrorHandler;

require RHash;

package RTemplate;

@ISA=qw{ RHash };

my $template='_TEMPLATE';
my $prefix='<!--';
my $postfix=' -->';

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
  undef local $/;
  $self->{$template}=<FILE>;
  return $self;
}

sub process
{
  my $self=shift;
  my(%vars)=(@_);
  ($result=$self->{$template})=~s|$prefix(.*?)$postfix|"\x24vars$1"|eeg;
  return $result;
}

1