from __future__ import division
from pyspark import SparkContext, SparkConf
from pyspark.mllib.stat import Statistics
from operator import add
import happybase
import csv

conf = SparkConf().setAppName('ListenerSummarizer')
sc = SparkContext(conf=conf)
conn = happybase.Connection('localhost')
ctable = conn.table('/user/mapr/cust_table')
ltable = conn.table('/user/mapr/live_table')
atable = conn.table('/user/mapr/agg_table')
trackfile = sc.textFile('tracks.csv')
clicksfile = sc.textFile('clicks.csv')
trainfile = open('features.txt', 'wb')

def make_tracks_kv(str):
    l = str.split(",")
    return [l[1], [[int(l[2]), l[3], int(l[4]), l[5]]]]

def clicks_summary(str):
    l = str.split(",")
    custid = l[1]
    adv = l[2]
    if (adv == "ADV_REDUCED_1DAY"):
        return (custid, 1)

def compute_stats_byuser(tracks):
    mcount = morn = aft = eve = night = 0
    tracklist = []
    for t in tracks:
        trackid, dtime, mobile, zip = t
        if trackid not in tracklist:
            tracklist.append(trackid)
	d, t = dtime.split(" ")
	hourofday = int(t.split(":")[0])
	mcount += mobile
        if (hourofday < 5):
	    night += 1
        elif (hourofday < 12):
            morn += 1
        elif (hourofday < 17):
            aft += 1
        elif (hourofday < 22):
            eve += 1
        else:
            night += 1
    return [len(tracklist), morn, aft, eve, night, mcount]

def user_clicked(line, which):
    eid, custid, adclicked, ltime = line.split(",")
    if (which in adclicked):
        return (custid, 1)
    else:
        return (custid, 0)

# make a k,v RDD out of the input data
tbycust = trackfile.map(lambda line: make_tracks_kv(line)).reduceByKey(lambda a,b: a + b)

# compute profile for each user
custdata = tbycust.mapValues(lambda a: compute_stats_byuser(a))  

# compute aggregate stats for entire track history
aggdata = Statistics.colStats(custdata.map(lambda x: x[1]))  

# distill the clicks down to a smaller data set that is faster
clickdata = clicksfile.map(lambda line:
        user_clicked(line, "ADV_REDUCED_1DAY")).reduceByKey(add)
sortedclicks = clickdata.sortByKey()

# write the individual user profiles
c = 0
entries = []
b = ltable.batch(transaction=True)
for k, v in custdata.collect():
    unique, morn, aft, eve, night, mobile = v
    tot = float(morn + aft + eve + night)
    c += 1

    # write the data to MapR-DB
    b.put(k,
	        {'ldata:unique_tracks': str(unique),
	         'ldata:morn_tracks': str(morn),
	         'ldata:aft_tracks': str(aft),
	         'ldata:eve_tracks': str(eve),
	         'ldata:night_tracks': str(night),
	         'ldata:mobile_tracks': str(mobile),
                 })

    # get the associated customer record
    r = ctable.row(k)

    # see if this user clicked on a 1-day special reduced Gold rate
    clicked = 1 if sortedclicks.lookup(k)[0] > 0 else 0

    #print unique,morn,aft,eve,night,mobile,tot
    training_row = [
                morn / tot,
                aft / tot,
                eve / tot,
                night / tot,
                mobile / tot,
                unique / tot ]
    trainfile.write("%d" % clicked)

    # the libSVM format wants features to start with 1
    for i in range(1, len(training_row) + 1):
        trainfile.write(" %d:%.2f" % (i, training_row[i - 1]))
    trainfile.write("\n")

    # (optional) so we can watch the output
    trainfile.flush()

# send it to the db
b.send()

# write the summary data
atable.put("all",
    {'adata:unique_tracks': str(aggdata.mean()[0]),
     'adata:morn_tracks': str(aggdata.mean()[1]),
     'adata:aft_tracks': str(aggdata.mean()[2]),
     'adata:eve_tracks': str(aggdata.mean()[3]),
     'adata:night_tracks': str(aggdata.mean()[4]),
     'adata:mobile_tracks': str(aggdata.mean()[5]) })

print "wrote %d lines to profile db" % c
print "averages:  unique: %d morning: %d afternoon: %d evening: %d night: %d mobile: %d" % \
    (unique, morn, aft, eve, night, mobile)
print "done"
