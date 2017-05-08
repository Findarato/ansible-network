#! /bin/bash
# ##############################################################################
# check_dhcp_all_pools.sh - Nagios plugin
#
# This script querys a MS Windows DHCP-Server via SNMP v2 to fetch informations about the given DHCP-Pool.
#
# Copyright (C) 2006, 2007 Lars Michelsen <lars@vertical-visions.de>,
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307,
#
# GNU General Public License: http://www.gnu.org/licenses/gpl-2.0.txt
#
# Report bugs to: lars@vertical-visions.de
#
# 2006-07-05 Version 0.2
# 2007-10-27 Version 0.3
#
# Modified 2013-04-22 by JRM (http://liveaverage.com) to support checking all scopes
# 
#
# ##############################################################################

if [ $# -lt 2 ]; then
        echo "check_dhcp_all_pools"
        echo "Usage: $0 <host> <community> <warn> <crit>"
        echo "Example: WARN at 50 & CRIT at 30 will WARN you when the percentage of free DHCP addresses"
        echo "is less than or equal to 50% of available addresses and alarm CRITICAL whe the percentage"
        echo "of free addresses is less than or equal to 30% of available addresses."
        exit 3
fi

IP="$1"
COMMUNITY="$2"
WARN="$3"
CRIT="$4"
RET=0
RETW=0
RETC=0
Z=0
STAT=( )
i=0

if [ ${#WARN} -lt 1 ]
then
        WARN=20
fi

if [ ${#CRIT} -lt 1 ]
then
        CRIT=10
fi

#Get the list of all scopes/subnets from the server:
TEMP=($( snmpwalk -c $COMMUNITY $IP .1.3.6.1.4.1.311.1.3.2.1.1.1 | cut -d " " -f4 ))

#Traverse array and get usage information per scope:
for i  in ${!TEMP[*]};do

POOL=${TEMP[$i]}

FREEOID=".1.3.6.1.4.1.311.1.3.2.1.1.3.$POOL"
USEDOID=".1.3.6.1.4.1.311.1.3.2.1.1.2.$POOL"

SNMP_RESULT=`snmpget -v 2c -c $COMMUNITY $IP $FREEOID`
FREE=`echo $SNMP_RESULT|cut -d " " -f4`

SNMP_RESULT=`snmpget -v 2c -c $COMMUNITY $IP $USEDOID`
USED=`echo $SNMP_RESULT|cut -d " " -f4`

MAX=`echo "$FREE+$USED" |bc`

if [ "$MAX" -ne 0 ]; then


PERCFREE=`echo "$FREE*100/$MAX" |bc`
PERCUSED=`echo "$USED*100/$MAX" |bc`

#DEBUG: echo "FREE: $FREE USED: $USED MAX: $MAX PERC: $PERCFREE,$PERCUSED"

        if [ "$PERCFREE" -le "$WARN" -a "$PERCFREE" -gt "$CRIT" ]; then
        let "RETW += 1"
        STAT=( "${STAT[@]}" "Warning:\t$POOL - $PERCFREE% free - $PERCUSED% used - $USED/$MAX - Threshold is $WARN% free" )
        elif [ "$PERCFREE" -le "$CRIT" ]; then
        let "RETC += 1"
        STAT=( "${STAT[@]}" "Critical:\t$POOL - $PERCFREE% free - $PERCUSED% used - $USED/$MAX - Threshold is $CRIT% free" )
        else
        STAT=( "${STAT[@]}" "OK:\t$POOL\t - $PERCUSED% used - $USED/$MAX" )
        fi

#elif [ "$MAX" -eq 0 ]; then

        #Debug for detecting 100% excluded ranges (reservations only):
        #STAT=( "${STAT[@]}" "OK:\t$POOL\tNothing used, could be excluded" )



fi


# Performance-Data
#echo " | 'Scope Usage'=$PERCUSED%;$WARN;$CRIT;0;$MAX"
#echo -e " | $POOL OK - Usage: $PERCUSED% ($FREE Addresses of $MAX in pool free) \n"

done


#Evaluate return code:

if [ "$RETC" -eq 0 -a "$RETW" -eq 0 ]; then
        RET=0
        echo -e "OK:\tAll scopes fine"
elif [ "$RETW" -ne 0 -a "$RETC" -eq 0 ]; then
        RET=1
        echo  -e "Warning: One or more scopes is nearing capacity"
elif [ "$RETC" -ne 0 ]; then
        RET=2
        echo -e "Critical: One or more scopes is nearing capacity"
fi

###### Second loop for long service output:

for I in ${!STAT[*]};do
echo -e ${STAT[$I]}
done

#Echo the total amount of scopes available vs those shown:
echo -e "\nShowing ${#STAT[@]} of ${#TEMP[@]} configured scopes"

exit $RET
