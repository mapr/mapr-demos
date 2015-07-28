# spark_music_demo
This repo contains the PySpark code and data sets required to run an example Spark computation on the MapR platform, using MapR-FS, MapR-DB and Drill.

The full end-to-end flow and use case of this demo is documented in a series of blog posts and video:
- Blog Post #1:  https://www.mapr.com/blog/real-time-user-profiles-spark-drill-and-mapr-db
- Blog Post #2:  https://www.mapr.com/blog/classifying-customers-mllib-and-spark
- Video on YouTube:  https://www.youtube.com/watch?v=wIWp8lnj7UE

To run the demo, perform the following steps:

0) Check that prerequisites are satisified on all MapR nodes.  Specifically, ensure that Spark and PySpark are installled as well as the HappyBase Python package.

1) Create the MapR-DB tables required for storing the data.  You will need three tables:  cust_table, agg_table, live_table.

2) In each of the above tables, create a single column family named cdata, adata and ldata, respectively.

3) Run the script 'loadcust.py' to load the customer data (cust.csv) into MapR-DB.  You may want to edit this file to adjust any parameters needed beforehand.

Now you can run the Spark job to compute the aggregate user profiles (adjust Spark path as needed).  This can be done from the master node.

```
/opt/mapr/spark/spark-1.2.1/bin/spark-submit ./rt_profile_dash.py 
```

You can run 'tail -f features.txt' to see the features being generated.

You should see few lines of output summarizing the results.  Assuming you have the cluster mounted locally, Copy the features.txt file to MapR-FS:

```
cp features.txt /opt/mapr/spotcluster3/user/mapr
```

Now run the binary classification code script, again from the master node:

```
/opt/mapr/spark/spark-1.2.1/bin/spark-submit ./predict.py
```

You should see a few lines of output summarizing the results, including error for SGD and LBFGS and the size of the train and test data sets.

## Viewing the data in Tableau

The files cust_view.sql and live_view.sql contain the SQL queries necessary to make the views in Drill Explorer.  The Tableau workbook included in this repo references these views.  To create the views, simply go to the 'SQL' tab in Drill Explorer and enter the query, then selecting 'Save'.  This will save the views in the Hadoop filesystem (or MapR-FS) and they can be pulled into Tableau later.







