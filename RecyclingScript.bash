#!/bin/bash

# general recycling script

# remember:
# $1 is the name of the container
# $2 is the attacker ip address
# $3 is the container ip address

# signal start of recycling script
echo "killer starting"

# kill the tail script
pkill -f "tailing_script.sh $1"

# kill the tailing process started by the tailscript
pkill -f "tail -f -n 1 var/lib/lxc/$1/rootfs/var/log/auth.log"

# kill the MITM tailing
pkill -f "node /root/MITM/mitm/index.js HACS200_2C 10000 $3 $1 true mitm.js"

# recycle time
pct stop $1
pct unmount $1
pct destroy $1

# creating the specified container
if [ $1 -eq 101 ] 
then
	pct create 101 
/var/lib/vz/template/cache/ubuntu-16.04-standard_16.04.5-1_amd64.tar.gz --storage local-lvm --nameserver 1.1.1.1 --searchdomain umd.edu --net0 name=eth0,ip=172.20.0.2/16,gw=172.20.0.1,bridge=vmbr0 --memory 512 --onboot true --password --swap 0 --cpulimit 0.5 --cores 1
elif [ $1 -eq 102 ] 
then
	pct create 102 
/var/lib/vz/template/cache/ubuntu-16.04-standard_16.04.5-1_amd64.tar.gz --storage local-lvm --nameserver 1.1.1.1 --searchdomain umd.edu --net0 name=eth0,ip=172.20.0.3/16,gw=172.20.0.1,bridge=vmbr0 --memory 512 --onboot true --password --swap 0 --cpulimit 0.5 --cores 1
elif [ $1 -eq 103 ] 
then
	pct create 103 
/var/lib/vz/template/cache/ubuntu-16.04-standard_16.04.5-1_amd64.tar.gz --storage local-lvm --nameserver 1.1.1.1 --searchdomain umd.edu --net0 name=eth0,ip=172.20.0.4/16,gw=172.20.0.1,bridge=vmbr0 --memory 512 --onboot true --password --swap 0 --cpulimit 0.5 --cores 1
elif [ $1 -eq 104 ] 
then
	pct create 104 
/var/lib/vz/template/cache/ubuntu-16.04-standard_16.04.5-1_amd64.tar.gz --storage local-lvm --nameserver 1.1.1.1 --searchdomain umd.edu --net0 name=eth0,ip=172.20.0.5/16,gw=172.20.0.1,bridge=vmbr0 --memory 512 --onboot true --password --swap 0 --cpulimit 0.5 --cores 1
fi

# start the container
pct start $1

# inputting the password
if [ $1 -eq 101 ] 
then
	echo -e "root\nroot101" | pct exec 101 passwd
elif [ $1 -eq 102 ]
then
	echo -e "root\nroot102" | pct exec 102 passwd
elif [ $1 -eq 103 ] 
then
	echo -e "root\nroot103" | pct exec 103 passwd
elif [ $1 -eq 104 ] 
then
	echo -e "root\nroot104" | pct exec 104 passwd
fi

# mount
pct mount $1

# change root login settings
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/g' /var/lib/lxc/$1/rootfs/etc/ssh/sshd_config

# service restart
pct exec $1 service ssh restart

# MITM transition steps
nohup node /root/MITM/mitm/index.js HACS200_2C 10000 $3 $1 true mitm.js > mitm_file 2>&1 &

# needed this to fix a bug
pct stop $1 && pct unmount $1
pct start $1 && pct mount $1

# random number generation determining whether to copy files or not
randNum=$RANDOM

if [ $((randNum%2)) = 0 ] 
then
	# code to transfer files
	cp -r /root/Backup_Files /var/lib/lxc/$1/rootfs/root/
	cp -r /root/Conferences_and_Meetings /var/lib/lxc/$1/rootfs/root/
	cp -r /root/Dates_and_Times /var/lib/lxc/$1/rootfs/root/
	cp -r /root/Documents /var/lib/lxc/$1/rootfs/root/
	cp -r /root/Downloads /var/lib/lxc/$1/rootfs/root/
	cp -r /root/Exported_Files /var/lib/lxc/$1/rootfs/root/
	cp -r /root/Imported_Files /var/lib/lxc/$1/rootfs/root/
	cp -r /root/International_Branches /var/lib/lxc/$1/rootfs/root/
	cp -r /root/IT_Department /var/lib/lxc/$1/rootfs/root/
	cp -r /root/Job_Applications /var/lib/lxc/$1/rootfs/root/
	cp -r /root/Marketing /var/lib/lxc/$1/rootfs/root/
	cp -r /root/Payroll /var/lib/lxc/$1/rootfs/root/
	cp -r /root/Portfolio /var/lib/lxc/$1/rootfs/root/
	cp -r /root/Project_Planning /var/lib/lxc/$1/rootfs/root/
	cp -r /root/Sponsors /var/lib/lxc/$1/rootfs/root/
	cp -r /root/Users /var/lib/lxc/$1/rootfs/root/
	cp -r /root/Volunteering /var/lib/lxc/$1/rootfs/root/
	cp -r /root/Workspace /var/lib/lxc/$1/rootfs/root/
fi

# iptables rules to prevent attacker re-entry and open the container for connections
#iptables --table filter --delete INPUT --in-interface enp4s2 --source $2 --protocol tcp --destination-port <PORTNUM> --jump ACCEPT
#iptables --table filter --delete INPUT --in-interface enp4s2 --source 0.0.0.0/0 --protocol tcp --destination-port <PORTNUM> --jump DROP
#iptables --table filter --insert INPUT 1 --in-interface enp4s2 --source $2 --destination $3 --jump DROP

# Rerun the tailing script **may need an output directory
nohup /root/Honeypot_Scripts/tailing_script.sh 2>&1 &
