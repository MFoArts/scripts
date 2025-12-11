#!/usr/bin/perl
#
# Script to use CSV files exported from Wix for Event attendees, Ticket or RSVP 
# and build a CSV file in the correct format to import new users to the 
# MFOA dbase

use strict;
use warnings;

use Text::CSV;
use Getopt::Long;
use Set::Scalar;

my $dbaseFile = "";
my @wixFiles = ();
my $outFile = "";

GetOptions(	'dbaseFile|db=s'	=> \$dbaseFile,
			'wixFiles|wf=s{,}'		=> \@wixFiles,
			'outFile|o=s'		=> \$outFile);

#print "Dbase file:\t$dbaseFile\nOut File:\t$outFile\n";
#for my $wixFile (@wixFiles) { print "Wix File:\t$wixFile\n"; }
