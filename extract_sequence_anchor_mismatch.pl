#!/usr/bin/perl

# Edward Romasko - 13Mar2015
#
# Purpose:
# Extracts nucleotide sequence between two 12bp fixed anchors while 
# allowing up to 2bp of mismatches due to PCR mutation/sequencing error,
# in the form of mutation, insertion, or deletion.
#
# Arguments: 
# 1) Input text file containing database of sequences (with front anchor, internal sequence, back anchor) on separate lines
# 2) Input text file containing 12bp anchor to be searched for within the database
# 3) Output text file to store sequence extracted from between the identified 12bp anchors

use strict;
use warnings;

(my $database_filename, my $anchor_filename, my $output_filename) = @ARGV;

unless (open(DBFILE, $database_filename)) {
	print "File \"$database_filename\" doesn\'t open!\n";
	exit;
}
unless (open(ANCHORFILE, $anchor_filename)) {
	print "File \"$anchor_filename\" doesn\'t open!\n";
	exit;
}

my $anchor = <ANCHORFILE>;
close ANCHORFILE;
chomp $anchor;

while (<DBFILE>) {	
	my $line = $_;
	chomp $line;
	my $len = length $line;
	my $front_anchor = substr($line, 0, 12); # Extract first 12bp of sequence line as front anchor
	my $back_anchor = substr($line, -12, 12); # Extract last 12bp of sequence line as back anchor
	
	# Bitwise XOR comparison between strings, then regular expression matching of non-NULL characters (which indicate differences),
	# and counting/storing the number of differences
	my $mismatches_front = () = ( $anchor ^ $front_anchor ) =~ /[^\x00]/g;
	my $mismatches_back = () = ( $anchor ^ $back_anchor ) =~ /[^\x00]/g;
	
	########## Printing out results to screen as going through database sequences
	print "Line length: $len\n";
	print "Front anchor: $front_anchor\n";
	print "Front anchor mismatches: $mismatches_front\n";
	print "Back anchor: $back_anchor\n";
	print "Back anchor mismatches: $mismatches_back\n";
	##########
	
	if (($mismatches_front <= 1) and ($mismatches_back <= 1)) { # If there are <= 2 mismatches in both anchors, extract internal sequence and send to output file
		my $extracted_sequence_len = $len - 24;
		my $extracted_sequence = substr($line, 12, $extracted_sequence_len);
		##########
		print "Extracted sequence length: $extracted_sequence_len\n";
		print "Extracted sequence: $extracted_sequence\n";
		##########
		if (open(OUTPUTFILE, $output_filename)) {
			open(OUTPUTFILE, ">>", $output_filename); # File already exists; results will be appended to end of file
			print OUTPUTFILE $extracted_sequence,"\n";
		} 
		else {
			open(OUTPUTFILE, ">", $output_filename); # File does not exist yet; create it using name entered as command-line parameter
			print OUTPUTFILE $extracted_sequence,"\n";
		}
		close OUTPUTFILE;
	}
}


	
	
	
	
