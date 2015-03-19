## Twitter Flume source

Compiled from various samples using twitter classes to use as source and filter data based on keywords


Tested with Flume 1.5 on MapR 4.0.1

Installation and use:

1) Install Flume on a node(s) (yum install mapr-flume)
(Note: This package already contains a twitter source for the 1% feed and provides the sink in avro format, not json, and also doesn’t have any keyword filter options)

2) Verify the versions of the twitter core and stream jars in the <FLUME_HOME>/lib directory. These need to be 3.0.6 or later (twitter4j-core-3.0.6.jar & twitter4j-stream-3.0.6.jar)

If they are older versions copy from apache or use the jars available in this github by going to the <FLUME_HOME>/lib directory and executing the commands below

(wget --no-check-certificate https://github.com/mapr/mapr-demos/tree/master/drill-twitter-MSTR/flume/target/twitter4j-core-3.0.6.jar)
(wget --no-check-certificate https://github.com/mapr/mapr-demos/tree/master/drill-twitter-MSTR/flume/target/twitter4j-stream-3.0.6.jar)

Also remember to remove the older jars from the <FLUME_HOME>/lib directory

3) Copy flume-sources-twitter-json-0.1.jar from github target to <FLUME_HOME>/lib directory

(wget --no-check-certificate https://github.com/mapr/mapr-demos/tree/master/drill-twitter-MSTR/flume/target/flume-sources-twitter-json-0.1.jar)

4) See these steps to create a twitter app and get the relevant tokens to use for the twitter flume source configuration (http://iag.me/socialmedia/how-to-create-a-twitter-app-in-8-easy-steps/)

5) Update the flume.conf and flume-env.sh files in the <FLUME_HOME>/conf directory using the samples provided in this repo
(Make sure to double check the tokens and keywords you want to use)
(Also verify the sink you want to use - default in the config file points to maprfs with base directory /twitter/tmp)
(Can be modified for HDFS and S3 - Will look at this in the future)

The flume source will filter on both keywords and languages (if all languages are desired the languages variables can be left empty). Language codes are the 2 letter ISO_639-1 codes, the link below provides the list

http://en.wikipedia.org/wiki/List_of_ISO_639-1_codes

Also the flume conf file is deliberately set up to create larger (a little less than 128MB JSON files) for optimized query operations at larger scale. This can be changed if needed.


6) Make sure to create a directory in the MapR-FS root directory called twitter with subdirectories 'tmp' and 'feed'. Also verify that the user that will execute Flume has full permission to these directories. Default it to use the mapr user on the node.


7) Start flume from the <FLUME_HOME> directory (You can change the options as needed)
(I recommend that you install a utility such as screen and run start flume from there, or use similar nohup option to maintain the flume session - other option suggestions are welcome)
(./bin/flume-ng agent --conf ./conf/ -f ./conf/flume.conf -Dflume.root.logger=INFO,console -n TwitterAgent)

8) The tweets should now stream into the <MapR-FS root>/twitter/tmp directory in the specified directory structure of /year/month/day/hour (This can be changed with the parameters in the flume.conf file)

9) Drill 0.7 does not work well with Flume inUse files due to the fact that they can contain incomplete JSON docs, and it is not able to ignore hidden files or certain prefixes. The temporary workaround is to move completed files from the ./twitter/tmp directory to the ./twitter/feed directory. 

The script move_files.sh uses the MapR NFS loopback to move completed flume files to the processing directory, this is just a move operation that is very low overhead.

Go the <MapR-FS root>/twitter/tmp and copy the script to that location.
(wget --no-check-certificate https://github.com/mapr/mapr-demos/tree/master/drill-twitter-MSTR/flume /move_files.sh)
Make sure the file is executable and owned by the same user as the one for flume, default is mapr on the node.

Edit cron to run the file every 5 minutes (or shorter if preferred).
As mapr user (or user with privileges) run

crontab -e
(then enter)
*/5 * * * * cd /mapr/<mapr-clustername>/twitter/tmp && ./move_files.sh



 

 