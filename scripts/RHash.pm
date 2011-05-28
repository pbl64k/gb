
require RErrorHandler;

package RHash;

sub create
{
  my $this=shift;
  my $class=ref($this)||$this;
  my(%init)=(@_);
  my $self=%init?\%init:{};
  bless $self,$class;
  return $self;
}

1