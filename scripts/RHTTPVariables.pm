
require RErrorHandler;

require RHash;

package RHTTPVariables;

@ISA=qw{ RHash };

my $commontypes=2;
my $specifictypes=3;
# common types, specific types, specific arrays
my(@types)=qw{ ALL ARRAY GET POST COOKIE ARRAY_GET ARRAY_POST ARRAY_COOKIE };

sub create
{
  my $this=shift;
  my $self=($this->SUPER::create());
  return $self;
}

sub load
{
# Currently in GPC order -- easily modifiable

  my $this=shift;
  my $filename=shift;
  my $self=($this->SUPER::create());
  $self->{$types[0]}={};
  $self->{$types[1]}={};

# G-processing
  my $query=$ENV{QUERY_STRING};
  $self->process($commontypes+0,$query);

# P-processing
  if($ENV{REQUEST_METHOD}eq'POST')
  {
    read(STDIN,$query,$ENV{'CONTENT_LENGTH'});
    $self->process($commontypes+1,$query);
  }

# C-processing
  $query=$ENV{HTTP_COOKIE};
  $query=~s/; /&/g;
  $self->process($commontypes+2,$query); 
  return $self;
}

sub process
{
  my $self=shift;
  my $type=shift;
  my $query=shift;
  $self->{$types[$type]}={};
  for(split(/&/,$query))
  {
    my @pair=split(/=/,$_,2);
    $pair[1]=~y/+/ /;
    $pair[1]=~s/%([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg;
    if(exists($self->{$types[0]}{$pair[0]}))
    {
      RErrorHandler->handle(0,$self,"'$pair[0]' in '$types[0]' redefinition -- was '$self->{$types[0]}{$pair[0]}'; will be '$pair[1]'. Malicious user attack possible! Multiple values available in '$types[1]'.");
    }
    else
    {
      $self->{$types[1]}{$pair[0]}=();
    }
    $self->{$types[0]}{$pair[0]}=$pair[1];
    push(@{$self->{$types[1]}{$pair[0]}},$pair[1]);
    if(exists($self->{$types[$type]}{$pair[0]}))
    {
      RErrorHandler->handle(0,$self,"'$pair[0]' in '$types[$type]' redefinition -- was '$self->{$types[$type]}{$pair[0]}'; will be '$pair[1]'. Malicious user attack possible! Multiple values available in '".$types[$type+$specifictypes]."'.");
    }
    else
    {
      $self->{$types[$type+$specifictypes]}{$pair[0]}=();
    }
    $self->{$types[$type]}{$pair[0]}=$pair[1];
    push(@{$self->{$types[$type+$specifictypes]}{$pair[0]}},$pair[1]);
  }
}

1
