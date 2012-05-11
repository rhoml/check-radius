#!/bin/bash
#
# Developers: Rhommel Lamas
# Purpose: Nagios Plugin for Freeradius Status Check
# Version 1.0.1
#
# ---------------------------------------- License -----------------------------------------------------
# 
# This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>. 
#
# ---------------------------------------- Documentation -------------------------------------------------
# Documentation about radclient: ~:# man radclient
# This scripts is intended to be used as a Nagios plugin to check the different states
# of our Freeradius Server even though the $DAEMON is up and runing it checks 
# if the $DAEMON can handle requests using radclient.
# 
# -----------------------------------------------------------------------------------------------------
#  Plugin Description
# -----------------------------------------------------------------------------------------------------
#
# This Plugin handles 3 states
#
#       OK - Freeradius is UP and Capable of Handle requests
#       WARNING - Freeradius Status is Unknow
#       Critical - Freeradius is DOWN
#                        - Freeradius is UP but isn't capable of Handling any request (DB problems, Configuration, Iptables, etc...)
# 
# Radclient Status Command
# echo "Message-Authenticator = 0x00" | radclient xxx.xxx.xxx.xxx:xxxx status nagios
#
###########################################################################
##
# 	Initialization
##

DAEMON=radiusd
INIT_SCRIPT=/etc/init.d/$DAEMON
PARAM1=$1
RAD_SERVER=$2
PARAM2=$3
RAD_ACCT_PORT=$4
RAD_CHECK=status
PARAM3=$5
RAD_USER=$6
PARAM4=$7
TIMEOUT=$8

##
# Parameter Validation
##

if [ "$PARAM1" != "-H" -o "$PARAM2" != "-P" -o "$PARAM3" != "-U" -o "$PARAM4" != "-t" -o "$RAD_SERVER" == "" -o "$RAD_ACCT_PORT" == "" -o "$RAD_USER" == "" -o "$TIMEOUT" == "" ]; then
        echo "Usage: $0 -H <Host ip Address> -P <Accounting Port> -U <Radius user for testing> -t <timeout>"
                # Nagios exit code 3 = status UNKNOWN = orange


if [ "$PARAM1" != "-h" ]; then
        # Nagios exit code 3 = status UNKNOWN = orange
                exit 3
   else
        echo ""
		echo " -h = Display's this Help"
        echo " -H = Freeradius Host ip Address."
        echo " -P = Freeradius Accounting Port."
        echo " -U = Freeradius User (created for this purpose only)."
        echo " -t = Radclient timeout (seconds)."
        echo " -h = This help message."
        # Nagios exit code 3 = status UNKNOWN = orange
                exit 3   
   fi
fi

##
#	DO NOT MODIFY ANYTHING BELOW THIS
##

$INIT_SCRIPT status >/dev/null 2>/dev/null
    case $? in
    0)
        echo "Message-Authenticator = 0x00" | radclient -t $TIMEOUT -q $RAD_SERVER:$RAD_ACCT_PORT $RAD_CHECK $RAD_USER
        if [ $? == 0 ]; then
                        echo "OK - $DAEMON is WORKING"
                        # Nagios exit code 0 = status OK = green
                        exit 0
        else
                        echo " Critical - $DAEMON is running but doesn't handles requests "
                        # Nagios exit code 2 = status CRITICAL = red
                    exit 2                
        fi
        ;;
    3)
        echo " Critical - $DAEMON isn't running"
                # Nagios exit code 2 = status CRITICAL = red
            exit 2
      ;;
    *)
        echo " Critical - $DAEMON isn't running"
                # Nagios exit code 1 = status WARNING = yellow
            exit 1
      ;;
    esac