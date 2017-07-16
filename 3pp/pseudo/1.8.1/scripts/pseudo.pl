#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Basename;
use File::Spec;

my $program = basename( $0 );
my ($pseudo_prefix, $enable_op_logging, $shell, @options, $opts, $commands, $cmd);

sub usage
{
  print <<EOF;

Usage: $program <shell> <shell_options> <command_string>
Where:
          shell - command intepreter {sh,/bin/sh,/bin/bash};
  shell_options - shell options list,  last should be '-c' ;
 command_string - command string to be interpreted by shell.

EOF
  exit 1;
}


my $path = File::Spec->rel2abs(dirname( __FILE__ ));
my $enable_pseudo_logging = $ENV{'ENABLE_PSEUDO_LOGGING'};

$pseudo_prefix = $path . "/../usr" ;
$enable_op_logging = "";

if( defined( $enable_pseudo_logging ) && $enable_pseudo_logging eq "yes" )
{
  $enable_op_logging = "-l";
}


# Parse the command line options:
#
$shell = shift;
foreach ( @ARGV )
{
  if( /--help/ ) { usage; }
  else           { push @options, $_; }
}
$commands = pop @options;

# Check options:
#
if( !defined($shell) || !defined($commands) ) { usage; }

$opts = "";
if( @options )
{
  foreach ( @options )
  {
    if( substr( $_, 0, 1) ne "-" ) { usage; }
    $opts = $opts . " $_";
  }
}
else
{
  usage;
}


# add backslash before each '"':
#
$commands =~ s/([\"])/\\$1/xg;

# remove extra horizontal spaces:
#
$commands =~ s/\h+/ /g;

$cmd  = $pseudo_prefix . "/bin/pseudo";
$cmd .=    " " . $enable_op_logging;
$cmd .= " -P " . $pseudo_prefix ;
$cmd .=    " " . $shell . $opts ;
$cmd .=   ' "' . $commands . '"';

system( $cmd );

if( $? == 0 ) { exit 0; }
else          { exit 1; }
