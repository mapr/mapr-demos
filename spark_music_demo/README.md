# spark_music_demo
This repo contains the PySpark code and data sets required to run an example Spark computation on the MapR platform, using MapR-FS, MapR-DB and Drill.  The full end-to-end flow and use case of this demo is documented in a series of blog posts.

To run the demo, perform the following steps:

0) Ensure that prerequisites are satisified on all MapR nodes:
    - Spark and PySpark are installed
    - Happybase is installed

1) Create the MapR-DB tables required for storing the data.  You will need three tables:
    - cust_table
    - agg_table
    - live_table

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
