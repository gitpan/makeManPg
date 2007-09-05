#!/usr/bin/perl
#
# Description : This script creats MAN Page for any application/program/executable by reading its --help/-? options. Man page is created in current directory unless and untill specified by -m option.
#
# Creator     : Manoj Gupta (manojkumargupta@gmail.com)
# 
# Date        : 1st Aug 2007
#
use strict;
use Getopt::Std;
my %options=();
getopt("cm",\%options); 

unless($options{c}){
print "\n\tUsage : ./makeManPg.pl -c commandName [-m manFile]\n";
exit 1;
}

$options{m}||=$options{c}.'.man';
my $executable="$options{c} --help";
#print "$executable >/dev/null 2>&1\n";
`$executable 2>&1`;
#print "$executable :   $@ --- $! --- $?\n";
if($! =~ /No such file or directory/){
print "\nError while creating Man page of $options{c} : \n";
print "\t Command : '$options{c}' : not found \n";
exit 1;
}elsif($?){
print "\t --help option not supported, proceeding with -? option\n";
$executable="$options{c} -?";
}

my $manline=".\\\" Man page for $options{c}.";
$manline.="\n.TH man 1 \"".(localtime())."\" \"1.0\" \"$options{c} man page\"\n";

open(IN,"$executable 2>&1 |");
$manline.=<IN>;
unless(open(OUT,">$options{m}")){
print "\nNot able to open '$options{m}'. Please check permission. \n\tError thrown : $? $!\n";
exit 0;
}

print OUT $manline;
while($manline=<IN>){
$manline =~ s/^Usage\s*:(.*)$/\.SH Usage:\n    $1/i; 
$manline =~ s/^(\w+?):/\.SH $1:/;
$manline =~ s/^\s+(\w+?):\s+/\.P\n\.B $1:\n    /;
$manline =~ s/^\s\s+/    /;
$manline =~ s/^\s*\-(\S+)\s+/\.P\n\.B  \-$1\n  /; 
print OUT $manline;
}
close IN;

print "Man page for '$options{c}' is created as : $options{m}\n";
print 'Try using it as  : "]$ man ./',$options{m},"\"\n";
exit 0;
