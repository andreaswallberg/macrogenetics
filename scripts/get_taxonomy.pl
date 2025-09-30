#!/usr/bin/perl -w

use strict;
use warnings;
use 5.010;

my $group_table = {};
my $species_table = {};
my $taxon_table = {};

my $group_file = shift @ARGV;
my $taxon_file = shift @ARGV;

open ( my $group_in , "<" , $group_file ) or die "$!";

while (<$group_in>) {

	chomp;
	
	my @data = split ( /\t/ , $_ );
	
	my $informal_group = shift @data;
	
	my ( $kingdom , $phylum , $class , $order ) = @data;
	
	$kingdom = "" unless defined $kingdom;
	$phylum = "" unless defined $phylum;
	$class = "" unless defined $class;
	$order = "" unless defined $order;
	
	my $group = "$kingdom\t$phylum\t$class\t$order";
	
	$group_table->{ $group } = $informal_group;

}

open ( my $taxon_in , "<" , $taxon_file ) or die "$!";

my $header = <$taxon_in>;
chomp $header;

while (<$taxon_in>) {

	chomp;
	
	my @data = split ( /\t/ , $_ );
	
	my ( $kingdom , $phylum , $class , $order , $family , $genus , $subgenus , $species_ep ) = 
	@data[ 10 .. 17 ];
	
	next unless $genus =~ m/\w/;
	next unless $species_ep =~ m/\w/;
	
	$genus =~ s/\(.+//;
	$species_ep =~ s/\(.+//;
	
	my $species = "$genus $species_ep";
	
	my $group = "$kingdom\t$phylum\t$class\t$order";
	
	next unless defined $group_table->{ $group };
	
	$species_table->{ $species } = "$kingdom\t$phylum\t$class\t$order\t$family\t$genus\t$species_ep";
	
	push @{ $taxon_table->{ $group }->{ "species" } } , $species;

}

open ( my $classification_out , ">" , $taxon_file . ".classification_to_orders.tsv" ) or die "$!";
open ( my $species_out , ">" , $taxon_file . ".species.tsv" ) or die "$!";
open ( my $names_out , ">" , $taxon_file . ".species_names.tsv" ) or die "$!";
open ( my $count_out , ">" , $taxon_file . ".counts.tsv" ) or die "$!";

my $count_table = {};

say $classification_out "INFORMAL_GROUP\tN_SPECIES\tKINGDOM\tPHYLUM\tCLASS\tORDER\tSPECIES";

say $species_out "SPECIES\tINFORMAL_GROUP\tKINGDOM\tPHYLUM\tCLASS\tORDER\tFAMILY\tGENUS\tSPECIES_EPITHET";

foreach my $group ( sort keys %{ $taxon_table } ) {

	my @species_list = sort @{ $taxon_table->{ $group }->{ "species" } };

	my $informal_group = $group_table->{ $group };
	
	my $n_species = @species_list;
	
	say $classification_out "$informal_group\t$n_species\t$group\t" , join ( "\|" , @species_list );

	foreach my $species ( @species_list ) {
	
		say $species_out $species , "\t" , $informal_group , "\t" , $species_table->{ $species };
	
		say $names_out $species;
	
		$count_table->{ $informal_group }++;
	
	}
	
}

say $count_out "INFORMAL_GROUP\tN_SPECIES";

foreach my $informal_group ( sort keys %{ $count_table } ) {

	say $count_out $informal_group , "\t" , $count_table->{ $informal_group };

}
