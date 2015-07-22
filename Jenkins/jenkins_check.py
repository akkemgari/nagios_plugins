#! /usr/bin/env python
#---------------------------------------------------------------------------------------------------------------
# Author:
# Juned Memon <junaid18183@gmail.com>
# This is a simple Nagios plugin to check if any of the defined Jenkins Job is getting failed.
#---------------------------------------------------------------------------------------------------------------
#Imports
import urllib2,sys,re,simplejson
#---------------------------------------------------------------------------------------------------------------
#Variables
exclude_colors=['disabled','notbuilt']
#---------------------------------------------------------------------------------------------------------------
if len(sys.argv) != 2:
  print "Please run the script with a Jenkins url as the only argument\n Example : python jenkins_check.py http://localhost:8080"
  sys.exit(1)
#---------------------------------------------------------------------------------------------------------------

url = str(sys.argv[1])
xml_input_no_filter = simplejson.load(urllib2.urlopen(url + "/api/json?tree=jobs[name,color,healthReport[score]]"))

all_jobs = xml_input_no_filter['jobs']
failed_jobs = [row for row in all_jobs if bool(re.search('red', row['color']))]
disabled_jobs = [row for row in all_jobs if bool(re.search('disabled', row['color']))]
notbuilt_jobs = [row for row in all_jobs if bool(re.search('notbuilt', row['color']))]
#failed_jobs = [row for row in all_jobs if not bool(re.search('blue', row['color'])) and row['color'] not in exclude_colors ]

msg=(str(len(failed_jobs)) + " jobs out of " + str(len(all_jobs)) + " are currently failing")

for (i, item) in enumerate(failed_jobs):
  #msg = msg+" Job name : " + item['name'] + " Result : " + item['color']
  msg = msg+" Job%s:%s" %(i+1,item['name'])

if len(failed_jobs) > 0 :
        status=2
else:
        status=0

msg = msg + " | All_Jobs=%s;Failed_Jobs=%s;Disabled_Jobs=%s;Notbuilt_Jobs=%s" %(len(all_jobs),len(failed_jobs),len(disabled_jobs),len(notbuilt_jobs))
print msg


#For Dashing
url = "http://ggvaapp07.glam.colo:3030/widgets/Jenkins"
data = simplejson.dumps({ "auth_token": "LOVE_YOU_JUNED", "all_jobs": len(all_jobs) , "failed_jobs" : len(failed_jobs) , "disabled_jobs" : len(disabled_jobs) , "notbuilt_jobs": len(notbuilt_jobs)})

headers={"Content-Type": "application/json"}

try:
	request = urllib2.Request(url, data, headers)
	response = urllib2.urlopen(request)

#Python 2.6 and above
#except urllib2.URLError as e :
#	print 'Dashing update fail'
#python 2.4 
except urllib2.URLError , e :
	#if not e.code == 204:
	#	 print 'Dashing update fail'
	pass



####Dashibg End
sys.exit(status)
