# IPMI Fan controller

I installed non-Dell (_how dare I?!_) hardware into my R7910 the fans sit around 5000 rpm each because of a 'non-oem hardware profile'. This is not acceptable for a quiet office so I have enabled IPMI over Network from within the iDRAC and manually turn runs up and down. I know this ESX host is rarely CPU stressed so am comforable with long check durations.

## Drac Config

I add another user specifically for this. No other permissions should be required.

### Create a user
1. Overview > iDRAC Settings > User Authentication

2. Click on a user number.

3. Under IPMI User Privileges
Set "Maximum LAN User Privilege Granted" to *Administrator*


### Enable IPMI

We also then need to enable IPMI over LAN

1.  Overview > iDRAC Settings > Network > IPMI Settings

2. Check the "Enable IPMI Over LAN" box

## Notes

There is am [esxi vib package](https://vswitchzero.com/ipmitool-vib/) someone has compiled to allow this to run directly on the ESX host itself. But this is not my chosen path so here we are. \o/