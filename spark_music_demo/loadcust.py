# load the customer data from CSV into MapR-DB/HBase
import csv
import happybase

# CSV file of customer records -- change me
f = 'cust.csv'

ufile = open(f)
reader = csv.DictReader(ufile)
conn = happybase.Connection('localhost')
table = conn.table('/user/mapr/cust_table')

print "reading customer file %s" % f
i = 0
for row in reader:
    i += 1
    table.put(row['CustID'],
        {'cdata:name': row['Name'],
         'cdata:gender': row['Gender'],
         'cdata:address': row['Address'],
         'cdata:zip': row['zip'],
         'cdata:signdate': row['SignDate'],
         'cdata:status': row['Status'],
         'cdata:level': row['Level'],
         'cdata:campaign': row['Campaign'],
         'cdata:linked_with_apps': row['LinkedWithApps']})
print "loaded cust db with %d entries" % i
