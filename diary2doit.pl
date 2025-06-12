#!/usr/bin/perl
#
# Converts text file from SeismicityDiary extractFromSpreadsheets.pl to doit file
# Use as part of pipes, ie
# $ ./extractFromSpreadsheet.pl | grep Irish | diary2doit.pl > doit.sh
#
# R.C. Stewart 2022-12-07
#
use strict;
use warnings;

print '#!/usr/bin/bash', "\n";

#my $command = '/home/seisan/bin/fetchPlot.py';
my $command = '/home/seisan/bin/getnPlot';
my $options0 = "";
my $options1 = '--source auto --dir /home/seisan/tmp--DONT_USE --pre 60 --dur 180';
#if ( $#ARGV >= 0 ) {
#    my $options0 = join(" ", @ARGV);
#}
#if (index($options0, '--pre') == -1) {
#    $options1 = join( ' ', $options1, '--pre 60' );
#}
#if (index($options0, '--dur') == -1) {
#    $options1 = join( ' ', $options1, '--dur 60' );
#}

while (<>) {
    my $eventDate = substr( $_, 0, 10 );
    my $eventTime = substr( $_, 11, 10 );
    my $eventTag = substr( $_, 25, 38 );
    $eventTag =~ s/^\s+|\s+$//;
    $eventTag =~ s/\s/_/g;
    $eventTag =~ s/\//_/g;
    my $options2 = join( ' ', '--date', $eventDate, '--time', $eventTime, '--tag', $eventTag );
    print join( ' ', $command, $options0, $options1, $options2), "\n";
}

