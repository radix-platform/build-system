
use File::Basename;

use strict;
use warnings FATAL => 'all';

my $path = dirname( __FILE__ );

package _kxLab;


sub distro_name
{
  my $name = "kxLab";

  open( FILE, "< $path/constants.mk" );

  while( <FILE> )
  {
    if( /^DISTRO_NAME(.+= +)(.+)/ )
    {
      $name = $2;
    }
  }
  close( FILE );

  return $name;
}

sub build_system_tmpdir
{
  return $path . "/tmp";
}

sub build_system_path
{
  return $path;
}

sub error
{
  my $message = shift;
  my $func = shift;

  print STDERR "Error: $message\n";
  if( defined( $func ) )
  {
    &$func();
  }
  exit 1;
}

sub command_error
{
  my $command = shift;
  my $context = shift;

  error( "$command failed at @{$context}[1] line @{$context}[2]" );
}

sub system
{
  my $command = shift;

  if( system( $command ) )
  {
    my @context = caller;
    command_error($command, \@context);
  }
}

1;
