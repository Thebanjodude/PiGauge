#!/usr/bin/python

import getopt
import math
import sys
import time
from Adafruit_I2C import Adafruit_I2C
from Adafruit_PWM_Servo_Driver import PWM

# Initialise the PWM device using the default address
chip = Adafruit_I2C(0x40)
pwm = PWM(0x40)  

# Imperically derived values for servo pulse times to achieve specific
# positions. These are run through a linear regression.
servo_data = [(0.0, 170.0), 
              (25.0, 280.0), 
              (50.0, 389.0), 
              (75.0, 499.0), 
              (100.0, 608.0)]

def main(argv):
    chart_num = None
    chart_pos = None
    read = False
    try:
        opts, args = getopt.getopt(argv, "hc:p:a", ["ChartNumber=",
                                                    "ChartPosition=",
                                                    "ReadChart=",
                                                    "GetAllPos="])
        for opt, arg in opts:
            if opt == '-h':
                print_help_and_exit(0)
            elif opt in ("-c", "--ChartNumber"):    
                chart_num = int(arg)
                if not 1 <= chart_num <= 5:
                    print 'ChartNumber must be between 1 and 5 inclusive.'
                    sys.exit(1)
            elif opt in ("-p", "--ChartPosition"):
                chart_percent = int(arg)
                if not 0 <= chart_percent <= 100:
                    print 'ChartPosition must be between an integer between \n\
                           0 and 100 inclusive.'
                    sys.exit(1)
                chart_pos = transfer(chart_percent)
            elif opt in ("-a", "--GetAllPos"):
                for chart_num in range(1, 6):
                    print_position(chart_num)
                sys.exit(0)
    except:
        print_help_and_exit(1)
            
    if chart_num is not None and chart_pos is not None:
        move_servos(chart_num, chart_pos)
    else:
        print_help_and_exit(1)

    
def move_servos(chart_num, chart_pos):
    pwm.setPWM(chart_num, 0, chart_pos)
    time.sleep(0.1)
    print_position(chart_num)

    
def print_position(chart_num):
    # Add two unsigned byets off the I2C bus. Shift the second register
    # because it is the MSB.
    chart_pos = (chip.readU8(8 + chart_num * 4) + 
                (chip.readU8(9 + chart_num * 4) << 8)) 
    print 'Servo', chart_num, 'is at', inverse_transfer(chart_pos)
    
    
def transfer(chart_percent):
    return int(xfer_m * chart_percent + xfer_b)
    
    
def inverse_transfer(chart_pos):
    return int(round((chart_pos - xfer_b) / xfer_m))
        

def linear_regression(data):
    sum_x, sum_y, sum_xy, sum_xx, sum_yy = 0, 0, 0, 0, 0
    n = float(len(data))

    for x, y in data:
        sum_x  += x
        sum_y  += y
        sum_xy += x*y
        sum_xx += x*x
        sum_yy += y*y

    m  = (sum_xy - sum_x * sum_y / n) / (sum_xx - sum_x**2 / n)
    b  = (sum_y - m * sum_x) / n
    return m, b
        
        
def print_help_and_exit(return_code):
    print """
Usage: python scriptname.py [options]
Option:
 -a               Gives the positions of all the servos (0 - 100%)
 -c <num>         Use position argument for chart <num> (1 - 5, integer only)
 -p <num>         Set chart to position <num>% (0 - 100, integer only)
 --ChartNum <num> Same as -c <num>
 --ChartPos <num> Same as -p <num>
    """
    sys.exit(0)
    
xfer_m, xfer_b = linear_regression(servo_data)  
main(sys.argv[1:])