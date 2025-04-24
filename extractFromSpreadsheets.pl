#!/usr/bin/perl
#
# Creates prose from various spreadsheets
# R.C. Stewart, 2022-09-07

use 5.016;
use strict;
use warnings;
use Env;
use Spreadsheet::Read qw(ReadData);
use Scalar::Util qw(looks_like_number);
use DateTime::Format::Excel;
use Time::HiRes qw(time);
use POSIX qw(strftime);

my %whats;
my %wheres;
my %whatswheres;
my %durations;
my %comments;
my %ids;
my %trigs;
my %firsts;
  
# Get setup info
my @setup = split '\|', `setupGlobals`;

# Seismic Info
#
my $fileData ="./SeismicityDiary.xlsx";
#if( $setup[3] eq 'MVO' ) {
#    $fileData = '/mnt/mvofls2/Seismic_Data/monitoring_data/seismic/seismicinfo.xlsx';
#} elsif( $setup[3] eq 'travelling' ) {
#    $fileData = '/media/stewart/Travelling/monitoring_data/seismic/seismicinfo.xlsx';
#}

# Fetching all file contenti
my $book_data = ReadData( $fileData );

# Read rows for VT strings
my @rowsmulti = Spreadsheet::Read::rows($book_data->[1]);
foreach my $m (1 .. scalar @rowsmulti) {

    my $what = $rowsmulti[$m-1][11];
    $what = '' unless( $what );

    my $where = '';

    my $id = $rowsmulti[$m-1][0];
    $id = '' unless( $id );

    my $staFirst = $rowsmulti[$m-1][16];
    $staFirst = '' unless( $staFirst );

    my $datimFirst = $rowsmulti[$m-1][1];
    $datimFirst = '' unless( $datimFirst );

    if( looks_like_number($datimFirst) ){
        my $datetime = DateTime::Format::Excel->parse_datetime( $datimFirst );
        $datimFirst = $datetime-> strftime('%Y-%m-%d %H:%M:%S.%1N');
    }

    #    print $id, " : ", $datimFirst, " : ", $what, "\n";

    my $idDatim = $datimFirst;
    if( $idDatim eq '' ) {
        if( $id ne '' ) {
            $idDatim = join( ' ', join( '-', substr($id,0,4), substr($id,4,2), substr($id,6,2) ), join( ':', substr($id,9,2), substr($id,11,2) ) );
       } 
    }
    my $dur = $rowsmulti[$m-1][2];
    $dur = '' unless( $dur );
    my $duration = '';
    if( $dur ne '' ) {
        $duration = sprintf( '%8.1fm', $dur );
        $duration =~ s/^\s+//;
    }

    my $comment = $rowsmulti[$m-1][36];
    $comment = '' unless( $comment );

    #print $id, " :: ", $idDatim, " :: ", $what, "\n";
    
    if( substr($idDatim,0,1) eq '2' or substr($idDatim,0,1) eq '1' ) {
        if (exists $whats{$idDatim}) {
            printf "CAUTION: key %s already exists\n", $idDatim;
        }
        $ids{$idDatim} = $id;
        $whats{$idDatim} = $what;
        $wheres{$idDatim} = $where;
        $durations{$idDatim} = $duration;
        $comments{$idDatim} = $comment;
        $firsts{$idDatim} = $staFirst;
        $trigs{$idDatim} = '';
        if( $where ne '' ){
            $whatswheres{$idDatim} = join( ', ', $what, $where );
        } else {
            $whatswheres{$idDatim} = $what;
        }
    }
}


# Events
#
@rowsmulti = Spreadsheet::Read::rows($book_data->[3]);
foreach my $m (1 .. scalar @rowsmulti) {

    my $what = $rowsmulti[$m-1][2];
    $what = '' unless( $what );

    my $id = $rowsmulti[$m-1][0];
    $id = '' unless( $id );

    my $datimFirst = $rowsmulti[$m-1][1];
    $datimFirst = '' unless( $datimFirst );

    my $staFirst = $rowsmulti[$m-1][7];
    $staFirst = '' unless( $staFirst );

    if( looks_like_number($datimFirst) ){
        my $datetime = DateTime::Format::Excel->parse_datetime( $datimFirst );
        $datimFirst = $datetime-> strftime('%Y-%m-%d %H:%M:%S.%1N');
    }

    #print $id, " : ", $datimFirst, " : ", $what, "\n";

    my $trig = $rowsmulti[$m-1][4];
    $trig = '' unless( $trig );

    my $idDatim = $datimFirst;
    if( $idDatim eq '' ) {
        if( $id ne '' ) {
            $idDatim = join( ' ', join( '-', substr($id,0,4), substr($id,4,2), substr($id,6,2) ), join( ':', substr($id,9,2), substr($id,11,2) ) );
        } 
    }

    my $duration = $rowsmulti[$m-1][5];
    $duration = '' unless( $duration );

    my $where = $rowsmulti[$m-1][3];
    $where = '' unless( $where );

    my $fps = $rowsmulti[$m-1][10];
    $fps = '' unless( $fps );

    my $reftime = $rowsmulti[$m-1][11];
    $reftime= '' unless( $reftime);

    my $mag = $rowsmulti[$m-1][12];
    $mag = '' unless( $mag );

    my $confirmed = $rowsmulti[$m-1][13];
    $confirmed = '' unless( $confirmed );

    my $comment = $rowsmulti[$m-1][14];
    $comment = '' unless( $comment);

    if( $confirmed ne '' ){
        $comment = join( '. ', 'Confirmed location', $comment );
    }

    if( substr($idDatim,0,1) eq '2' or substr($idDatim,0,1) eq '1' ) {
        if (exists $whats{$idDatim}) {
            printf "CAUTION: key %s already exists\n", $idDatim;
        }
        $ids{$idDatim} = $id;
        $whats{$idDatim} = $what;
        $wheres{$idDatim} = $where;
        $durations{$idDatim} = $duration;
        $firsts{$idDatim} = $staFirst;
        if( $mag ne '' ){
	        $comment = join( ' : ', join( '', 'M', $mag ), $comment );
        }
        if( $fps ne '' ){
	        $comment = join( ' : ', 'FPS', $comment );
        }
	    $comments{$idDatim} = $comment;
        $trigs{$idDatim} = $trig;
        if( $where ne '' ){
            $whatswheres{$idDatim} = join( ', ', $what, $where );
        } else {
            $whatswheres{$idDatim} = $what;
        }
    }
}


# Network
#
@rowsmulti = Spreadsheet::Read::rows($book_data->[8]);
foreach my $m (1 .. scalar @rowsmulti) {

    my $what = $rowsmulti[$m-1][1];
    $what = '' unless( $what );

    my $id = $rowsmulti[$m-1][0];
    $id = '' unless( $id );

    #print $id, " : ", $what, "\n";

    my $comment = $rowsmulti[$m-1][2];
    $comment = '' unless( $comment );

    my $idDatim = join( ' ', join( '-', substr($id,0,4), substr($id,4,2), substr($id,6,2) ), join( ':', substr($id,9,2), substr($id,11,2) ) );

    #print $id, " :: ", $idDatim, " :: ", $what, "\n";
    
    if( substr($idDatim,0,1) eq '2' or substr($idDatim,0,1) eq '1' ) {
        if (exists $whats{$idDatim}) {
            printf "CAUTION: key %s already exists\n", $idDatim;
        }
        $ids{$idDatim} = $id;
        $whats{$idDatim} = $what;
        $wheres{$idDatim} = '';
        $durations{$idDatim} = '';
        $firsts{$idDatim} = '';
        $comments{$idDatim} = $comment;
        $trigs{$idDatim} = '';
        $whatswheres{$idDatim} = $what;
    }
}



# output
my $outRun = 'doIt.sh';
open(FHR, '>', $outRun) or die $!;

my $outFile = 'SeismicityDiary.txt';
open(FH, '>', $outFile) or die $!;

open(HFH,'>','SeismicityDiary.html');
print HFH "<!DOCTYPE html>\n<HTML>\n<HEAD>\n<TITLE>Seismicity Diary</TITLE>\n";
print HFH "<style>\n";
print HFH "table, th, td {\n";
print HFH "  padding-top: 5px;\n";
print HFH "  padding-bottom: 5px;\n";
print HFH "  padding-left: 10px;\n";
print HFH "  padding-right: 10px;\n";
#print HFH "  border: 1px solid black;\n";
#print HFH "  border-collapse: collapse;\n";
#print HFH "  height:50px;\n";
print HFH "}\n";
print HFH "</style>\n";
print HFH "</HEAD>\n<BODY>\n";
print HFH "<TT>\n";
print HFH "<B>Seismicity Diary</B><BR>\n";
print HFH "<EM>This is complete from 2020 onwards. <BR>Except for lahars, which are complete from 2021 onwards.<BR>Except for stations, which are complete from late 2022.</EM><BR>\n";

print HFH "<TABLE>\n";

#my $pathPlots = "./plots"; # For testing
my $pathPlots = "/plots";
#my @plotfiles0 = `find ./plots -type f -name *.gif -o -name *.jpg  -o -name *.png`;
#s/^\.\/plots\/// for @plotfiles0;

foreach my $idd (sort keys %whats) {

        printf FH "%-22s   ", $idd;
        printf FH "%-35s   ", $whats{$idd};
        printf FH "%-35s", $wheres{$idd};
        printf FH "%-6s", $firsts{$idd};
        if( $durations{$idd} ne '' ) {
            printf FH "%s duration   ", $durations{$idd};
        }
        print FH "\n";

        my $tag = $whats{$idd};
        $tag =~ s/ /_/g;
        my($dateEv,$timeEv) = split /\s/, $idd;
        print FHR join( ' ', "getnPlot --tag", $tag, "--date", $dateEv, "--time", $timeEv ), "\n";

        print HFH "<TR>\n";
        print HFH "<TD>\n";
        printf HFH "<B>%s</B>", $idd;
        printf HFH "<HR>\n";
        print HFH "</TD>\n";
        print HFH "<TD>\n";
        printf HFH "%s", $whatswheres{$idd};
        print HFH "</TD>\n";
        print HFH "<TD>\n";
        printf HFH "%s", $firsts{$idd};
        print HFH "</TD>\n";
        if( $durations{$idd} ne '' ) {
            print HFH "<TD>\n";
            printf HFH "%s duration", $durations{$idd};
            print HFH "</TD>\n";
        } else {
            print HFH "<TD>\n";
        }


        if( $comments{$idd} ne '' ) {
            printf FH "  %s\n", $comments{$idd};
        }
        printf FH "  id: %13s   \n", $ids{$idd};
        printf FH "  triggered: %s\n", $trigs{$idd};

        print HFH "<TD>\n";
        printf HFH "id: %s\n", $ids{$idd};
        print HFH "</TD>\n";
        print HFH "<TD>\n";
        printf HFH "triggered: %s\n", $trigs{$idd};
        print HFH "</TD>\n";
        print HFH "</TR>\n";

        if( $comments{$idd} ne '' ) {
            print HFH "<TR><TD colspan=\"5\">\n";
            my $commentstmp = $comments{$idd};
            $commentstmp =~ s/(['"])/\\$1/g;
            printf HFH "%s\n", $commentstmp;
            print HFH "</TD></TR>\n";
        }

        opendir(DIR, "./plots");
        opendir(DIR1, "/home/seisan/projects/Seismicity/VT_strings/data/heli_plots");
        opendir(DIR2, "/home/seisan/projects/Seismicity/VT_strings/data/all_plots");
        my $sst = $ids{$idd};
        if( $sst =~ /\-/ ) {
            my @plotfiles = grep { /$sst/ } readdir(DIR);
            #my @plotfiles = grep { /$sst/ } @plotfiles0;
            my @plotfiles1 = grep { /$sst/ } readdir(DIR1);
            my @plotfiles2 = grep { /$sst/ } readdir(DIR2);
            print FH "  Plots: ";
            print FH join( "  ", ( @plotfiles, @plotfiles1, @plotfiles2 ) );
            print HFH "<TR><TD colspan=\"5\">\n";
            print HFH "  Plots: ";
            foreach my $plotFile (@plotfiles,@plotfiles1,@plotfiles2) {
                my $link = "<BR><A HREF=\"" . join( '/', $pathPlots, $plotFile ) . "\">" . $plotFile . "</A> ";
                print HFH $link;
            }
            print HFH "</TD></TR>\n";
        }
        print FH "\n\n";
        print HFH "<TR><TD> </TD></TR>\n";
            
        #closedir(DIR);
        closedir(DIR1);
        closedir(DIR2);

        printf "%-22s   ", $idd;
        printf "%1s   ", $trigs{$idd};
        printf "%-35s   ", $whats{$idd};
        printf "%-45s", $wheres{$idd};
        printf "%-6s", $firsts{$idd};
        printf "\n";
}

print HFH "<TABLE>\n";
print HFH "</TT>\n";
print HFH "</BODY>\n</HTML>\n";

close( FH );
close( FHR );
close( HFH );
