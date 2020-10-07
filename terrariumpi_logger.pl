#Based in part on https://engineer.john-whittington.co.uk/2016/11/raspberry-pi-data-logger-influxdb-grafana/

import time, datetime, urllib.request, json, requests


from influxdb import InfluxDBClient

# Define influxDB variables
my_host = "localhost"
my_port = 8086
dbname = "terrariumPi_db"


#Define the TerrariumPi URL
base_url = "http://localhost:8090"


# Create the InfluxDB object
client = InfluxDBClient(host=my_host, port=my_port, database=dbname)

#print(client.get_list_database()) #debugging test of connection


#calculate the time.
current_time = int(time.time())

# Read the sensor data
data_from_API = urllib.request.urlopen(base_url+"/api/sensors").read()

#Convert it to a Python object 
json_data = json.loads(data_from_API)

#For each sensor convert the relevant data into InfluxDB Line Protocol format
for element in json_data['sensors']:
	json_body = [
		{
			"measurement": element['name'],
			"tags": {
				"type": element['type'],
				"hardwaretype": element['hardwaretype']
			},
			"time": current_time,
			"fields": {
				"Value": element['current'],
				"Alarm_On": element['error'],
				"Alarm_Max": element['alarm_max'],
				"Alarm_Min": element['alarm_min']
			}
		}
	]
# and write to InfluxDB database
	client.write_points(json_body, time_precision='s', protocol='json')
#	print ( json_body )


# Read the switch data
data_from_API = urllib.request.urlopen(base_url+"/api/switches").read()

#Convert it to a Python object
json_data = json.loads(data_from_API)

# For each switch convert the relevant data into InfluxDB Line Protocol format
for element in json_data['switches']:
	json_body = [
		{
			"measurement": element['name'],
			"tags": {
				"ID": element['id'],
				"Hardware type": element['hardwaretype']
			},
			"time": current_time,
			"fields": {
				"Value": element['state'],
				"Timer_Enabled": element['timer_enabled'],
				"Timer_Start": element['timer_start'],
				"Timer_Stop": element['timer_stop']
			}
		}
	]
	client.write_points(json_body, time_precision='s', protocol='json')
#	print ( json_body )

# Read the sensor averages
data_from_API = urllib.request.urlopen(base_url+"/api/sensors/average").read()
json_data = json.loads(data_from_API)
for i in json_data["sensors"].keys():
	json_body = [
		{
			"measurement": i,
			"time": current_time,
			"fields": {
				"Value": json_data["sensors"][i]['current'],
				"Alarm_On": json_data['sensors'][i]['alarm'],
				"Alarm_Max": json_data['sensors'][i]['alarm_max'],
				"Alarm_Min": json_data['sensors'][i]['alarm_min']
			}
		}
	]
	client.write_points(json_body, time_precision='s', protocol='json')
#	print ( json_body )

# Read the system data
data_from_API = urllib.request.urlopen(base_url+"/api/system").read()
json_data = json.loads(data_from_API)
json_body = [
	{
		"measurement": "Disk",
		"time": current_time,
		"fields": {
			"Free Disk": json_data['disk']['free'],
			"Total Disk": json_data['disk']['total'],
			"Used Disk": json_data['disk']['used']
		}
	}
]
client.write_points(json_body, time_precision='s', protocol='json')
#print ( json_body )

json_body = [
	{
		"measurement": "Memory",
		"time": current_time,
		"fields": {
			"Free Memory": json_data['memory']['free'],
			"Total Memory": json_data['memory']['total'],
			"Used Memory": json_data['memory']['used']
		}
	}
]
client.write_points(json_body, time_precision='s', protocol='json')
#print ( json_body )

json_body = [
	{
		"measurement": "CPU Load",
		"time": current_time,
		"fields": {
			"Load1": json_data['load']['load1'],
			"Load15": json_data['load']['load15'],
			"Load5": json_data['load']['load5']
		}
	}
]
client.write_points(json_body, time_precision='s', protocol='json')
#print ( json_body )

json_body = [
	{
		"measurement": "CPU Temperature",
		"time": current_time,
		"fields": {
			"CPU temperature": json_data['temperature']
		}
	}
]
client.write_points(json_body, time_precision='s', protocol='json')
#print ( json_body )

json_body = [
	{
		"measurement": "Uptime",
		"time": current_time,
		"fields": {
			"System Uptime": json_data['uptime']
		}
	}
]
client.write_points(json_body, time_precision='s', protocol='json')
#print ( json_body )
