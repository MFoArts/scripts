MFoA repository to store scipts that get used to manage data transfers between the different systems

Rather Ad Hoc right now but we'll need some conventions so its obvious at a glance what the scripts are for and other useful informnation

# create_db_users_from_wix.pl

Script to take files from the Wix system containing Event guests who bought tickets or RSVP's and compare to the list of users in the MFoA database to flag any users to add to the dbase for future outreach / marketing

## Usage

>create_db_users_from_wix.pl -dbase <CSV file export of the current MFoA users> -wixfiles <list of CSV or text files exported from all Wix events in the festival year> -o <Output CSV file containing potential new accounts to add>

