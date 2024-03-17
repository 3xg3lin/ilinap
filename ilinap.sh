#!/bin/bash
# This tool for linux and macOS artifact parser
#

bash_function () {          # bashrc and cron output
    for user in ${users[*]}
    do
	if [ -n /home/$user/.bashrc ]
	then
	    sudo cp /home/$user/.bashrc bash_files/$user.bashrc 2>/dev/null
	fi
	if [ -n /home/$user/.bash_profile ]
	then
	    sudo cp /home/$user/.bash_profile bash_files/$user.bash_profile 2>/dev/null
	fi
	if [ -n /home/$user/.bash_login ]
	then
	    sudo cp /home/$user/.bash_login bash_files/$user.bash_login 2>/dev/null
	fi
	if [ -n /home/$user/.bash_logout ]
	then 
	    sudo cp /home/$user/.bash_logout bash_files/$user.bash_logout 2>/dev/null
	fi
	if [ -n /var/spool/cron/crontabs/$user ]
	then
	    sudo cp /var/spool/cron/crontabs/$user crontab_files/$user.crontab 2>/dev/null
	fi
    done
}

system_service () {
    if [ -d /lib/systemd/system ]
    then
	systemctl status --type=service > services/service_running
	ls -a /lib/systemd/system/* > services/all_services
    fi
}

os_release () {            # os-release
    if [ -n /etc/os-release ]
    then
	echo "/etc/os-release is $(cat /etc/os-release)" > result
    fi
}

hostname () {            # hostname output
    if [ -n /etc/hostname ]
    then
	echo "/etc/hostname is $(cat /etc/hostname)" >> result
    fi
}

location () {            # Localtime and timezone
    if [ -n /etc/timezone ]
    then
	echo "/etc/timezone is $(cat /etc/timezone)" >> result
    fi
}

ip_address () {         # Ip addres and network output
    ip a > network/ip_command
    for networkd_file in /etc/network/interfaces.d/*
    do
	cp $networkd_file > network/network_interface/$networkd_file
    done
    if ! $(command -v netstat)
    then
	apt install net-tool -y
    fi
    netstat -natup > network/netstat_output
    cat /etc/hosts > network/hosts_output
    cat /etc/resolv.conf > network/revolv.conf
}

process () {           # Process output 
    ps aux > process/ps_output
}

user_group () {       # /etc/passwd file
    cat /etc/passwd| column -t -s : > passwd/passwd_output

    # /etc/groups output
    cat /etc/group| column -t -s : > groups/groups_output
}

sudoers_file () {        # sudoers file
if [ -n /etc/sudoers ]
then
    cp /etc/sudoers sudoers/sudoers_output 
else
    echo "Please login with root account"
    cp /etc/sudoers sudoers/sudoers_output
fi
}

log_files () {              # login failure and historical data
    if [ -n /var/log/btmp ]
    then
	last -f /var/log/btmp > login_log/btmp
    fi
    if [ -n /var/log/wtmp ]
    then
	last -f /var/log/wtmp > login_log/wmtp
    fi
    if [ -n /var/run/utmp ]
    then
	last -f /var/run/utmp > login_log/utmp
    fi
}

viminfo_file () {           # viminfo file copy
    for user in ${users[*]}
    do
	if [ -n /home/$user/.viminfo ]
	then
	    cp /home/$user/.viminfo vim_file/$user.viminfo 
	fi
    done
}

sudo_execution_history () {
    journalctl --facility=4,10 > sudo_execution/sudo_execution_hist
}
## Until this part contain macOS function
mac_bash_file () {
    for user in /Users/*/
    do
	basename_user=$(basename $user)
	if [ -n $user/.bashrc ]
	then
	    	    cp $user/.bashrc basename_user.bashrc
	fi
	if [ -n $user/.bash_history ]
	then
	    cp $user/.bash_history basename_user.bash_history
	fi
	if [ -d $user/.bash_sessions/ ]
	then
	    mkdir $basename_user.bash_sessions
	    cp $user/.bash_sessions/* $basename_user.bash_sessions/
	fi
	if [ -n $user/.bash_profile ]
	then
	    cp $user/.bash_profile $basename_user.bash_profile
	fi
	if [ -n $user/.profile ]
	then
	    cp $user/.profile $basename_user.profile
	fi
	if [ -n $user/.bash_logout ]
	then
	    cp $user/.bash_logout $basename_user.bash_logout
	fi
    done
    for puser in /private/var/*/
    do
	basename_puser=$(basename $puser)
	if [ -n $puser/.bash_history ]
	then
	    cp $puser/.bash_history $basename_puser.bash_history
	fi
	if [ -d $puser/.bash_sessions ]
	then
	    mkdir $basename_puser.bash_sessions
	    cp $puser/.bash_sessions/* $basename_puser.bash_sessions/ 
	fi
	if [ -n /private/etc/profile ]
	then
	    cp /private/etc/profile private.etc.profile
	fi
	if [ -n /private/etc/bashrc* ]
	then
	    cp /privat/etc/bashrc* private.etc.bashrc*
	fi
    done
}



if [ $(uname) = 'Linux' ]
then
    if [ "$EUID" -eq 0 ]
    then

	mkdir artifacts bash_files crontab_files services process passwd groups sudoers login_log vim_file sudo_execution
	for user in $(awk -F: '{if ($6 ~ /^\/home/ ) print $1}' /etc/passwd)
	do
	    users+=($user)
	done
	touch result
	mkdir -p network/network_interface
	bash_function       # working
	system_service      # not working
	os_release          # working
	hostname            # working
	location            # working
	ip_address          # not working
	process             # not working
	user_group          # not working
	sudoers_file        # not working
	log_files           # not working
	viminfo_file        # working
	sudo_execution_history  #working
    else
	echo Please run this script with sudo 
	exit
    fi
elif [ $(uname) = 'Darwin' ]
then
    echo "This is MacOS"
else
    echo "This is not MacOS or Linux sorry"
fi
