#!/usr/bin/perl
### By Blake Stephens #####################################
use strict;
use warnings;
use IO::Socket::INET;
use Net::Ping;

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

my $my_ip_address = '';
main();

exit;

### SUBS ###

sub main {
	my $found = 0;

	# tickle the subnet to wake it up and look up everything on the local network.
	# tickleSubnet();
	pingEverybody();

	# do an arp lookup on each MAC address
	my @Records = `arp -a`;

	# loop through all address keys
	foreach my $host (sort keys %ADDRESSES) {
		my $mac = $ADDRESSES{$host};
		printf("MAC Address to find: %s\n", $mac);
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

sub tickleSubnet {
	my $ip = get_local_ip_address();
	(my $subnet = $ip) =~ s/\d+$/255/;

	system('ping', '-r', '-c', 2, $subnet);
}

sub pingEverybody {
	my $ip = get_local_ip_address();
	(my $base_subnet = $ip) =~ s/\d+$//;
	for (my $i = 0; $i < 255; $i++) {
		# print `ping -c 1 $base_subnet$i | grep -B 1 "Lost = 0" &`;
		# print `ping -c 1 -W 400 $base_subnet$i | grep -B 1 "1 packets received" &`;
		# print `ping -c 1 -W 4 $base_subnet$i`;
		my $host = "$base_subnet$i";
		my $p = Net::Ping->new('icmp');
		print "\nPinging host $host";
		$p->ping($host,1);
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

# This idea was stolen from Net::Address::IP::Local::connected_to()
# And stolen again from http://stackoverflow.com/questions/330458/how-can-i-determine-the-local-machines-ip-addresses-from-perl
# written by tstanton
sub get_local_ip_address {
	return $my_ip_address if ($my_ip_address);

	my $socket = IO::Socket::INET->new(
		Proto       => 'udp',
		PeerAddr    => '8.8.4.4', # Google's public DNS
		PeerPort    => '53', # DNS
	);

	# A side-effect of making a socket connection is that our IP address
	# is available from the 'sockhost' method
	$my_ip_address = $socket->sockhost;

	return $my_ip_address;
}
