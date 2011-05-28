
require RErrorHandler;

require RHash;

require DBI;

package RDataBase;

@ISA=qw{ RHash };

my $connection='_CONNECTION';
my $statements='_STATEMENTS';
my $operator='_OPERATOR';
my $interface='interface';
my $driver='driver';
my $database='database';
my $username='username';
my $password='password';

sub create
{
  my $this=shift;
  my $self=($this->SUPER::create(@_));
  $self->{$connection}=DBI->connect($self->{$interface}.':'.$self->{$driver}.':'.$self->{$database},$self->{$username},$self->{$password});
  $self->{$statements}={};
  return $self;
}

sub bindplainstatement
{
  my $self=shift;
  my $name=shift;
  my $statement=shift;
  ($self->{$statements}{$name}=RStatement->create($operator=>$statement))->prepare($self->{$connection});
}

sub bindstatement
{
  my $self=shift;
  my $name=shift;
  my $filename=shift;
  ($self->{$statements}{$name}=RStatement->load($filename))->prepare($self->{$connection});
}

package RStatement;

@ISA=qw{ RHash };

my $operator='_OPERATOR';
my $row='_ROW';
my $handle='_HANDLE';
my $result='_RESULT';

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
  $self->{$operator}=<FILE>;
  return $self;
}

sub prepare
{
  my $self=shift;
  my $connection=shift;
  $self->{$handle}=$connection->prepare($self->{$operator});
}

sub execute
{
  my $self=shift;
  $self->{$result}=$self->{$handle}->execute(@_);
}

sub fetchrow
{
  my $self=shift;
  my $rowarrayref=$self->{$handle}->fetchrow_arrayref;
  $self->{$row}={};
  if(@$rowarrayref)
  {
    for(0..$#$rowarrayref)
    {
      (my $override=$self->{$handle}{mysql_table}[$_])=~s/^(#?sql.*?)?$/__SQL__/i;
      $self->{$row}{$override}{$self->{$handle}{NAME}[$_]}=${$rowarrayref}[$_];
    }
    return 1;
  }
  else
  {
    return 0;
  }
}

1
