PiGauge
===================

You need to run through the Adafruit tutorial for the PWM Driver. It has critical steps needed for this project to function. X

I will keep updating this README as issues arise, although almost everything you need is in the article.

A couple things worth mentioning:

* The first time you run the php all the positions read 896.
	- This is OK. The registers are reading full off
* If you get the error "Failed to run Python Script" 
	-$ cd /dev/
	-$ dir
	Look for i2c-0 and i2c-1. If it is not there then  $ nano /etc/modules
	add a line that reads "i2c-dev" then restart your pi. 

* If you have a REV2 Pi
	- you'll need to update the default I2C port. 
	- In the file Adafruit_PWM_Servo_Driver/Adafruit_I2C.py
	change: 
	def__init__(self, address, bus=smbus.SMBus(0), debug=False)
	to 
	def__init__(self, address, bus=smbus.SMBus(1), debug=False)

	-Then  $ nano /etc/modules
        -Add a line that reads "i2c-dev" then restart your pi.



INSTALL
-------------------
Not mandatory, but it's a good idea to keep your pi up to date.  So start with:

    sudo apt-get update && sudo apt-get upgrade`

Get the python library from Adafruit:

    git clone https://github.com/adafruit/Adafruit-Raspberry-Pi-Python-Code.git

And copy over the PWM code to a path where python can find it:

    cp ./Adafruit-Raspberry-Pi-Python-Code/Adafruit_PWM_Servo_Driver/Adafruit_I2C.py /usr/local/lib/python2.7/site-packages/
    cp ./Adafruit-Raspberry-Pi-Python-Code/Adafruit_PWM_Servo_Driver/Adafruit_PWM_Servo_Driver.py  /usr/local/lib/python2.7/site-packages/

Install apache and php:

    sudo apt-get install apache2 php5 libapache2-mod-php5

Check to ensure apache installed correctly, go to http://ip.of.your.pi and you should see the "It Works!" page.

Link the PiGauge project to your www root.  There are two ways to do this, the easy way:

* (if you are unsure of the path of your project directory type `pwd` from the project directory for the full path)
    sudo ln /path/to/PiGauge_directory /var/www/PiGauge -s
* And the proper way:
	update sites-enabled in apache conf and setup a virtual site(?) or whatever its called-bah

Add apache to the i2c group to allow it to have access to the i2c bus

    sudo adduser www-data i2c

And restart apache to allow it to use the new permissions you have given it

    sudo /etc/init.d/apache2 restart`

You should be ready to go, head over to http://ip.of.your.pi/PiGauge/ and try it out!

NOTES
-------------------
If you have restarted your PWM chip you will get bad position numbers back until you set the PWMs.
