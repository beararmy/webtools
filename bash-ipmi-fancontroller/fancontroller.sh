#!/bin/bash
# */1 * * * * root /stuff/fancontroller/fancontroller.sh 2>&1 >> /var/log/cron
# Example values are hex, ie 0x64 = 100%, 0x32 = 50%
# 0x16 - 5000 rpm
# 0x04 - 2000 rpm
# 0x06 - 2400 rpm
# 0x08 - 2800 rpm
# 0x12 - 4300 rpm
# passing 'raw 0x30 0x30 0x01 0x01' can be used to re-enable dynamic fans

# Config
IDRACIP="IP ADDRESS FOR DRAC INTERFACE"
IDRACUSER="LOGIN NAME, CREATED FOR IPMI"
IDRACPASSWORD="LOGIN PASSWORD, CREATED FOR IPMI"
TEMPTHRESHOLDLOW="36"      # First tier to spin the fans up
TEMPTHRESHOLDHIGH="42"     # Second tier
TEMPTHRESHOLDVERYHIGH="46" # Top tier
DATE=$(date +%Y-%m-%d-%H_%M_%S)

# Get CPU temperature
T=$(ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD sensor | grep "^Temp" | grep degrees | awk '{print $3}' | cut -d. -f1)

# Do the needy
if [[ $T > $TEMPTHRESHOLDLOW ]]; then
    ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x01 0x00 >>/dev/null #0x01 will re-enable dynamic fans
    echo -n "[$DATE] Drac for $IDRACIP, setting fan to 2400 rpm based on temp of $T and threshold of $TEMPTHRESHOLDLOW"
    ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x02 0xff 0x06

elif [[ $T > $TEMPTHRESHOLDHIGH ]]; then
    ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x01 0x00 >>/dev/null
    echo -n "[$DATE] Drac for $IDRACIP, setting fan to 4300 rpm based on temp of $T and threshold of $TEMPTHRESHOLDHIGH"
    ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x02 0xff 0x12

elif [[ $T > $TEMPTHRESHOLDVERYHIGH ]]; then
    ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x01 0x00 >>/dev/null
    echo -n "[$DATE] Drac for $IDRACIP, setting fan to 7200 rpm based on temp of $T and threshold of $TEMPTHRESHOLDVERYHIGH"
    ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x02 0xff 0x24

else
    ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x01 0x00 >>/dev/null
    echo -n "[$DATE] Drac for $IDRACIP, setting fan to 2000 rpm based on temp of $T and thresholds not met"
    ipmitool -I lanplus -H $IDRACIP -U $IDRACUSER -P $IDRACPASSWORD raw 0x30 0x30 0x02 0xff 0x04

fi
