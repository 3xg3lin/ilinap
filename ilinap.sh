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
    for disabled in /private/var/db/com.apple.launchd/disabled.*.plist
    do
	disabled_main=$(basename $disabled)
	if [ -n $disabled ] 
	then
	    plutil -p $disabled > mac_autoruns/$disabled_main
	fi 
    done
    for at_tabs in /private/var/at/tabs/*
    do
	at_tabs_main=$(basename $at_tabs)
	if [ -n $at_tabs ]     #; crontab
	then
	    cp $at_tabs > mac_autoruns/$at_tabs_main
	fi
    done
    for launchagent in /System/Library/LaunchAgents/*.plist
    do
	launchagent_main=$(basename $launchagent)
	if [ -n $launchagent ]    #; LaunchAgents
	then
	    plutil -p $launchagent_main > mac_autoruns/$launchagent_main
	fi
    done
    for l_launchagent in /Library/LaunchAgents/*.plist  
    do
	l_launchagent_main=$(basename $l_launchagent)
	if [ -n l_launchagent ]
	then
	    plutil -p l_launchagent > mac_autoruns/l_launchagent_main
	fi
    done
    for u_launchagent in /Users/*/Library/LaunchAgents/*.plist 
    do
	u_launchagent_main=$(basename $u_launchagent)
	if [ -n $u_launchagent ]
	then
	    plutil -p $u_launchagent > mac_autouns/$u_launchagent_main
	fi
    done
    for p_launchagent in /private/var/*/Library/LaunchAgents/*.plist 
    do
	p_launchagent_main=$(basename $p_launchagent)
	if [ -n $p_launchagent ]
	then
	    plutil -p $p_launchagent > mac_autoruns/$p_launchagent_main
	fi
    done
    for s_launchagent in /System/Library/LaunchAgents/.*.plist 
    do
	s_launchagent_main=$(basename $s_launchagent)
	if [ -n $s_launchagent ]
	then
	    plutil -p $s_launchagent mac_autoruns/$s_launchagent_main
	fi
    done
    for ll_launchagent in /Library/LaunchAgents/.*.plist 
    do
	ll_launchagent_main=$(basename $ll_launchagent)
	if [ -n $ll_launchagent ]
	then
	    plutil -p $ll_launchagent > mac_autoruns/$ll_launchagent_main
	fi
    done
    for ul_launchagent in /Users/*/Library/LaunchAgents/.*.plist
    do
	ul_launchagent_main=$(basename $ul_launchagent)
	if [ -n $ul_launchagent ]
	then
	    plutil -p $ul_launchagent > mac_autoruns/$ul_launchagent_main
	fi
    done
    for pl_launchagent in /private/var/*/Library/LaunchAgents/.*.plist 
    do
	pl_launchagent_main=$(basename $pl_launchagent)
	if [ -n $pl_launchagent ]
	then
	    plutil -p $pl_launchagent > mac_autoruns/$pl_launchagent_main
	fi
    done
    for ls_launchagent in /Library/Apple/System/Library/LaunchAgents/*.plist  
    do
	ls_launchagent_main=$(basename $ls_launchagent)
	if [ -n $ls_launchagent ]
	then
	    plutil -p $ls_launchagent > mac_autoruns/ls_launchagent_main
	fi
    done
    for las_launchagent in /Library/Apple/System/Library/LaunchAgents/.*.plist
    do
	las_launchagent_main=$(basename $las_launchagent)
	if [ -n $las_launchagent ]
	then
	    plutil -p $las_launchagent > mac_autoruns/$las_launchagent_main
	fi
    done
    for sl_launchdemon in /System/Library/LaunchDaemons/*.plist
    do
	sl_launchdemon_main=$(basename $sl_launchdemon)
	if [ -n $sl_launchdemon ]     #; LaunchDaemons
	then
	    plutil -p $sl_launchdemon > mac_autoruns/$sl_launchdemon_main
	fi
    done
    for l_launchdemon in /Library/LaunchDaemons/*.plist
    do
	l_launchdemon_main=$(basename $l_launchdemon)
	if [ -n $l_launchdemon ]
	then
	    plutil -p $l_launchdemon > mac_autoruns/$l_launchdemon_main
	fi
    done
    for hsl_launchdemon in /System/Library/LaunchDaemons/.*.plist
    do
	hsl_launchdemon_main=$(basename $hsl_launchdemon)
	if [ -n $hsl_launchdemon ]
	then
	   plutil -p $hsl_launchdemon > mac_autoruns/$hsl_launchdemon_main
	fi
    done
    for hl_launchdemon in /Library/LaunchDaemons/.*.plist
    do
	hl_launchdemon_main=$(basename $hl_launchdemon)
	if [ -n $hl_launchdemon ]
	then
	    plutil -p $hl_launchdemon > mac_autoruns/$hl_launchdemon_main
	fi
    done
    for las_launchdemon in /Library/Apple/System/Library/LaunchDaemons/*.plist
    do
	las_launchdemon_main=$(basename $las_launchdemon)
	if [ -n $las_launchdemon ]
	then
	   plutil -p $las_launchdemon > mac_autoruns/$las_launchdemon_main
	fi
    done
    for hlas_launchdemon in /Library/Apple/System/Library/LaunchDaemons/.*.plist 
    do
	hlas_launchdemon_main=$(basename $hlas_launchdemon)
	if [ -n /Library/Apple/System/Library/LaunchDaemons/.*.plist ]
	then
	    plutil -p $hlas_launchdemon > mac_autoruns/$hlas_launchdemon_main
	fi
    done
    for sl_script_add in /System/Library/ScriptingAdditions/*.osax
    do
	sl_script_add_main=$(basename $sl_script_add)
	if [ -n $sl_script_add ]        #; ScriptingAdditions
	then
	    cp $sl_script_add > mac_autoruns/sl_script_add_main
	fi
    done
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
    mac_version_first_part=$( sw_vers |awk -F '[ .]' '/ProductVersion/ {print $1}'|sed 's/ProductVersion\://g' )
    mac_version_second_part=$( sw_vers |awk -F '[ .]' '/ProductVersion/ {print $2}'|sed 's/ProductVersion\://g' ) 
    mkdir mac_bash_files mac_autoruns
else
    echo "This is not MacOS or Linux sorry"
fi
