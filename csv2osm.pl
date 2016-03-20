#####################################################################################################
# CSV2OSM_LOCAL - convert csv-data into osm-format (osm = OpenStreetMap)                            #
#                                                                                                   #
# Copyright (C) 2009 Jan Tappenbeck, osm(at)tappenbeck.net                                          #
#                                                                                                   #
# This program is free software; you can redistribute it and/or modify it under the terms of the    #
# GNU General Public License as published by the Free Software Foundation; either version 3 of      #
# the License, or (at your option) any later version.                                               #
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;         #
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.         #
# See the GNU General Public License for more details.                                              #
# You should have received a copy of the GNU General Public License along with this program;        #
# if not, see <http://www.gnu.org/licenses/>.                                                       #
#                                                                                                   #
# thanks for help by tuning to http://board.perl-community.de/thread/13157/#MSG2                    #
#####################################################################################################

#########
# HISTORY
#########
#
# 2012-01-12  JT   $osm_api change to 0.6

# cut left and right empty spaces
sub trim {
  my @out = @_;
  for (@out) {
       s/^\s+//; # cut left
	   s/\s+$//; # cut right
	}
    return @out == 1
        ? $out[0] # return one
        : @out;   # return many
}


##########
# TODO
##########
#
# Nachfragen, wenn Zieldatei schon vorhanden
# prüfen, ob die Koordinaten auch Ziffern sind !

#!/usr/bin/perl
# file: csv2osm_local.pl

use strict ;
use warnings ;

print "\n\nCSV2OSM_LOCAL - convert csv-data into osm-format\n";
print "================================================\n";
print "Copyright (C) 2009 Jan Tappenbeck, osm(at)tappenbeck.net\n";
print "GNU-License - see <http://www.gnu.org/licenses/>\n\n";

###########
#userdefine
###########
#  names of columns - lat log had to be every time define in this order
my @colnames = qw/name    megalit_type    moved   place   village    historic /;
my $csvfile = 'test.txt'; # file with csv-data
my $delimeter = ';';     # word-seperator

###############
# osm variables
###############
my $osm_xml = '1.0';
my $osm_encoding = 'UTF-8';
my $osm_api = '0.6';
my $osm_editor = 'JOSM';

#################
# other variables
#################
my $dataline;
my $countcol = 0; # how many columns define
my $point_count = 0; #how many points importet
my $line_count = 0; #line of input
my $i = 0;
my $j = 0;
my $lat;
my $log;
my $osmfile;      #targetfile for osm-data := csvfile.osm
my $err_msg;      #error-report
my $colname;
my $colname_idx = 0;
my $object_id = 0;
my @values;
$countcol = scalar(@colnames);

die "\n\n######################\n# missing CSV-file ! #\n######################\n\n\n==> cancel!\n\n\n"
  if not -e $csvfile;

$osmfile = $csvfile.".osm";
print "\ntargetfile: ".$osmfile."\n";

die "\n\n#######################\n# osm-file existing ! #\n#######################\n\n\n==> cancel!\n\n\n"
  if -e $osmfile;

print "\nnames of define columns:\n";
print "------------------------\n";
foreach $colname (@colnames){
  $colname_idx++;
  print $colname_idx."\.column: ".$colname."\n";
}#end-foreach
print "---- all ----\n\n";

open(my $fh, '<', $csvfile) or die "can not open csv-file";
close($csvfile);

# header for xml-file
open(FILEHANDLE,">".$osmfile);
print FILEHANDLE "<?xml version='".$osm_xml."' encoding='".$osm_encoding."'?>\n";
print FILEHANDLE "<osm version='".$osm_api."' generator='".$osm_editor."'>\n";

# read csv-datalines
while(my $dataline=<$fh>){
         chomp($dataline);

         $line_count++;

         #aufsplitten der csv-datei
         my @value = split($delimeter,$dataline);


         #purge first and following spaces
         @value = trim(@value);

         #create node-data
         my $lat = shift @value;
         my $log = shift @value;

         #lat and log define?
         if (defined $lat && defined $log){
                 #output node-header
                 $object_id--;
                 print FILEHANDLE sprintf "  <node id='%s' action='modify' visible='true' lat='%s' lon='%s'>\n",
                 $object_id, $lat, $log;

                 # get column-values and set to node
                 foreach my $col (@colnames) {
                         my $value = shift @value;
                         next if !defined $value || length $value < 1;
                         print FILEHANDLE sprintf "    <tag k='%s' v='%s' />\n", $col, $value;
                 }
                 $point_count++;
                 print FILEHANDLE "  </node>\n";

                 } else {
                         $err_msg .= "missing lat- and/or log-value in line $line_count\n";
         }#endif - &&

 }# end-while

# feetline for xml-file
print FILEHANDLE "</osm>\n";

close(FILEHANDLE);

print "\nerror-report:\n";
print "-------------\n";
if (!defined $err_msg) {
  print "** no error **\n";
}else{
  print $err_msg;
}

print("\n".$point_count." point(s) imported\n");

print("\n**** perl-script-end ****\n\n");
