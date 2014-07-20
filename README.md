PolarFlowExport
===============

Script for manually created process to export &amp; convert flow.polar.com workout data to .tcx files for import into other fitness sites such as Endomondo or SportTracks.mobi

## Purpose

The reason I wrote this script is because I spent a few months using a Polar Loop and Polar H7 heart rate monitor to record my workouts. I have since moved on to a Pebble Steel and use other tools for tracking my fitness (particularly Endomondo &amp; SportTracks.mobi). As such, I hated the idea that Polar has not yet created a way to easily export my data to another platform. After taking a glance at the HTML source code, I noticed that all the data I needed from my workouts was contained in the HTML, so I created this process to capture that data and convert it to a format that I could easily import into my new fitness platforms.

I'll preface this by saying that this is a manual process, as I only had 63 workouts to export, and it would've taken me longer to create a scraping tool than the time it took to manually copy/paste the data to a text file. So, if anyone wants to take on that task, be my guest, but I'm providing this as-is. Also, none of my workouts included GPS data, so my script doesn't account for that, but the data is there to be copied &amp; the script can be easily adjusted to factor in that data.

## The Process

The first step in the process involves manually exporting your data from flow.polar.com and saving the data as text files for the script to process.

1. First, open up an individual workout on the Flow website
2. Using the template provided, fill in the type of workout (e.g. cycling, walking, running, other, etc.)
3. Copy the max &amp; average heart rate data to the file
3. Copy the number of calories burned
4. View the source code for the HTML page that contains your workout and scroll/search until you find code that begins - **"var curve = new Curve"** -- this is where all of our other data is contained
5. Copy the stopDistance variable (it's in meters) and put that for "distance" in your text file
6. Right after stopDistance should be variables for startTime and endTime. Copy these values to their respective lines in the text file
7. Unless you know your max speed, leave that at zero
8. The value line in the text file is for your heart rate data, which is found in the variable that begins - **"durationBasedSamples":{"HEART_RATE":** -- copy this line until you reach **"sportTypeSpeed"**. Paste that into the text file
9. Save the text file using a format such as: **YYYY-MM-DD\_Type.txt** -- where "type" is the type of workout. If you have multiple workouts for the same day use something like: **YYYY-MM-DD\_1\_Type.txt** & **YYYY-MM-DD\_2\_Type.txt**
10. Save all these files to a directory named "Export" and put this in the same folder as the Perl script

Next, open the perl script and edit any of the variables at the top that need to be changed (such as latitude, longitude, altitude, and timezone offset). Instructions for these are contained in the Perl script.

Create a folder called "Import" in the same directory as the Perl script, for the .tcx files to be output to (yeah, I know I could have put this in the code, but I didn't).

Finally, run the script and check the Import folder for the .tcx files that you can then upload to a site like Endomondo or SportTracks.mobi.

## Final Thoughts

Feel free to fork this script and add to it. I just did this to get the job done for my needs, but thought it'd be worth sharing with those who may need to do the same thing.
