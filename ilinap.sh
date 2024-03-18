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
	new_networkd_file=$(basename $networkd_file)
	cp -r $new_networkd_file > network/network_interface/$new_networkd_file
    done
    if ! $(command -v netstat &>/dev/null)
    then
	apt install net-tools -y &>/dev/null
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
            cp $user/.bashrc mac_bash_files/basename_user.bashrc
	fi
    	if [ -n $user/.bash_history ]
	then
            cp $user/.bash_history mac_bash_files/basename_user.bash_history
    	fi
	if [ -d $user/.bash_sessions/ ]
	then
	    mkdir $basename_user.bash_sessions
	    cp $user/.bash_sessions/* mac_bash_files/$basename_user.bash_sessions/
    	fi
	if [ -n $user/.bash_profile ]
    	then
	    cp $user/.bash_profile mac_bash_files/$basename_user.bash_profile
    	fi
	if [ -n $user/.profile ]
    	then
	    cp $user/.profile mac_bash_files/$basename_user.profile
    	fi
	if [ -n $user/.bash_logout ]
    	then
	    cp $user/.bash_logout mac_bash_files/$basename_user.bash_logout
    	fi
    done
    for puser in /private/var/*/
    do
    	basename_puser=$(basename $puser)
	if [ -n $puser/.bash_history ]
    	then
	    cp $puser/.bash_history mac_bash_files/$basename_puser.bash_history
    	fi
	if [ -d $puser/.bash_sessions ]
    	then
	    mkdir mac_bash_files/$basename_puser.bash_sessions
	    cp -r $puser/.bash_sessions/* mac_bash_files/$basename_puser.bash_sessions/ 
    	fi
	if [ -n /private/etc/profile ]
    	then
	    cp /private/etc/profile mac_bash_files/private.etc.profile
    	fi
	if [ -n /private/etc/bashrc* ]
	then
	    cp /privat/etc/bashrc* mac_bash_files/private.etc.bashrc*
    	fi
    done
}

mac_autoruns () {
    if [ $mac_version -ge "10.10" ]
    then
       if [ -n /private/var/db/com.apple.xpc.launchd/disabled.*.plist ] 
       then
	   plutil -p /private/var/db/com.apple.xpc.launchd/disabled.*.plist > mac_autoruns/disabled-*-plist
       fi 
       if [ -n /private/var/at/tabs/* ]     #; crontab
       then
	   plutil -p /private/var/at/tabs/* > mac_autoruns/*
       fi
       if [ -n /System/Library/LaunchAgents/*.plist ]    #; LaunchAgents
       then
	   plutil -p /System/Library/LaunchAgents/*.plist > mac_autoruns/*-plist
       fi
       if [ -n /Library/LaunchAgents/*.plist ]
       then
	   plutil -p /Library/LaunchAgents/*.plist > mac_autoruns/*-plist
       fi
       if [ -n /Users/*/Library/LaunchAgents/*.plist ]
       then
	   plutil -p /Users/*/Library/LaunchAgents/*.plist > mac_autouns/*-plist
       fi
       if [ -n /private/var/*/Library/LaunchAgents/*.plist ]
       then
	   plutil -p /private/var/*/Library/LaunchAgents/*.plist > mac_autoruns/*-plist
       fi
       if [ -n /System/Library/LaunchAgents/.*.plist ]
       then
	   plutil -p /System/Library/LaunchAgents/.*.plist mac_autoruns/.*-plist
       fi
       if [ -n /Library/LaunchAgents/.*.plist ]
       then
	   plutil -p /Library/LaunchAgents/.*.plist > mac_autoruns/.*-plist
       fi
       if [ -n /Users/*/Library/LaunchAgents/.*.plist ]
       then
	   plutil -p /Users/*/Library/LaunchAgents/.*.plist > mac_autoruns/.*-plist
       fi
       if [ -n /private/var/*/Library/LaunchAgents/.*.plist ]
       then
	   plutil -p /private/var/*/Library/LaunchAgents/.*.plist > mac_autoruns/.*-plist
       fi
    fi
    if [ $mac_version -ge "10.15" ]
    then
	if [ -n /Library/Apple/System/Library/LaunchAgents/*.plist ]
	then
	    plutil -p /Library/Apple/System/Library/LaunchAgents/*.plist > mac_autoruns/*-plist
	fi
	if [ -n /Library/Apple/System/Library/LaunchAgents/.*.plist ]
	then
	    plutil -p /Library/Apple/System/Library/LaunchAgents/.*.plist > mac_autoruns/*-plist
	fi
	if [ -n /System/Library/LaunchDaemons/*.plist ]     #; LaunchDaemons
	then
	    plutil -p /System/Library/LaunchDaemons/*.plist > mac_autoruns/*-plist
	fi
	if [ -n /Library/LaunchDaemons/*.plist ]
	then
	    plutil -p /Library/LaunchDaemons/*.plist > mac_autoruns/*-plist
	fi
	if [ -n /System/Library/LaunchDaemons/.*.plist ]
	then
	    plutil -p /System/Library/LaunchDaemons/.*.plist > mac_autoruns/*-plist
	fi
	if [ -n /Library/LaunchDaemons/.*.plist ]
	then
	    plutil -p /Library/LaunchDaemons/.*.plist > mac_autoruns/*-plist
	fi
	if [ -n /Library/Apple/System/Library/LaunchDaemons/*.plist ]
	    plutil -p /Library/Apple/System/Library/LaunchDaemons/*.plist > mac_autoruns/*-plist
	fi
	if [ -n /Library/Apple/System/Library/LaunchDaemons/.*.plist ]
	then
	    plutil -p /Library/Apple/System/Library/LaunchDaemons/.*.plist > mac_autoruns/.*-plist
	fi
	if [ -n /System/Library/ScriptingAdditions/*.osax ]        #; ScriptingAdditions
	then
	    cp /System/Library/ScriptingAdditions/*.osax > mac_autoruns/*-osax
	fi
	if [ -n /Library/ScriptingAdditions/*.osax ]
	then
	    cp /Library/ScriptingAdditions/*.osax mac_autoruns/*-osax
	fi
	if [ -n /System/Library/ScriptingAdditions/.*.osax ]
	then
	    cp /System/Library/ScriptingAdditions/.*.osax mac_autoruns/.*-osax
	fi
	if [ -n /Library/ScriptingAdditions/.*.osax ]
	then
	    cp /Library/ScriptingAdditions/.*.osax mac_autoruns/.*-osax
	fi
	if [ -n /System/Library/StartupItems/*/* ]          #; StartupItems
	then
	    cp /System/Library/StartupItems/*/* mac_autoruns/*/*
	fi
	if [ -n /Library/StartupItems/*/* ]
	then
	    cp /Library/StartupItems/*/* mac_autoruns/*/*
	fi
	if [ -n /private/etc/periodic.conf ]          #; periodic, rc, emond
	then
	    cp /private/etc/periodic.conf mac_autoruns/periodic.conf
	fi
	if [ -n /private/etc/periodic/*/* ]
	then
	    cp /private/etc/periodic/*/* mac_autoruns/*/*
	fi
	if [ -n /private/etc/*.local ]
	then
	    cp /private/etc/*.local mac_autoruns/*.local
	fi
	if [ -n /private/etc/rc.common ]
	then
	    cp /private/etc/rc.common mac_autoruns/rc.common
	fi
	if [ -n /private/etc/emond.d/*/* ]
	then
	    cp /private/etc/emond.d/*/* mac_autoruns/*/*
	fi
	if [ -n /Users/*/Library/Preferences/com.apple.loginitems.plist ]      #; user login items
	then
	    plutil -p /Users/*/Library/Preferences/com.apple.loginitems.plist mac_autoruns/com.apple.loginitems.plist
	fi
	if [ -n /private/var/*/Library/Preferences/com.apple.loginitems.plist ]
	then
	    plutil -p /private/var/*/Library/Preferences/com.apple.loginitems.plist mac_autoruns/com.apple.loginitems.plist
	fi
    fi
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
	bash_function       
	system_service      
	os_release          
	hostname            
	location            
	ip_address          
	process             
	user_group      
	sudoers_file    
	log_files           
	viminfo_file        
	sudo_execution_history  
    else
	echo Please run this script with sudo 
	exit
    fi
elif [ $(uname) = 'Darwin' ]
then
    mac_version=$( sw_vers |awk -F '[ .]' '/ProductVersion/ {print $1"."$2}')
    mkdir mac_bash_files mac_autoruns
else
    echo "This is not MacOS or Linux sorry"
fi
