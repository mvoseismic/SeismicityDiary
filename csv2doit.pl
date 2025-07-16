#!/usr/bin/perl
#
# Converts SeismicityDiary.csv to doit file
# Use as part of pipes, ie
# $ cat SeismicityDiary.csv | grep "Q experiment" | csv2doit.pl > doit.sh
#
# R.C. Stewart 2022-12-07
#
use strict;
use warnings;

print '#!/usr/bin/bash', "\n";

#my $command = '/home/seisan/bin/fetchPlot.py';
my $command = '/home/seisan/bin/getnPlot';
my $options0 = "";
my $options1 = '--source auto --dir /home/seisan/tmp--DONT_USE/seismicityDiary --pre 60 --dur 180';
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
    my @bits = split( ',', $_ );
    my $eventDateTime = $bits[1];
    my $eventTag = $bits[2];
    @bits  = split ( ' ', $eventDateTime );
    my $eventDate = $bits[0];
    my $eventTime = $bits[1];
    my $options2 = join( ' ', '--date', $eventDate, '--time', $eventTime, '--tag', $eventTag );
    print join( ' ', $command, $options0, $options1, $options2), "\n";
}

