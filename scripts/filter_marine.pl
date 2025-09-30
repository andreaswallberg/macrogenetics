#!/usr/bin/perl -w

use strict;
use warnings;
use 5.010;

my $profile_table = {};

open ( my $profile_in , "<" , $ARGV[ 0 ] ) or die "$!";

my $header = <$profile_in>;
chomp $header;

open ( my $profile_out , ">" , $ARGV[ 0 ] . ".marine.tsv" ) or die "$!";

say $profile_out $header;

while (<$profile_in>) {

	chomp;
	
	if ( $_ =~ m/^(\S+)\t1/ ) {
	
		$profile_table->{ $1 } = 1;
	
		say $profile_out $_;
	
	}

}

open ( my $taxa_in , "<" , $ARGV[ 1 ] ) or die "$!";

$header = <$taxa_in>;
chomp $header;

open ( my $taxa_out , ">" , $ARGV[ 1 ] . ".marine.species.accepted.valid.tsv" ) or die "$!";
open ( my $taxa_s_out , ">" , $ARGV[ 1 ] . ".marine.species.tsv" ) or die "$!";

say $taxa_out $header;
say $taxa_s_out $header;

while (<$taxa_in>) {

	chomp;
	
	if ( $_ =~ m/^(\S+)\t/ ) {
	
		my $id = $1;
	
		if ( defined $profile_table->{ $id } and $_ =~ /\tSpecies\t/ ) {
	
			say $taxa_s_out $_;
		
			if ( $_ =~ /valid/ and $_ =~ /accepted/ ) {
			
				say $taxa_out $_;
			
			}
		
		}
	
	}

}
