#!/usr/bin/perl -w

use strict;
use warnings;
use 5.010;

my $species_table = {};

while (<>) {

	chomp;
	
	$species_table->{ $_ } = 1;

}

foreach my $species ( sort keys %{ $species_table } ) {

	say $species;

}
