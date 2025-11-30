#!/usr/bin/perl
#
# Script to use CSV files exported from Wix for Event attendees, Ticket or RSVP 
# and build a CSV file in the correct format to import new users to the 
# MFOA dbase

#!/usr/bin/perl
use strict;
use warnings;

use Text::CSV;
use Getopt::Long;
