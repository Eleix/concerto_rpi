#!/bin/bash
echo "Initiating Auto-Installer"

# Checks to see if the user running this script is root
if [ "$EUID" -ne 0 ]   
	then echo "Error, Please run this script as root"
	exit
fi

#Checks for and updates the system before installing the necessary tools.
apt-get update && apt-get upgrade -y
apt-get install git chromium-browser vim xdotool -y

#moves to the pi user's home directory and clones the concerto install script
cd ~pi/
git clone https://github.com/tranquilitycal/concerto_rpi
chown -R pi:pi *
cd ~pi/concerto_rpi
chmod +x InstallConcertoForPi.sh

#alerts user that the concerto installer is ready and launches it.
echo "Switching to Concerto Install Script"
sleep 2s
sudo -u pi bash /home/pi/concerto_rpi/InstallConcertoForPi.sh
#Gives the concerto script time to create its .lock file for this script to wait until its lock file is removed to continue.
sleep 2s
echo "Waiting for concerto script to finish up."

#checks for a lock file created by the concerto installer.
while [ -f ~pi/concerto.lock ] 
        do
		sleep 5;
done
echo "Concerto Install Complete"

#At this point the script begins doing redundant housework that the concerto script has left behind.
echo "Finishing Up"
chown -R pi:pi /home/pi/*
#Links nss library for Chromium
ln -s /usr/lib/arm-linux-gnueabihf/nss/ /usr/lib/nss
/bin/echo '0 0 * * * apt-get update && apt-get upgrade -y > /var/log/updater/midnight-update_$(date +\%m\%d\%Y).log &> /dev/null' >> ./.tmp
/usr/bin/crontab -u root ./.tmp
#grace period for crontab to be updated with the midnight update script then remove the file since its no longer needed.
sleep 2
rm -rf ./.tmp

#Script is finished, System is rebooted at the end of the script.
echo "Finished Setup"
echo ""
echo "Initiating reboot"
sleep 2
reboot
