# drill-twitter
Repository of using Apache Drill for Twitter Data

Tested with Drill 0.7

There are 2 files meant to be templates to create queries and views as needed. The txt includes some queries and ideas on how to query twitter data in JSON format, and can be altered as needed.

The sql file is meant to give a quick start to create views to simplify the use of Twitter data. The first view is for the most relevant data in the base tweets with data type casting, and also includes suppression of tweet characters to simplify the use with ODBC and JDBC tools that may not be able to handle all the different character sets in tweets (such emoticons). The second view captures the hashtags in tweets and represents each hashtag as a separate row in the view for easier consumption. The last view is for all retweets and captures the most relevant retweeted data. 

To use the create_drill_views.sql file simple copy the file to a drill node (or other interface tool that can execute sql files). With sqlline on a drill node simply execute from within the sqlline shell
0: jdbc:drill:zk=twitternode:5181> !run create_drill_views.sql
(Make sure that the file is in the directory from where you started sqlline)

Please note that these queries assume that a directory named twitter was created in the MapR-FS root directory, with a subdirectory called 'feed' in this directory containing all the JSON directory structure and files as created by the flume module. Also that a storage plugin for MapR-FS was created with the name dfs, and also a workspace with the name twitter was created pointing to the twitter directory in MapR-FS. 
