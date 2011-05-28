
require RErrorHandler;

require REntityHeader;

package RHTTPHeader;

@ISA=qw{ REntityHeader };

my(%defaulthead)=('Content-Type'=>'text/html');

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
