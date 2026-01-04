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
use Data::Dumper;

if ($#ARGV < 5) 
{
		&usage;
}

my $dbaseFile = "";
my %dbaseMap = ();
my @wixFiles = ();
my %wixMap = ();
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

#print Dumper (%wixMap);

open my $outFh, ">:encoding(utf8)", $outFile or die "$outFile :\t$!\n";
my $outCSV = Text::CSV->new ({
                binary => 1,
				always_quote => 1,
                auto_diag => 1 });

#my @headerLine = ( "First Name", "Last Name","Email");
#$outCSV->say($outFh, \@headerLine);

my @newEmailsArr = $newEmails->members;
for my $newEmail (sort @newEmailsArr)
{
		my $winInfoRef = $wixMap{$newEmail};
		$outCSV->say($outFh, $winInfoRef);
}

close ($outFh);

#print Dumper(%dbaseMap);

open $outFh, ">:encoding(utf8)", "dbaseMap.csv" or die "dbaseMap.csv :\t$!\n";

for my $dbaseEmail (sort keys %dbaseMap)
{
		my $arrayRef = $dbaseMap{$dbaseEmail};
		$outCSV->say($outFh, $arrayRef);
}

close ($outFh);

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
				$existingEmails->insert(lc($primaryEmail));
		}
		my $alternateEmail = $row->[26];
		if (defined($alternateEmail))
		{
				$existingEmails->insert(lc($alternateEmail));
		}
		my $firstName = $row->[1];
		my $lastName = $row->[2];

		my @mfoaID = ($firstName, $lastName, $primaryEmail);
		my $arrayRef = \@mfoaID;
		$dbaseMap{$primaryEmail} = $arrayRef;
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
				$wixEventGuestsEmails->insert(lc($primaryEmail));
		}

		my $firstName = $row->[2];
		my $lastName = $row->[3];

		my @wixInfo = ($firstName, $lastName, $primaryEmail);
		my $wixInfoRef = \@wixInfo;
		$wixMap{$primaryEmail} = $wixInfoRef;
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
			$wixEventGuestsEmails->insert(lc($primaryEmail));
		}

		my $firstName = $row->[0];
		my $lastName = $row->[1];

		my @wixInfo = ($firstName, $lastName, $primaryEmail);
		my $wixInfoRef = \@wixInfo;
		$wixMap{$primaryEmail} = $wixInfoRef;

	}
}
