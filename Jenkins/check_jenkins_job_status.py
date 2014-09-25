#! /usr/bin/env python
#---------------------------------------------------------------------------------------------------------------
# Author:
# Juned Memon <junaid18183@gmail.com>
# This is a simple Nagios plugin to check if any of the defined Jenkins Job is getting failed.
#---------------------------------------------------------------------------------------------------------------
#Imports
import urllib2,sys,re,simplejson,argparse,base64
#---------------------------------------------------------------------------------------------------------------
#Variables
exclude_colors=['disabled','notbuilt']
#dashbord_url="http://ggvaapp07.glam.colo:3030/widgets/Jenkins"
#---------------------------------------------------------------------------------------------------------------
def main ():

        parser = argparse.ArgumentParser(description="check_jenkins_jobs")

        parser.add_argument("-U", "--url", help="Jenkins URL like  http://localhost:8080",required=True)
        parser.add_argument("-u", "--user", help="User",required=False)
        parser.add_argument("-p", "--password", help="Password",required=False)
	parser.add_argument("-D", "--dashing", help="Dashing base URL to send data to Dashing,e.g. http://localhost:3030",required=False)
        args = parser.parse_args()
	url=args.url
	user=args.user
	password=args.password
	dashing=args.dashing
	status,msg,dashing_status=get_jobs_status(url,user,password,dashing)
	print "%s|%s" %(msg,dashing_status)
	sys.exit(status)
# +----------------------------------------------------------------------+
def get_jobs_status(url,user,password,dashing):
	request = urllib2.Request(url + "/api/json?tree=jobs[name,color,healthReport[score]]")
	base64string = base64.encodestring('%s:%s' % (user, password)).replace('\n', '')
	request.add_header("Authorization", "Basic %s" % base64string)
	result = urllib2.urlopen(request)
	xml_input_no_filter = simplejson.load(result)

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
	if dashing :
                dashing_status=send_data_to_dashing(dashing,all_jobs,failed_jobs,disabled_jobs,notbuilt_jobs)
	return status,msg,dashing_status
# +----------------------------------------------------------------------+
def send_data_to_dashing(dashing,all_jobs,failed_jobs,disabled_jobs,notbuilt_jobs):
	url = dashing + "/widgets/Jenkins"
	data = simplejson.dumps({ "auth_token": "LOVE_YOU_JUNED", "all_jobs": len(all_jobs) , "failed_jobs" : len(failed_jobs) , "disabled_jobs" : len(disabled_jobs) , "notbuilt_jobs": len(notbuilt_jobs)})

	headers={"Content-Type": "application/json"}

	try:
        	request = urllib2.Request(url, data, headers)
	        response = urllib2.urlopen(request)

	#Python 2.6 and above
	#except urllib2.URLError as e :
	#	dashing_status='Dashing update fail'

	#python 2.4
	except urllib2.URLError , e :
        	if not e.code == 204:
        		dashing_status='Dashing update fail'
		dashing_status="Sent data to Dashing"
	return dashing_status
# +----------------------------------------------------------------------+
if __name__ == "__main__":
         sys.exit(main())
# +----------------------------------------------------------------------+
