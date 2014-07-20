#!/usr/bin/perl
use strict;
use Data::Dumper;
use DateTime;
use DateTime::Format::Epoch;
$|=1;   #makes the macro produce all results at once, not in spurts

######################################################################
# This script will take the files that I have created from copying
# and saving my workouts manually from the Polar Flow site so that
# they can be converted to .tcx files for import into Endomondo and
# SportTracks.mobi or any other site, but mainly to have a backup for
# my personal use
######################################################################

######################################################################
# Your Constant Variables (if your workout contains no GPS data)
# These are dummy values, since most sites require GPS data to import
# workouts and heart rate data
#
# I advice looking up your house/gym in Google Maps & copying the
# latitude & longitude from there as a default

my $latitude = 47.614848;
my $longitude = -122.3358423;
my $altitude = 587.0; #in meters

# Your timezone offset, should be a plus or minus value
# e.g. +03:00 or -08:00
# If no timezone offset is needed, simply use "Z"
# Info on finding yours here:
# http://en.wikipedia.org/wiki/List_of_UTC_time_offsets

my $timezone = "-08:00";

######################################################################


my @files = glob("Export/*.txt");

my $header = '<?xml version=\'1.0\' encoding=\'UTF-8\'?>
<TrainingCenterDatabase xmlns:tpx="http://www.garmin.com/xmlschemas/ActivityExtension/v2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns5="http://www.garmin.com/xmlschemas/ActivityGoals/v1" xmlns:ns4="http://www.garmin.com/xmlschemas/ProfileExtension/v1" xmlns:ns2="http://www.garmin.com/xmlschemas/UserProfile/v2" xmlns="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2">
  <Activities>
';

my $footer = '        </Track>
      </Lap>
    </Activity>
  </Activities>
  <Author xsi:type="Application_t">
    <Name>LaRosa Johnson - manual export from flow.polar.com</Name>
    <Build>
      <Version>
        <VersionMajor>0</VersionMajor>
        <VersionMinor>0</VersionMinor>
        <BuildMajor>0</BuildMajor>
        <BuildMinor>0</BuildMinor>
      </Version>
    </Build>
    <LangID>en</LangID>
    <PartNumber>000-00000-00</PartNumber>
  </Author>
</TrainingCenterDatabase>
';

foreach my $filename (@files){
     my $output = $filename; #come back to this later
     $output =~ s|\.txt|.tcx|i;
     $output =~ s|Export|Import|i;
     #filename should be something like "YYYY-MM-DD_Name_Type.tcx"
     
     open (IN, $filename);
     my @polarfile = <IN>;
     close IN;
     
     my $type = "";
     my $starttime;
     my $endtime;
     my $distance = "";
     my $calories = "";
     my $hravg = "";
     my $hrmax = "";
     my $maxspeed = "";
     my $inputvalues = "";
     
     my @time;
     my @hr;

     foreach my $line (@polarfile){
          if($line =~ m{type = (.+)$}){
               $type = $1;
          }
          elsif($line =~ m{starttime = (.+)$}){
               $starttime = $1;
          }
          elsif($line =~ m{endtime = (.+)$}){
               $endtime = $1;
          }
          elsif($line =~ m{distance = (.+)$}){
               $distance = $1;
          }
          elsif($line =~ m{calories = (.+)$}){
               $calories = $1;
          }
          elsif($line =~ m{HRavg = (.+)$}){
               $hravg = $1;
          }
          elsif($line =~ m{HRmax = (.+)$}){
               $hrmax = $1;
          }
          elsif($line =~ m{maxspeed = (.+)$}){
               $maxspeed = $1;
          }
          elsif($line =~ m{values = (.+)$}){
               $inputvalues = $1;
          }
     }

     while($inputvalues =~ m{\[[0-9]+,[0-9]+\]}){
          $inputvalues =~ s|\[([0-9]+),([0-9]+)\],*|
               push(@time, $1);
               push(@hr, $2);
                    
               my $temp = "";
               $temp;
          |ei;
     }
          
     my $totaltime = ($endtime - $starttime)/1000;
     my $dt = DateTime->new( year => 1970, month => 1, day => 1 );
     my $formatter = DateTime::Format::Epoch->new(
                      epoch          => $dt,
                      unit           => 'milliseconds',
                      type           => 'int',    # or 'float', 'bigint'
                      skip_leap_seconds => 1,
                      start_at       => 0,
                      local_epoch    => undef,
                  );

     $starttime = $formatter->parse_datetime($starttime) . "$timezone";
          
     my $header2 = qq(    <Activity Sport="$type">\n      <Notes>Polar Loop Workout</Notes>\n      <Id>$starttime</Id>\n      <Lap StartTime="$starttime">\n        <TotalTimeSeconds>$totaltime</TotalTimeSeconds>\n        <DistanceMeters>$distance</DistanceMeters>\n        <MaximumSpeed>$maxspeed</MaximumSpeed>\n        <Calories>$calories</Calories>\n        <AverageHeartRateBpm>\n          <Value>$hravg</Value>\n        </AverageHeartRateBpm>\n        <MaximumHeartRateBpm>\n          <Value>$hrmax</Value>\n        </MaximumHeartRateBpm>\n        <Intensity>Active</Intensity>\n        <TriggerMethod>Manual</TriggerMethod>\n        <Track>\n);
          
     my $hrcontent = "";
          
     my $c = 0;
          
     foreach my $tval (@time){
          $tval = $formatter->parse_datetime($tval) . "$timezone";
               
          $hrcontent .= qq(          <Trackpoint>\n            <Time>$tval</Time>\n            <Position>\n              <LatitudeDegrees>$latitude</LatitudeDegrees>\n              <LongitudeDegrees>$longitude</LongitudeDegrees>\n            </Position>\n            <AltitudeMeters>$altitude</AltitudeMeters>\n            <HeartRateBpm xsi:type="HeartRateInBeatsPerMinute_t">\n              <Value>$hr[$c]</Value>\n            </HeartRateBpm>\n          </Trackpoint>\n);
               
          $c++;
     }
          
     if($filename =~ m{_[1-2]}){
          $output =~ s|_([1-2])_|_Polar Loop Workout $1_|i;
     }
     else{
          $output =~ s|([0-9]+-[0-9]+-[0-9]+)_|$1_Polar Loop Workout_|i;
     }

     
     open (OUT, ">$output");
     print OUT $header;
     print OUT $header2;
     print OUT $hrcontent;
     print OUT $footer;
     close OUT;
}
