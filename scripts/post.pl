#!/devel/perl/bin/perl
#!/usr/bin/perl
#!C:\Pavel\Web\Perl\Bin\Perl

$me='post';

use RErrorHandler;

use RConfiguration;
use RHTTPVariables;
use RHTTPHeader;
use RTemplate;
use RDataBase;

my $cf=RComplexPlainTextConfiguration->load('../configuration/gastbuch.cf');

my $vars=RHTTPVariables->load;
my $head=RHTTPHeader->create;

my $tpl=RTemplate->load('../templates/'.$me.'_goback.tpl.html');
my $permden=RTemplate->load('../templates/'.$me.'_permden.tpl.html');
my $ok=RTemplate->load('../templates/'.$me.'_ok.tpl.html');

my $db=RDataBase->create(%{$cf->{NORMAL}{db}});
$db->bindstatement('authorize','../queries/'.$me.'_authorize.sql');
$db->bindstatement('add','../queries/'.$me.'_add.sql');
$db->{_STATEMENTS}{authorize}->execute($vars->{ARRAY_POST}{login}[0],$vars->{ARRAY_POST}{password}[0]);

my $body='';
if($db->{_STATEMENTS}{authorize}->fetchrow)
{
  my @ubyb=(
"oi",
  );

  ($subj=$vars->{ARRAY_POST}{subject}[0])=~s/&/&amp;/g;
  $subj=~s/</&lt;/g;
  $subj=~s/>/&gt;/g;
  ($msg=$vars->{ARRAY_POST}{message}[0])=~s/&/&amp;/g;
  $msg=~s/</&lt;/g;
  $msg=~s/>/&gt;/g;
  $msg=~s/\n/\n<br>/gm;
#  $msg=~s|_(\S+?)_|<u>$1</u>|g;
#  $msg=~s|\\(\S+?)\\|<i>$1</i>|g;
#  $msg=~s|\*(\S+?)\*|<b>$1</b>|g;
  $msg=~s{(http|ftp)(://)((\S)*)(,|\.|:|\?|\!|\s|\r|\n)?}{<a href="$1$2$3">$1$2$3</a>$5}g;
  $msg=~s{(([a-zA-Z0-9]|\.|_|\-)*)(\@)(([a-zA-Z0-9]|\.|_|\-)*)(,|\.|:|\?|\!|\s|\r|\n)?}{<a href="mailto:$1$3$4">$1$3$4</a>$6}g;

  if($vars->{ARRAY_POST}{mode1}[0])
  {
    $msg=~s/because/bicoz/gi;
    $msg=~s/Because/Bicoz/gi;
    $msg=~s/BECAUSE/BICOZ/gi;
    $msg=~s/good/oisam/gi;
    $msg=~s/Good/Oisam/gi;
    $msg=~s/GOOD/OISAM/gi;
    $msg=~s/(\,\s+)/", ".$ubyb[int(rand($#ubyb))]."$1"/egi;
    $subj=~s/because/bicoz/gi;
    $subj=~s/Because/Bicoz/gi;
    $subj=~s/BECAUSE/BICOZ/gi;
    $subj=~s/good/oisam/gi;
    $subj=~s/Good/Oisam/gi;
    $subj=~s/GOOD/OISAM/gi;
    $subj=~s/(\,\s+)/", ".$ubyb[int(rand($#ubyb))]."$1"/egi;
  }

  if($vars->{ARRAY_POST}{mode2}[0])
  {
    # mode 2 is really beyond my ability in English.
  }

  if($vars->{ARRAY_POST}{mode3}[0])
  {
    $subj=~y/Rr/Ll/;
    $msg=~y/Rr/Ll/;
  }

  if($vars->{ARRAY_POST}{filosofiryn}[0])
  {

# accept following characters:
my$filter='abcdefghijklmnopqrstuvwxyz'.
          ' .,:;-!?';
my@filter=split//,$filter;

# upper case
my$uc='ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
      ' .,:;-!?';
my @uc=split//,$uc;

# letters only
my$letters='abcdefghijklmnopqrstuvwxyz';
my@letters=split//,$letters;

# length
my$len;

# read by char
#$/=\1;
# stand-alone version only #

my%freq;
my@result;

#
my@msg=split//,$msg;
my$cnt=0;
# web version only #

do{$aa=$a=$msg[$cnt++];$a=~s/\n/ /;$a=~tr/A-Z/a-z/;}while((index($filter,$a)<0)&&$msg[$cnt]);$len++;
do{$bb=$b=$msg[$cnt++];$b=~s/\n/ /;$b=~tr/A-Z/a-z/;}while((index($filter,$b)<0)&&$msg[$cnt]);$len++;
while($_=$msg[$cnt++])
{
  s/\n/ /;
  tr/A-Z/a-z/;
  next if(index($filter,$_)<0);
  $freq{$a}{$b}{$_}++;
  $a=$b;$b=$_;
  $len++;
}

$result[++$#result]=$aa;
$result[++$#result]=$bb;
$len--;
while(--$len)
{
  my$total,$gadzook;
  for(sort keys%{$freq{$result[$#result-1]}{$result[$#result]}})
  {
    $total+=$freq{$result[$#result-1]}{$result[$#result]}{$_};
  }
  $gadzook=int(rand($total));
  $total=0;
Z:for(sort keys%{$freq{$result[$#result-1]}{$result[$#result]}})
  {
    $total+=$freq{$result[$#result-1]}{$result[$#result]}{$_};
    if($total>$gadzook)
    {
      $result[++$#result]=$_;
      last Z;
    }   
  }
}
$result[++$#result]='.';
my$rs=join'',@result;

$rs=~s/^\s+//;
$rs=~s/\s+/ /g;
$rs=~s/([\.\!\?]\s|^)(.)/$1.$uc[index($letters,$2)]/eg;

    $msg=$rs;  
  }

  $db->{_STATEMENTS}{add}->execute($db->{_STATEMENTS}{authorize}{_ROW}->{users}{id},$subj,$msg);
  $body=$ok->process;
}
else
{
  $body=$permden->process;
}

print $head->dump."\n";

print $tpl->process(__BODY__=>$body,__GOBACK__=>$ENV{HTTP_REFERER});

1
