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

if ($#ARGV < 5) 
{
		&usage;
}

my $dbaseFile = "";
my @wixFiles = ();
my $outFile = "";

GetOptions(	'dbaseFile|db=s'	=> \$dbaseFile,
			'wixFiles|wf=s{,}'		=> \@wixFiles,
			'outFile|o=s'		=> \$outFile)
or die("Error in command line arguments\n");


# Read/parse CSV files from the MFoA dbase and Wix
my $mfoaCSV = Text::CSV->new ({ 
				sep => "\",\"",
				binary => 1, 
				auto_diag => 1,
				quote_char => '\\'
				});
my $existingEmails = Set::Scalar->new();
&inputMFoADbase;


my $wixGuestCSV = Text::CSV->new ({ 
				sep => "\t",
				binary => 1, 
				auto_diag => 1 });
my $wixEventGuestsEmails = Set::Scalar->new();
for my $wixFile (@wixFiles)
{
	&inputWixGuests($wixFile);
}

my $newEmails = $wixEventGuestsEmails - $existingEmails;
print "$newEmails\n";

#
#----------------------------------------------------------------------
#----------------------------------------------------------------------
#----------------------------------------------------------------------
#
sub usage
{
		print "Usage: $0\n -dbaseFile <Exported MFoA account users as CSV> -wixFiles <Wix ticket buyers or RSVP respondents exported from Wix Events> -outFile <CSV file formatted for import into the MFoA dbase with the new users from Wix>";
		exit 1;
}

sub inputMFoADbase 
{
	open my $mfoafh, $dbaseFile or die "$dbaseFile: $!";

	my $headerLine = $mfoaCSV->getline ($mfoafh);

	while (my $row = $mfoaCSV->getline ($mfoafh)) {
		my $primaryEmail = $row->[9];
		if (defined($primaryEmail))
		{
				$existingEmails->insert($primaryEmail);
		}
		my $alternateEmail = $row->[26];
		if (defined($alternateEmail))
		{
				$existingEmails->insert($alternateEmail);
		}
	}
	close $mfoafh;
}

sub inputWixGuests
{
	my ($wixFile) = @_;
	open my $Wixfh, $wixFile or die "$wixFile $!";

	my $headerLine = $wixGuestCSV->getline ($Wixfh);

	my $firstHeaderColumn = $headerLine->[0];
	if ($firstHeaderColumn =~ /Order number/)
	{
			&inputWixPurchase($Wixfh);
	}
	elsif ($firstHeaderColumn =~ /First name/)
	{
			&inputWixRSVP($Wixfh);
	}
	else
	{
			print "Unknown file type\n";
	}

	close $Wixfh;
}

sub inputWixPurchase
{
	my ($fh) = @_;
	while (my $row = $wixGuestCSV->getline ($fh))
	{
		my $primaryEmail = $row->[4];
		if (defined($primaryEmail))
		{
				$wixEventGuestsEmails->insert($primaryEmail);
		}
	}
}

sub inputWixRSVP
{
	my ($fh) = @_;
	while (my $row = $wixGuestCSV->getline ($fh)) 
	{
		my $primaryEmail = $row->[2];
		if (defined($primaryEmail))
		{
			$wixEventGuestsEmails->insert($primaryEmail);
		}
	}
}
