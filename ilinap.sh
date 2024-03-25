#!/bin/bash
# This tool for linux and macOS artifact parser
#

bash_function () {          # bashrc and cron output
    if ! [ -d $linux_parser_file/home ]
    then
	mkdir $linux_parser_file/home
    fi
    if ! [ -d $linux_parser_file/var/spool/cron/crontabs ]
    then
	mkdir -p $linux_parser_file/var/spool/cron/crontabs/
    fi
    for user in ${users[*]}
    do
	if ! [ -d $linux_parser_file/home/$user ]
	then
	    mkdir -p $linux_parser_file/home/$user
	fi
	if [ -n /home/$user/.bashrc ]
	then
	    sudo cp /home/$user/.bashrc $linux_parser_file/home/$user/.bashrc 2>/dev/null
	fi
	if [ -n /home/$user/.bash_profile ]
	then
	    sudo cp /home/$user/.bash_profile $linux_parser_file/home/$user/.bash_profile 2>/dev/null
	fi
	if [ -n /home/$user/.bash_login ]
	then
	    sudo cp /home/$user/.bash_login $linux_parser_file/home/$user/.bash_login 2>/dev/null
	fi
	if [ -n /home/$user/.bash_logout ]
	then 
	    sudo cp /home/$user/.bash_logout $linux_parser_file/home/$user/.bash_logout 2>/dev/null
	fi
	if [ -n /var/spool/cron/crontabs/$user ]
	then
	    sudo cp /var/spool/cron/crontabs/$user $linux_parser_file/var/spool/cron/crontabs/$user 2>/dev/null
	fi
    done
}

system_service () {
    if [ -d /lib/systemd/system ]
    then
#	systemctl status --type=service > services/service_running
	if ! [ -d $linux_parser_file/lib/systemd/system ]
	then
	    mkdir $linux_parser_file/lib/systemd/system
	fi
	for service_all in /lib/systemd/system/* 
	do
	    main_service=$(basename $service_all)
	    cp -r $service_all > $linux_parser_file/lib/systemd/system/$main_service
	done
    fi
}

os_release () {            # os-release
    if [ -n /etc/os-release ]
    then
	if ! [ -d $linux_parser_file/etc/ ]
	then
	    mkdir $linux_parser_file/etc
	fi
	cp /etc/os-release $linux_parser_file/etc/os-release
    
    fi
}

hostname () {            # hostname output
    if [ -n /etc/hostname ]
    then
	if ! [ -d $linux_parser_file/etc/ ]
	then
	    mkdir $linux_parser_file/etc
	fi
    cp /etc/hostname $linux_parser_file/etc/hostname
    fi
}

location () {            # Localtime and timezone
    if [ -n /etc/timezone ]
    then
	if ! [ -d $linux_parser_file/etc/ ]
	then
	    mkdir $linux_parser_file/etc
	fi
	cp /etc/timezone $linux_parser_file/etc/timezone
    fi
}

ip_address () {         # Ip addres and network output
    ip a > $linux_parser_file/ip_a_command
    if [ -d /etc/network/interfaces.d/ ]
    then
	if ! [ -d $linux_parser_file/etc ]
	then
	    mkdir -p $linux_parser_file/etc
	fi
	if ! [ -d $linux_parser_file/etc/network ]
	then
	    mkdir -p $linux_parser_file/etc/network
	fi
	for networkd_file in /etc/network/interfaces.d/*
	do
	    new_networkd_file=$(basename $networkd_file)
	    cp -r $networkd_file > $linux_parser_file/etc/network/$new_networkd_file
	done
    fi
    if ! $(command -v netstat &>/dev/null)
    then
	apt install net-tools -y &>/dev/null
    fi
    netstat -natup > $linux_parser_file/netstat_natup_output
    cp /etc/hosts > $linux_parser_file/etc/hosts
    cp /etc/resolv.conf > $linux_parser_file/etc/revolv.conf
}

process () {           # Process output 
    ps aux > $linux_parser_file/ps_aux_output
}

user_group () { 
    if ! [ -d $linux_parser_file/etc ]
    then
	mkdir $linux_parser_file/etc
    fi
    cat /etc/passwd| column -t -s : > $linux_parser_file/etc/passwd

    cat /etc/group| column -t -s : > $linux_parser_file/etc/group
}

sudoers_file () {        # sudoers file
    if ! [ -d $linux_parser_file/etc ]
    then
	mkdir -p $linux_parser_file/etc 
    fi
    if [ -n /etc/sudoers ]
    then
	cp /etc/sudoers $linux_parser_file/etc/sudoers 
    fi
}

log_files () {              # login failure and historical data
    if ! [ -d $linux_parser_file/var ]
    then
	mkdir -p $linux_parser_file/var/{log,run}
    fi
    if ! [ -d $linux_parser_file/var/log ]
    then
	mkdir -p $linux_parser_file/var/log
    fi
    if [ -d $linux_parser_file/var/run ]
    then
	mkdir -p $linux_parser_file/var/run
    fi
    if [ -n /var/log/btmp ]
    then
	last -f /var/log/btmp > $linux_parser_file/var/log/btmp
    fi
    if [ -n /var/log/wtmp ]
    then
	last -f /var/log/wtmp > $linux_parser_file/var/log/wmtp
    fi
    if [ -n /var/run/utmp ]
    then
	last -f /var/run/utmp > $linux_parser_file/var/run/utmp
    fi
}

viminfo_file () {           # viminfo file copy
    if ! [ -d $linux_parser_file/home ]
    then
	mkdir -p $linux_parser_file/home
    fi
    for user in ${users[*]}
    do
	if ! [ -d $linux_parser_file/home/$user ]
	then
	    mkdir -p $linux_parser_file/home/$user 
	fi
	if [ -n /home/$user/.viminfo ]
	then
	    cp /home/$user/.viminfo $linux_parser_file/home/$user/.viminfo 
	fi
    done
}

sudo_execution_history () {
    journalctl --facility=4,10 > $linux_parser_file/sudo_execution_history
}
## Until this part contain macOS function
mac_bash_file () {
    if ! [ -d $macos_parser_file/home ]
    then
	mkdir -p $macos_parser_file/home
    fi
    for user in /Users/*/
    do
	basename_user=$(basename $user)
	if [ -d $macos_parser_file/home/$basename_user ]
	then
	    mkdir -p $macos_parser_file/home/$basename_user
	fi
    	if [ -n $user/.bashrc ]
	then
            cp $user/.bashrc $macos_parser_file/home/$basename_user/.bashrc
	fi
    	if [ -n $user/.bash_history ]
	then
            cp $user/.bash_history $macos_parser_file/home/$basename_user/.bash_history
    	fi
	if [ -d $user/.bash_sessions/ ]
	then
	    mkdir $basename_user.bash_sessions
	    cp $user/.bash_sessions/* $linux_parser_file/home/$basename_user/.bash_sessions/
    	fi
	if [ -n $user/.bash_profile ]
    	then
	    cp $user/.bash_profile $macos_parser_file/home/$basename_user/.bash_profile
    	fi
	if [ -n $user/.profile ]
    	then
	    cp $user/.profile $macos_parser_file/home/$basename_user/.profile
    	fi
	if [ -n $user/.bash_logout ]
    	then
	    cp $user/.bash_logout $macos_parser_file/home/$basename_user/.bash_logout
    	fi
    done
    for puser in /private/var/*
    do
	if ! [ -d $macos_parser_file/private ]
	then
	    mkdir -p $macos_parser_file/private/var
	fi
	if ! [ -d $macos_parser_file/private/var ]
	then
	    mkdir -p $macos_parser_file/private/var
	fi
    	basename_puser=$(basename $puser)
	if [ -n $puser/.bash_history ]
    	then
	    cp $puser/.bash_history $macos_parser_file/private/var/$basename_puser/.bash_history
    	fi
	if [ -d $puser/.bash_sessions ]
    	then
	    mkdir -p $macos_parser_file/private/var/$basename_puser/.bash_sessions
	    cp -r $puser/.bash_sessions/* $macos_parser_file/private/var/$basename_puser/.bash_sessions/ 
    	fi
	if [ -n /private/etc/profile ]
    	then
	    cp /private/etc/profile $macos_parser_file/private/etc/profile
    	fi
	if [ -n /private/etc/bashrc* ]
	then
	    cp /privat/etc/bashrc* $macos_parser_file/private/etc/bashrc*
    	fi
    done
}

mac_autoruns () {
    if ! [ -d $macos_parser_file/private/var/at/tabs ]
    then
	mkdir -p $macos_parser_file/private/var/db/com.apple.xpc.launchd/
    fi
    if ! [ -d $macos_parser_file/private/var/db/com.apple.xpc.launchd/ ]
    then
	mkdir -p $macos_parser_file/private/var/db/com.apple.xpc.launchd/
    fi
    if ! [ -d $macos_parser_file/System/Library/LaunchAgents/ ]
    then
	mkdir -p $macos_parser_file/System/Library/LaunchAgents/
    fi
    if ! [ -d $macos_parser_file/Library/LaunchAgents/ ]
    then
	mkdir -p $macos_parser_file/Library/LaunchAgents/
    fi
    for disabled in /private/var/db/com.apple.xpc.launchd/disabled*.plist
    do
	disabled_main=$(basename $disabled)
	if [ -n $disabled ] 
	then
	    plutil -p $disabled > $macos_parser_file/private/var/db/com.apple.xpc.launchd/$disabled_main
	fi 
    done
    for at_tabs in /private/var/at/tabs/*
    do
	at_tabs_main=$(basename $at_tabs)
	if [ -n $at_tabs ]     #; crontab
	then
	    cp $at_tabs > $macos_parser_file/private/var/at/tabs/$at_tabs_main
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
    for m_user in /Users/*
    do
	m_user_main=$(basename $m_user)
	for u_launchagent in $m_user/Library/LaunchAgents/*.plist 
	do
	    u_launchagent_main=$(basename $u_launchagent)
	    if [ -n $u_launchagent ]
	    then
		plutil -p $u_launchagent > $macos_parser_file/Users/$m_user_main/Library/LaunchAgents/$u_launchagent_main
	    fi
	done
    done
    for p_user in /private/var/*
    do
	p_user_basename=$(basename $p_user)
	for p_launchagent in /private/var/$p_user_basename/Library/LaunchAgents/*.plist 
	do
	    if ! [ -d $macos_parser_file/private/var/$p_user_basename/Library/LaunchAgents/ ]
	    then
		mkdir -p $macos_parser_file/private/var/$p_user_basename/Library/LaunchAgents
	    fi
	    p_launchagent_main=$(basename $p_launchagent)
	    if [ -n $p_launchagent ]
	    then
		plutil -p $p_launchagent > $macos_parser_file/private/var/$p_user_basename/Library/LaunchAgents/$p_launchagent_main
	    fi
	done
    done
    for s_launchagent in /System/Library/LaunchAgents/.*.plist 
    do
	s_launchagent_main=$(basename $s_launchagent)
	if ! [ -d $macos_parser_file/System/Library/LaunchAgents ]
	then
	    mkdir -p $macos_parser_file/System/Library/LaunchAgents
	fi
	if [ -n $s_launchagent ]
	then
	    plutil -p $s_launchagent > $macos_parser_file/System/Library/LaunchAgents/$s_launchagent_main
	fi
    done
    for ll_launchagent in /Library/LaunchAgents/.*.plist 
    do
	ll_launchagent_main=$(basename $ll_launchagent)
	if [ -d $macos_parser_file/Library/LaunchAgents ]
	then
	    mkdir -p $macos_parser_file/Library/LaunchAgents
	fi
	if [ -n $ll_launchagent ]
	then
	    plutil -p $ll_launchagent > $macos_parser_file/Library/LaunchAgents/$ll_launchagent_main
	fi
    done
    for ll_user in /Users/*
    do
	ll_user_basename=$(basename $ll_user)
	for ul_launchagent in /Users/$ll_user_basename/Library/LaunchAgents/.*.plist
	do
	    ul_launchagent_main=$(basename $ul_launchagent)
	    if ! [ -d /Users/$ll_user_basename/Library/LaunchAgents ]
	    then
		mkdir -p $macos_parser_file/Users/$ll_user_basename/Library/LaunchAgents
	    fi
	    if [ -n $ul_launchagent ]
	    then
		plutil -p $ul_launchagent > $macos_parser_file/Users/$ll_user_basename/Library/LaunchAgents/$ul_launchagent_main
	    fi
	done
    done
    for p_var in /private/var/*
    do
	ip_var_main=$(basename $p_var)
	for pl_launchagent in /private/var/$p_var_main/Library/LaunchAgents/.*.plist 
	do
	    pl_launchagent_main=$(basename $pl_launchagent)
	    if [ -n $pl_launchagent ]
	    then
		plutil -p $pl_launchagent > $macos_parser_file/private/var/$p_var_main/Library/LaunchAgents/$pl_launchagent_main
	    fi
	done
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
	    cp -r $sl_script_add > mac_autoruns/sl_script_add_main
	fi
    done
    for l_script_add in /Library/ScriptingAdditions/*.osax
    do
	l_script_add_main=$(basename $l_script_add)
	if [ -n $l_script_add ]
	then
	   cp -r $l_script_add mac_autoruns/$l_script_add_main
	fi
    done
    for hsl_script_add in /System/Library/ScriptingAdditions/.*.osax 
    do
	hsl_script_add_main=$(basename $hls_script_add)
	if [ -n $hsl_script_add ]
	then
	    cp -r $hsl_script_add mac_autoruns/$hsl_script_add_main
	fi
    done
    for hl_script_add in /Library/ScriptingAdditions/.*.osax 
    do
	hl_script_add_main=$(basename $hl_script_add)
	if [ -n $hl_script_add ]
	then
	    cp -r $hl_script_add mac_autoruns/$hl_script_add_main
	fi
    done
    for sl_startup in /System/Library/StartupItems/*/*
    do
	sl_startup_main=$(basename $sl_startup)
	if [ -n $sl_startup ]          #; StartupItems
	then
	    cp  $sl_startup mac_autoruns/$sl_startup_main
	fi
    done
    for l_startup in /Library/StartupItems/*/* 
    do
	l_startup_main=$(basename $l_startup)
	if [ -n $l_startup ]
	then
	   cp $l_startup mac_autoruns/$l_startup_main
	fi
    done
    if [ -n  /private/etc/periodic.conf  ]          #; periodic, rc, emond
    then
	cp  /private/etc/periodic.conf  mac_autoruns/periodic.conf
    fi
    for periodic_file in /private/etc/periodic/*/*
    do
	periodic_file_main=$(basename $periodic_file)
	if [ -n $periodic_file ]
	then
	    cp $periodic_file mac_autoruns/$periodic_file_main
	fi
    done
    for p_local in /private/etc/*.local
    do
	p_local_main=$(basename p_local)
	if [ -n $p_local ]
	then
	    cp $p_local mac_autoruns/p_local_main
	fi
    done
    if [ -n /private/etc/rc.common ]
    then
	cp /private/etc/rc.common mac_autoruns/rc.common
    fi
    for p_emon in /private/etc/emond.d/*/*
    do
	p_emon_main=$(basename p_emon)
	if [ -n $p_emon ]
	then
	    cp $p_emon mac_autoruns/$p_emon_main
	fi
    done
    for u_loginitems in /Users/*/Library/Preferences/com.apple.loginitems.plist
    do
	if [ -n $u_loginitems ]      #; user login items
	then
	    plutil -p $u_loginitems mac_autoruns/com.apple.loginitems.plist
	fi
    done
    for p_loginitems in /private/var/*/Library/Preferences/com.apple.loginitems.plist 
    do
	if [ -n $p_loginitems ]
	then
	    plutil -p $p_loginitems mac_autoruns/com.apple.loginitems.plist
	fi
    done
    for ul_backgrounditems in /Users/*/Library/Application Support/com.apple.backgroundtaskmanagementagent/backgrounditems.btm
    do
	ul_backgrounditems_main=$(basename $ul_backgrounditems)
	if [ -n $ul_backgrounditems ]
	then
	    cp $ul_backgrounditems mac_autoruns/$ul_backgrounditems_main
	fi
    done
}


if [ $(uname) = 'Linux' ]
then
    if [ "$EUID" -eq 0 ]
    then
	whoami=$(whoami)
	hostname=$(hostname)
	linux_parser_file=$whoami-$hostname
	mkdir $linux_parser_file
	for user in $(awk -F: '{if ($6 ~ /^\/home/ ) print $1}' /etc/passwd)
	do
	    users+=($user)
	done
	touch result
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
    whoami=$(whoami)
    hostname=$(hostname)
    macos_parser_file=$whoami-$hostname
    mkdir $macos_parser_file
else
    echo "This is not MacOS or Linux sorry"
fi
