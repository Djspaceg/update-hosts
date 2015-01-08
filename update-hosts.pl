#!/usr/bin/perl
### By Blake Stephens #####################################
use strict;
use warnings;


## Set the path to your hosts file
my $hosts_path = '/etc/hosts';
## A block of hostnames to mac addresses
my %ADDRESSES = qw(
	sctv	b0:10:a0:70:e0:1
	sftv	b0:10:a0:70:e0:3
);
## Optional: domain name to apply to each hostname
my $domain = '';


### CODE ##################################################

main();

exit;

### SUBS ###

sub main {
	my $found = 0;

	# do an arp lookup on each MAC address
	my @Records = `arp -a`;

	# loop through all address keys
	foreach my $host (sort keys %ADDRESSES) {
		my $mac = $ADDRESSES{$host};
		foreach my $line (@Records) {
			# if it's successful,
			if ($line =~ /\((\d+\.\d+\.\d+\.\d+)\) at $mac on/) {

				# backup hosts file before starting
				if (!$found) {
					system('cp', $hosts_path, $hosts_path .'.backup');
					print "Backup file created at $hosts_path.backup\n". '-'x30 ."\n";
				}

				# add it to the hosts file
				print "Found $host at $1 via MAC address\n";
				addToHosts($host, $1);
				$found++;
			}
		}
	}

	printf("%d Addresses Found.\n", $found);
	if ($found) {
		printf("\nUpdated hosts file below:\n%s\n", '-'x30);
		system('cat', $hosts_path);
	}
}

# modify hosts file
sub addToHosts {
	my $hostname = shift();
	my $ip = shift();
	my $hosts_path_new = $hosts_path .'.new';
	# build hosts line
	my $host_line = sprintf('%-15s %s %s'."\n", $ip, $hostname .'.'. ($domain || 'local'), $hostname);

	# open file for reading
	open(my $in,  '<', $hosts_path) or die "Can't read $hosts_path file: $!";
	open(my $out, '>', $hosts_path_new) or die "Can't write $hosts_path_new file: $!";

	my $found = 0;
	# search file for hostname
	while( <$in> ) {
		# if its found, replace that line with a fresh new line
		if (!/^#/ and /\s$hostname(\s|$)/) {
			print $out $host_line;
			$found++;
		} else {
			print $out $_;
		}
	}

	# if not, append to the end of the file
	print $out $host_line unless ($found);

	# close the file
	close($in);
	close($out);

	system('mv', $hosts_path_new, $hosts_path);
}
