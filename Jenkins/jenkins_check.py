#! /usr/bin/env python
#---------------------------------------------------------------------------------------------------------------
# Author:
# Juned Memon <junaid18183@gmail.com>
# This is a simple Nagios plugin to check if any of the defined Jenkins Job is getting failed.
#---------------------------------------------------------------------------------------------------------------
#Imports
import urllib,sys,re,simplejson
#---------------------------------------------------------------------------------------------------------------
#Variables
exclude_colors=['disabled','notbuilt']
#---------------------------------------------------------------------------------------------------------------
if len(sys.argv) != 2:
  print "Please run the script with a Jenkins url as the only argument\n Example : python jenkins_check.py http://localhost:8080"
  sys.exit(1)
#---------------------------------------------------------------------------------------------------------------

url = str(sys.argv[1])
xml_input_no_filter = simplejson.load(urllib.urlopen(url + "/api/json?tree=jobs[name,color,healthReport[score]]"))

all_jobs = xml_input_no_filter['jobs']
non_successful_jobs = [row for row in all_jobs if not bool(re.search('blue', row['color'])) and row['color'] not in exclude_colors ]

msg=(str(len(non_successful_jobs)) + " jobs out of " + str(len(all_jobs)) + " are currently failing")

for (i, item) in enumerate(non_successful_jobs):
  #msg = msg+" Job name : " + item['name'] + " Result : " + item['color']
  msg = msg+" Job%s:%s" %(i+1,item['name'])

if len(non_successful_jobs) > 0 :
        status=2
else:
        status=0

msg = msg + " | All_Jobs=%s;Failed_Jobs=%s" %(len(all_jobs),len(non_successful_jobs))
print msg
sys.exit(status)
