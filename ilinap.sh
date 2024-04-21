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
#		systemctl status --type=service > services/service_running
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
    if [ -f /etc/os-release ]
    then
		if ! [ -d $linux_parser_file/etc/ ]
		then
	    	mkdir $linux_parser_file/etc
		fi
		cp /etc/os-release $linux_parser_file/etc/os-release
    fi
}

hostname () {            # hostname output
    if [ -f /etc/hostname ]
    then
		if ! [ -d $linux_parser_file/etc/ ]
		then
	    	mkdir $linux_parser_file/etc
		fi
    	cp /etc/hostname $linux_parser_file/etc/hostname
    fi
}

location () {            # Localtime and timezone
    if [ -f /etc/timezone ]
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
    	if [ -f $user/.bashrc ]
		then
            cp $user/.bashrc $macos_parser_file/home/$basename_user/.bashrc
		fi
    	if [ -f $user/.bash_history ]
		then
            cp $user/.bash_history $macos_parser_file/home/$basename_user/.bash_history
    	fi
		if [ -d $user/.bash_sessions/ ]
		then
	    	mkdir $basename_user.bash_sessions
	    	cp $user/.bash_sessions/* $linux_parser_file/home/$basename_user/.bash_sessions/
    	fi
		if [ -f $user/.bash_profile ]
    	then
	    	cp $user/.bash_profile $macos_parser_file/home/$basename_user/.bash_profile
    	fi
		if [ -f $user/.profile ]
    	then
	    	cp $user/.profile $macos_parser_file/home/$basename_user/.profile
    	fi
		if [ -f $user/.bash_logout ]
    	then
	    	cp $user/.bash_logout $macos_parser_file/home/$basename_user/.bash_logout
    	fi
    done
    for puser in /private/var/*
    do
		basename_puser=$(basename $puser)
		if [ -d /private/var/$basename_puser ]
		then
	    	if ! [ -d $macos_parser_file/private/var/$basename_puser ]
	    	then
	       		mkdir -p $macos_parser_file/private/var/$basename_puser
	    	fi
		fi
		if [ -f $puser ]
		then
			cp -r $puser $macos_parser_file/private/var/$basename_puser
		fi
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
	    	cp /privat/etc/bashrc* $macos_parser_file/private/etc/
    	fi
    done
}

mac_autoruns () {
    for disabled in /private/var/db/com.apple.xpc.launchd/disabled*.plist
    do
	    disabled_main=$(basename $disabled)
	    if ! [ -d $macos_parser_file/private/var/db/com.apple.xpc.launchd ]
	    then
		    mkdir -p $macos_parser_file/private/var/db/com.apple.xpc.launchd/
	    fi
	    if [ -n $disabled ]
	    then
	        plutil -p $disabled > $macos_parser_file/private/var/db/com.apple.xpc.launchd/$disabled_main
	    fi
    done
    for at_tabs in /private/var/at/tabs/*
    do
	    at_tabs_main=$(basename $at_tabs)
	    if ! [ -d $macos_parser_file/private/var/at/tabs ]
	    then
	        mkdir -p $macos_parser_file/private/var/at/tabs
	    fi
	    if [ -f $at_tabs ]     #; crontab
	    then
	        cp $at_tabs > $macos_parser_file/private/var/at/tabs/$at_tabs_main
	    fi
    done
    for launchagent in /System/Library/LaunchAgents/*.plist
    do
	    launchagent_main=$(basename $launchagent)
	    if ! [ -d $macos_parser_file/System/Library/LaunchAgents/ ]
	    then
	        if [ -d /System/Library/LaunchAgents ]
	        then
		        mkdir -p $macos_parser_file/System/Library/LaunchAgents/
	        fi
	    fi
	    if [ -n $launchagent ]    #; LaunchAgents
	    then
	        plutil -p $launchagent_main > $macos_parser_file/System/Library/LaunchAgents/$launchagent_main
    	fi
    done
    for l_launchagent in /Library/LaunchAgents/*.plist
    do
	l_launchagent_main=$(basename $l_launchagent)
	if ! [ -d $macos_parser_file/Library/LaunchAgents/ ]
	then
	    mkdir -p $macos_parser_file/Library/LaunchAgents/
	fi
	if [ -n $l_launchagent ]
	then
	    plutil -p $l_launchagent > $macos_parser_file/Library/LaunchAgents/$l_launchagent_main
	fi
    done
    for m_user in /Users/*
    do
	m_user_main=$(basename $m_user)
		for u_launchagent in /Users/$m_user_main/Library/LaunchAgents/*.plist
		do
	    	u_launchagent_main=$(basename $u_launchagent)
	    	if ! [ -d $macos_parser_file/Users/$m_user_main/Library/LaunchAgents ]
	    	then
		    	mkdir -p $macos_parser_file/Users/$m_user_main/Library/LaunchAgents
	    	fi
	    	if [ -n $u_launchagent ]
	    	then
				plutil -p $u_launchagent > $macos_parser_file/Users/$m_user_main/Library/LaunchAgents/$u_launchagent_main
	    	fi
		done
    done
    for p_user in /private/var/*
    do
		p_user_basename=$(basename $p_user)
		if [ -d $p_user ]
		then
	    	for p_user_cont in /private/var/$p_user_basename/Library/LaunchAgents/*
	    	do
				p_user_cont_main=$(basename $p_user_cont)
			if ! [ -d $macos_parser_file/private/var/$p_user_basename/Library/LaunchAgents/ ]
			then
		    	mkdir -p $macos_parser_file/private/var/$p_user_basename/Library/LaunchAgents/
		    	cp -r $p_user_cont  $macos_parser_file/private/var/$p_user_basename/Library/LaunchAgents/$p_user_cont_main
			fi
	    done
	fi
	if [ -f $p_user ]
	then
	    mkdir -p $macos_parser_file/private/var
	    cp -r $p_user $macos_parser_file/private/var/$p_user_basename
	fi
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
		if ! [ -d $macos_parser_file/Library/LaunchAgents ]
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
	    	if ! [ -d /$macos_parser_file/Users/$ll_user_basename/Library/LaunchAgents ]
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
		p_var_main=$(basename $p_var)
		for pl_launchagent in /private/var/$p_var_main/Library/LaunchAgents/.*.plist
		do
			pl_launchagent_main=$(basename $pl_launchagent)
			if ! [ -d $macos_parser_file/private/var/$p_var_main/Library/LaunchAgents/ ]
			then
				mkdir -p $macos_parser_file/private/var/$p_var_main/Library/LaunchAgents
			fi
			if [ -n $pl_launchagent ]
			then
				plutil -p $pl_launchagent > $macos_parser_file/private/var/$p_var_main/Library/LaunchAgents/$pl_launchagent_main
			fi
		done
    done

    for ls_launchagent in /Library/Apple/System/Library/LaunchAgents/*.plist
    do
		ls_launchagent_main=$(basename $ls_launchagent)
		if ! [ -d $macos_parser_file/Library/Apple/System/Library/LaunchAgents ]
		then
			mkdir -p $macos_parser_file/Library/Apple/System/Library/LaunchAgents
		fi
		if [ -n $ls_launchagent ]
		then
			plutil -p $ls_launchagent > $macos_parser_file/Library/Apple/System/Library/LaunchAgents/$ls_launchagent_main
		fi
    done
    for las_launchagent in /Library/Apple/System/Library/LaunchAgents/.*.plist
    do
		las_launchagent_main=$(basename $las_launchagent)
		if ! [ -d $macos_parser_file/Library/Apple/System/Library/LaunchAgents ]
		then
			mkdir -p $macos_parser_file/Library/Apple/System/Library/LaunchAgents
		fi
		if [ -n $las_launchagent ]
		then
			plutil -p $las_launchagent > $macos_parser_file/Library/Apple/System/Library/LaunchAgents/$las_launchagent_main
		fi
    done
    for sl_launchdemon in /System/Library/LaunchDaemons/*.plist
    do
		sl_launchdemon_main=$(basename $sl_launchdemon)
		if ! [ -d $macos_parser_file/System/Library/LaunchDaemons ]
		then
			mkdir -p  $macos_parser_file/System/Library/LaunchDaemons
		fi
		if [ -n $sl_launchdemon ]     #; LaunchDaemons
		then
			plutil -p $sl_launchdemon > $macos_parser_file/System/Library/LaunchDaemons/$sl_launchdemon_main
		fi
    done
    for l_launchdemon in /Library/LaunchDaemons/*.plist
    do
		l_launchdemon_main=$(basename $l_launchdemon)
		if ! [ -d $macos_parser_file/Library/LaunchDaemons ]
		then
			mkdir -p $macos_parser_file/Library/LaunchDaemons
		fi
		if [ -n $l_launchdemon ]
		then
			plutil -p $l_launchdemon > $macos_parser_file/Library/LaunchDaemons/$l_launchdemon_main
		fi
    done
    for hsl_launchdemon in /System/Library/LaunchDaemons/.*.plist
    do
		hsl_launchdemon_main=$(basename $hsl_launchdemon)
		if ! [ -d $macos_parser_file/System/Library/LaunchDaemons ]
		then                                                      
			mkdir -p $macos_parser_file/System/Library/LaunchDaemons
		fi
		if [ -n $hsl_launchdemon ]
		then
			plutil -p $hsl_launchdemon > $macos_parser_file/Sytem/Library/LaunchDaemons/$hsl_launchdemon_main
		fi
    done
    for hl_launchdemon in /Library/LaunchDaemons/.*.plist
    do
		hl_launchdemon_main=$(basename $hl_launchdemon)
		if ! [ -d $macos_parser_file/Library/LaunchDaemons ]
		then
			mkdir -p $macos_parser_file/Library/LaunchDaemons
		fi
		if [ -n $hl_launchdemon ]
		then
			plutil -p $hl_launchdemon > $macos_parser_file/Library/LaunchDaemons/$hl_launchdemon_main
		fi
    done
    for las_launchdemon in /Library/Apple/System/Library/LaunchDaemons/*.plist
    do
		las_launchdemon_main=$(basename $las_launchdemon)
		if ! [ -d $macos_parser_file/Library/Apple/System/Library/LaunchDaemons ]
		then
			mkdir -p $macos_parser_file/Library/Apple/System/Library/LaunchDaemons
		fi
		if [ -n $las_launchdemon ]
		then
			plutil -p $las_launchdemon > $macos_parser_file/Library/Apple/System/Library/LaunchDaemons/$las_launchdemon_main
		fi
    done
    for hlas_launchdemon in /Library/Apple/System/Library/LaunchDaemons/.*.plist
    do
		hlas_launchdemon_main=$(basename $hlas_launchdemon)
		if ! [ -d $macos_parser_file/Library/Apple/System/Library/LaunchDaemons ]
		then
			mkdir -p $macos_parser_file/Library/Apple/System/Library/LaunchDaemons
		fi
		if [ -n /Library/Apple/System/Library/LaunchDaemons/.*.plist ]
		then
			plutil -p $hlas_launchdemon > $macos_parser_file/Library/Apple/System/Library/LaunchDaemons/$hlas_launchdemon_main
		fi
    done
    for sl_script_add in /System/Library/ScriptingAdditions/*.osax
    do
		sl_script_add_main=$(basename $sl_script_add)
		if ! [ -d $macos_parser_file/System/Library/ScriptingAdditions ]
		then
			mkdir -p $macos_parser_file/System/Library/ScriptingAddition
		fi
		if [ -n $sl_script_add ]        #; ScriptingAdditions
		then
			cp -r $sl_script_add $macos_parser_file/System/Library/ScriptingAdditions/$sl_script_add_main
		fi
    done
    for l_script_add in /Library/ScriptingAdditions/*.osax
    do
		l_script_add_main=$(basename $l_script_add)
		if ! [ -d $macos_parser_file/Library/ScriptingAdditions ]
		then
			mkdir -p $macos_parser_file/Library/SCriptingAdditions
		fi
		if [ -n $l_script_add ]
		then
			cp -r $l_script_add $macos_parser_file/Library/ScriptingAdditions/$l_script_add_main
		fi
    done
    for hsl_script_add in /System/Library/ScriptingAdditions/.*.osax
    do
		hsl_script_add_main=$(basename $hls_script_add)
		if ! [ -d $macos_parser_file/System/Library/ScriptingAdditions ]
		then
			mkdir -p $macos_parser_file/System/Library/ScriptingAdditions
		fi
		if [ -n $hsl_script_add ]
		then
			cp -r $hsl_script_add $macos_parser_file/System/Library/ScriptingAdditions/$hsl_script_add_main
		fi
    done
    for hl_script_add in /Library/ScriptingAdditions/.*.osax
    do
		hl_script_add_main=$(basename $hl_script_add)
		if ! [ -d $macos_parser_file/Library/ScriptingAdditions ]
		then
			mkdir -p $macos_parser_file/Library/ScriptingAdditions
		fi
		if [ -n $hl_script_add ]
		then
			cp -r $hl_script_add $macos_parser_file/Library/ScriptingAdditions/$hl_script_add_main
		fi
    done
    for sl_startup in /System/Library/StartupItems/*
    do
		sl_startup_main=$(basename $sl_startup)
		if [ -d /System/Library/StartupItems/$sl_startup_main ]
		then
			for usl_startup in /System/Library/StartupItems/$sl_startup_main/*
			do
				usl_startup_main=$(basename $usl_startup)
				if ! [ -d $macos_parser_file/System/Library/StartupItems/$sl_startup_main ]
				then
					mkdir -p $macos_parser_file/System/Library/StartupItems/$sl_startup_main
				fi
				if [ -f $sl_startup ]          #; StartupItems
				then
					cp -r  $usl_startup $macos_parser_file/System/Library/StartupItems/$sl_startup_main/$usl_startup_main
				fi
			done
		fi
		if [ -f $sl_startup ]
		then
			cp -r $sl_startup $macos_parser_file/System/Library/StartupItems/$sl_startup_main
		fi
    done
    for l_startup in /Library/StartupItems/*
    do
		l_startup_main=$(basename $l_startup)
		if [ -f $l_startup ]
		then
			if ! [ -d $macos_parser_file/Library/StartupItems ]
			then
				mkdir -p $macos_parser_file/Library/StartupItems
			fi
			cp -r $l_startup $macos_parser_file/Library/StartupItems/$l_startup_main
		fi
		if [ -d $l_startup ]
		then
			for ul_startup in /Library/StartupItems/$l_startup_main
			do
				ul_startup_main=$(basename $ul_startup)
				if [ -f $ul_startup ]
				then
					cp -r $ul_startup $macos_parser_file/Library/StartupItems/$l_startup_main/$ul_startup_main
				fi
			done
		fi
    done
    if [ -n  /private/etc/periodic.conf  ]          #; periodic, rc, emond
    then
		if ! [ -d $macos_parser_file/private/etc ]
		then
			mkdir -p $macos_parser_file/private/etc
		fi
		cp  /private/etc/periodic.conf $macos_parser_file/private/etc/periodic.conf
	fi
    for p_periodic_file in /private/etc/periodic/*
    do
		p_periodic_file_main=$(basename $p_periodic_file)
		if [ -f $p_periodic_file ]
		then
			if ! [ -d $macos_parser_file/private/etc/periodic ]
			then
				mkdir -p $macos_parser_file/private/etc/periodic
			fi
			cp -r $p_periodic_file $macos_parser_file/private/etc/periodic/$p_periodic_file_main
		fi
		if [ -d $p_periodic_file ]
		then
			for periodic_file in /private/etc/periodic/$p_periodic_file_main/*
			do
				periodic_file_main=$(basename $periodic_file)
				if ! [ -d $macos_parser_file/private/etc/periodic/$p_periodic_file_main ]
				then
					mkdir -p $macos_parser_file/private/etc/periodic/$p_periodic_file_main
				fi
				if [ -n $periodic_file ]
				then
					cp -r $periodic_file $macos_parser_file/private/etc/periodic/$p_peroidic_file_main/$periodic_file_main
				fi
			done
		fi
    done
    for p_local in /private/etc/*.local
    do
		p_local_main=$(basename p_local)
		if ! [ -d $macos_parser_file/private/etc/ ]
		then
			mkdir -p $macos_parser_file/private/etc
		fi
		if [ -n $p_local ]
		then
			cp $p_local $macos_parser_file/private/etc/$p_local_main
		fi
    done
    if [ -n /private/etc/rc.common ]
    then
		if ! [ -d $macos_parser_file/private/etc ]
		then
			mkdir $macos_parser_file/private/etc
		fi
		cp /private/etc/rc.common $macos_parser_file/private/etc/rc.common
    fi
    for pp_emon in /private/etc/emond.d/*
    do
		pp_emon_main=$(basename $pp_emon)
		if [ -f $pp_emon ]
		then
			if ! [ -d $macos_parser_file/private/etc/emond.d ]
			then
				mkdir -p $macos_parser_file/private/etc/emond.d
			fi
			cp -r $pp_emon $macos_parser_file/private/etc/emond.d/$pp_emon_main
		fi
		if [ -d $pp_emon ]
		then
			for p_emon in /private/etc/emond.d/$pp_emon_main/*
			do
				p_emon_main=$(basename $p_emon)
				if ! [ -d $macos_parser_file/private/etc/emond.d/$pp_emon_main ]
				then
					mkdir -p $macos_parser_file/private/etc/emond.d/$pp_emon_main
				fi
				if [ -n $p_emon ]
				then
					cp -r $p_emon $macos_parser_file/private/etc/emond.d/$pp_emon_main/$p_emon_main
				fi
			done
		fi
    done
    for uu_loginitems in /Users/*
    do
		uu_login_main=$(basename $uu_login_main)
		for u_loginitems in /Users/$uu_login_main/Library/Preferences/com.apple.loginitems.plist
		do
			if ! [ -d /Users/$uu_login_main/Library/Preferences ]
			then
				mkdir -p /Users/$uu_login_main/Library/Preferences
			fi
			if [ -n $u_loginitems ]      #; user login items
			then
				plutil -p $u_loginitems > $macos_parser_file/Users/$uu_login_main/Library/Preferences/com.apple.loginitems.plist
			fi
		done
    done
    for pp_loginitems in /private/var/*
    do
		pp_loginitems_main=$(basename $pp_loginitems)
		for p_loginitems in /private/var/$pp_loginitems_main/Library/Preferences/com.apple.loginitems.plist
		do
			if ! [ -d /private/var/$pp_loginitems_main/Library/Preferences ]
			then
				mkdir -p /private/var/$pp_loginitems_main/Library/Preferences
			fi
			if [ -n $p_loginitems ]
			then
				plutil -p $p_loginitems > $macos_parser_file/private/var/$pp_loginitems_main/Library/Preferences/com.apple.loginitems.plist
			fi
		done
    done
    for ful_bkgrounditems in /Users/*
    do
		ful_bkgrounditems_main=$(basename $ful_bkgrounditems)
		for ul_bkgrounditems in /Users/$ful_bkgrounditems_main/Library/Application\ Support/com.apple.backgroundtaskmanagementagent/backgrounditems.btm
		do
			ul_bkgrounditems_main=$(basename $ul_bkgrounditems)
			if ! [ -d $macos_parser_file/Users/$ful_bkgrounditems_main/Library/Application\ Support/com.apple.backgroundtaskmanagementagent ]
			then
				mkdir -p $macos_parser_file/Users/$ful_bkgrounditems_main/Library/Application\ Support/com.apple.backgroundtaskmanagementagent
			fi
			if [ -n $ul_bkgrounditems ]
			then
				cp $ul_bkgrounditems $macos_parser_file/Users/$ful_bkgrounditems_main/Library/Application\ Support/com.apple/backgrountaskmanagementagent/$ul_bkgrounditems_main
			fi
		done
    done
}

mac_activer_directory () {
    for activedir in /Library/Preferences/OpenDirectory/Configurations/Active\ Directory/*
    do
		activedir_main=$(basename $activedir)
		if ! [ -d $macos_parser_file/Library/Preferences/OpenDirectory/Configurations/Active\ Directory ]
		then
			mkdir -p $macos_parser_file/Library/Preferences/OpenDirectory/Configurations/Active\ Directory
		fi
		if [ -n $activedir ]
		then
			cp -r $activedir $macos_parser_file/Library/Preferences/OpenDirectory/Configurations/Active\ Directory/
		fi
    done
}

mac_applist () {
    for app_user in /Users/*
    do
		app_user_main=$(basename $app_user)
		for app_user_s in /Users/$app_user_main/Library/Application\ Support/com.apple.stoplight/appList.dat
		do
			if ! [ -d $macos_parser_file/Users/$app_user_main/Library/Application\ Support/com.apple.stoplight ]
			then
				mkdir -p $macos_parser_file/Users/$app_user_main/Library/Application\ Support/com.apple.stoplight
			fi
			cp -r $app_user_s $macos_parser_file/Users/$app_user_main/Library/Application\ Support/com.apple.stoplight/
		done
    done
}

mac_ard () {
    for ard in /private/var/db/RemoteManagement/caches/*
    do
		if ! [ -d $macos_parser_file/private/var/db/RemoteManagement/caches ]
		then
			mkdir -p $macos_parser_file/private/var/db/RemoteManagement/caches
		fi
		ard_main=$(basename $ard)
		cp -r $ard $macos_parser_file/private/var/db/RemoteManagement/caches/$ard_main
	done
	for ard_cache in /private/var/db/RemoteManagement/ClientCaches/*
	do
		ard_cache_main=$(basename $ard_cache)
		if [ -f $ard_cache ]
		then
			if ! [ -d $macos_parser_file/private/var/db/RemoteManagement/ClientCaches ]
			then
				mkdir -p $macos_parser_file/private/var/db/RemoteManagement/ClientCaches
			fi
			cp -r $ard_cache $macos_parser_file/private/var/db/RemoteManagement/ClientCaches/$ard_cache_main
		fi
		if [ -d $ard_cache ]
		then
			for ard_sec_cache in /private/var/db/RemoteManagement/ClientCaches/$ard_cache_main/*
			do
				if ! [ -d $macos_parser_file/private/var/db/RemoteManagement/ClientCaches/$ard_cache_main ]
				then
					mkdir -p $macos_parser_file/private/var/db/RemoteManagement/ClientCaches/$ard_cache_main
				fi
				ard_sec_cache_main=$(basename $ard_sec_cache)
				cp -r $ard_sec_cache $macos_parser_file/private/var/db/RemoteManagement/ClientCaches/$ard_cache_main/$ard_sec_cache_main
			done
		fi
    done
    for rmdb in /private/var/db/RemoteManagement/RMDB/*
    do
		rmdb_main=$(basename $rmdb)
		if ! [ -d $macos_parser_file/var/db/RemoteManagement/RMDB ]
		then
			mkdir -p $macos_parser_file/var/db/RemoteManagement/RMDB
		fi
		cp -r $rmdb $macos_parser_file/private/var/db/RemoteManagement/RMDB/$rmdb_main
    done
}

mac_asl () {
    for asl in /private/var/log/asl/*.asl
    do
		asl_main=$(basename $asl)
		if ! [ -d $macos_parser_file/private/var/log/asl ]
		then
			mkdir -p $macos_parser_file/private/var/log/asl
		fi
		cp -r $asl $macos_parser_file/private/var/log/asl/$asl_main
    done
}

mac_bluetooth () {
    if ! [ -d $macos_parser_file/Library/Preference ]
    then
		mkdir -p $macos_parser_file/Library/Preference
    fi
    plutil -p /Library/Preferences/com.apple.Bluetooth.plist > $macos_parser_file/Library/Preferences/com.apple.Bluetooth.plist
}

mac_cfurl_cache () {
    for cfuser in /Users/*
    do
		cfuser_main=$(basename $cfuser)
		for cflib in /Users/$cfuser_main/Library/Caches/*
		do
			cflib_main=$(basename $cflib)
			if [ -f $cflib ]
			then
				if ! [ -d $macos_parser_file/Users/$cfuser_main/Library/Caches ]
				then
					mkdir -p $macos_parser_file/Users/$cfuser_main/Library/Caches
				fi
				cp -r $cflib $macos_parser_file/Users/$cfuser_main/Library/Caches/$cflib_main
			fi
			if [ -d /Users/$cfuser_main/Library/Caches/$cflib_main/fsCachedData ]
			then
				for fscache in /Users/$cfuser_main/Library/Caches/$cflib_main/fsCachedData/*
				do
					fscache_main=$(basename $fscache)
					if ! [ -d $macos_parser_file/Users/$cfuser_main/Library/Caches/$cflib_main/fsCachedData ]
					then
						mkdir -p $macos_parser_file/Users/$cfuser_main/Library/Caches/$cflib_main/fsCachedData
					fi
					cp -r $fscache $macos_parser_file/Users/$cfuser_main/Library/Caches/$cflib_main/fsCachedData/$fscache_main
				done
			fi
			for cfcache in /Users/$cfuser_main/Library/Caches/$cflib_main/Cache.db*
			do
				cfcache_main=$(basename $cfcache)
				if ! [ -d  $macos_parser_file/Users/$cfuser_main/Library/Caches/$cflib_main ]
				then
					mkdir -p  $macos_parser_file/Users/$cfuser_main/Library/Caches/$cflib_main
				fi
				cp -r $cfcache $macos_parser_file/Users/$cfuser_main/Library/Caches/$cflib_main/$cfcache_main
			done
		done
    done
}

mac_cmdhistory () {
    for user_cmd in /Users/*
    do
		user_cmd_main=$(basename $user_cmd)
		for cmd_history in /Users/$user_cmd_main/.*_history
		do
			cmd_history_main=$(basename $cmd_history)
			if ! [ -d $macos_parser_file/Users/$user_cmd_main ]
			then
				mkdir -p $macos_parser_file/Users/$user_cmd_main
			fi
			cp -r $cmd_history $macos_parser_file/Users/$user_cmd_main/$cmd_history_main
		done
    done
}

mac_coreanalytics () {
    if ! [ -d $macos_parser_file/Library/Logs/DiagnosticReports ]
    then
		mkdir -p $macos_parser_file/Library/Logs/DiagnosticReports
    fi
    cp -r /Library/Logs/DiagnosticReports/Analytics*.core_analytics $macos_parser_file/Library/Logs/DiagnosticReports/
    if ! [ -d $macos_parser_file/Library/Logs/DiagnosticReports/Retired ]
    then
		mkdir -p $macos_parser_file/Library/Logs/DiagnosticReports/Retired
    fi
    cp -r /Library/Logs/DiagnosticReports/Retired/Analytics*.core_analytics $macos_parser_file/Library/Logs/DiagnosticReports/Retired/
    if ! [ -d $macos_parser_file/private/var/db/analyticsd/aggregates ]
    then
		mkdir -p $macos_parser_file/private/var/db/analyticsd/aggregates
    fi
    cp -r /private/var/db/analyticsd/aggregates/* $macos_parser_file/private/var/db/analyticsd/aggregates/
    for agg in /private/var/db/analyticsd/aggregates/*
    do
		agg_main=$(basename $agg)
		if [ -f $agg ]
		then
			if ! [ -d $macos_parser_file/private/var/db/analyticsd/aggregates ]
			then
				mkdir -p $macos_parser_file/private/var/db/analyticsd/aggregates
			fi
			cp -r $agg $macos_parser_file/private/var/db/analyticsd/aggregates
		fi
		if [ -d $agg ]
		then
			for agg_file in /private/var/db/analyticsd/aggregates/$agg_main/*
			do
				agg_file_main=$(basename $agg_file)
				if [ -f $agg_file ]
				then
					if ! [ -d $macos_parser_file/private/var/db/analyticsd/aggregates/$agg_main ]
					then
						mkdir -p $macos_parser_file/private/var/db/analyticsd/aggregates/$agg_main
					fi
					cp -r $agg_file $macos_parser_file/private/var/db/analyticsd/aggregates/$agg_main/$agg_file_main
				fi
				if [ -d $agg_file ]
				then
					for agg_file_3 in /private/var/db/analyticsd/aggregates/$agg_main/$agg_file_main/*
					do
						agg_file_3_main=$(basename $agg_file_3)
						if ! [ -d $macos_parser_file/private/var/db/analyticsd/aggregates/$agg_main/$agg_file_main ]
						then
							mkdir -p $macos_parser_file/private/var/db/analyticsd/aggregates/$agg_main/$agg_file_main
						fi
						cp -r $agg_file $macos_parser_file/private/var/db/analyticsd/aggregates/$agg_main/$agg_file_main/$agg_file_3_main
					done
				fi
			done
		fi
    done
}

mac_dock_items () {
    for dock_user in /Users/*
    do
		dock_user_main=$(basename $dock_user)
		if ! [ -d $macos_parser_file/Users/$dock_user_main/Library/Preferences ]
		then
			mkdir -p $macos_parser_file/Users/$dock_user_main/Library/Preferences
		fi
		plutil -p /Users/$dock_user_main/Library/Preferences/com.apple.dock.plist > $macos_parser_file/Users/$dock_user_main/Library/Preferences/com.apple.dock.plist
    done
}

mac_documentrevisions () {
    if ! [ -d $macos_parser_file/.DocumentRevisions-V100/db-V1 ]
    then
		mkdir -p $macos_parser_file/.DocumentRevisions-V100/db-V1
    fi
    cp -r /.DocumentRevisions-V100/db-V1/db.sqlite* $macos_parser_file/.DocumentRevisions-V100/db-V1/
    if ! [ -d $macos_parser_file/System/Volumes/Data/.DocumentRevisions-V100/db-V1 ]
    then
		mkdir -p $macos_parser_file/System/Volumes/Data/.DocumentRevisions-V100/db-V1
    fi
    cp -r /System/Volumes/Data/.DocumentRevisions-V100/db-V1/db.sqlite* $macos_parser_file/System/Volumes/Data/.DocumentRevisions-V100/db-V1
}

mac_dynamictext () {
    for dy_user in /Users/*
    do
		dy_user_main=$(basename $dy_user)
		for dytext in /Users/$dy_user_main/Library/Spelling/*
		do
			dytext_main=$(basename $dytext)
			if ! [ -d $macos_parser_file/$dy_user_main/Library/Spelling ]
			then
			mkdir -p $macos_parser_file/$dy_user_main/Library/Spelling
			fi
			cp -r $dytext $macos_parser_file/$dy_user_main/Library/Spelling/$dytext_main
		done
    done
}

mac_filesharing () {
    if ! [ -d $macos_parser_file/private/var/db/dslocal/nodes/Default/sharepoints ]
    then
		mkdir -p $macos_parser_file/private/var/db/dslocal/nodes/Default/sharepoints
    fi
    cp -r /private/var/db/dslocal/nodes/Default/sharepoints/* $macos_parser_file/private/var/db/dslocal/nodes/Default/sharepoints/
}

mac_firefox () {
    for fire_user in /Users/*
    do
		fire_user_main=$(basename $fire_user)
		for firefox_file in /Users/$fire_user_main/Library/Application\ Support/Firefox/Profiles/*
		do
			firefox_file_main=$(basename $firefox_file)
			if [ -f $firefox_file ]
			then
				if ! [ -d $macos_parser_file/Users/$fire_user_main/Library/Application\ Support/Firefox/Profiles ]
				then
					mkdir -p $macos_parser_file/Users/$fire_user_main/Library/Application\ Support/Firefox/Profiles
				fi
				cp -r $firefox_file $macos_parser_file/Users/$fire_user_main/Library/Application\ Support/Firefox/Profiles/$firefox_file_main
			fi
			if [ -d $firefox_file ]
			then
				for ffirefox_file in /Users/$fire_user_main/Library/Application\ Support/Firefox/Profiles/$firefox_file_main/*
				do
					ffirefox_file_main=$(basename $ffirefox_file)
					if ! [ -d $macos_parser_file/Users/$fire_user_main/Library/Application\ Support/Firefox/Profiles/$firefox_file_main ]
					then
						mkdir -p $macos_parser_file/Users/$fire_user_main/Library/Application\ Support/Firefox/Profiles/$firefox_file_main
					fi
					cp -r $ffirefox_file $macos_parser_file/Users/$fire_user_main/Library/Application\ Support/Firefox/Profiles/$firefox_file_main/$ffirefox_file_main
				done
			fi
		done
    done
}

mac_fsevents () {
	for fsevent in /.fseventsd/*
	do
		fseventd_main=$(basename $fsevent)
		if ! [ -d $macos_parser_file/.fseventsd ]
		then
			mkdir -p $macos_parser_file/.fseventsd
		fi
		cp -r $fsevent $macos_parser_file/.fseventsd/$fseventd_main
	done
	for s_fsevent in /System/Volumes/Data/.fseventsd/*
	do
		s_fsevent_main=$(basename $s_fsevent)
		if ! [ -d $macos_parser_file/System/Volumes/Data/.fseventsd/ ]
		then
			mkdir -p $macos_parser_file/System/Volumes/Data/.fseventsd/
		fi
		cp -r $s_fsevent $macos_parser_file/System/Volumes/Data/.fseventsd/$s_fsevent_main
	done
}

mac_idevice () {
	for idev_user in /Users/*
	do
		idev_user_main=$(basename $idev_user)
		for idev in /Users/$idev_user_main/Library/Application\ Support/MobileSync/Backup/*
		do
			idev_main=$(basename $idev)
			if [ -f $idev ]
			then
				if ! [ -d $macos_parser_file/Users/$idev_user_main/Library/Application\ Support/MobileSync/Backup/ ]
				then
					mkdir -p $macos_parser_file/Users/$idev_user_main/Library/Application\ Support/MobileSync/Backup/
				fi
				cp -r $idev $macos_parser_file/Users/$idev_user_main/Library/Application\ Support/MobileSync/Backup/$idev_main
			if [ -d $idev ]
			then
				for sub_idev in $idev/*
				do
					sub_idev_main=$(basename $sub_idev)
					if ! [ -d $macos_parser_file$idev ]
					then
						mkdir -p $macos_parser_file/Users/$idev_user_main/Library/Application\ Support/MobileSync/Backup/$idev_main
					fi
					cp -r $sub_idev $macos_parser_file/Users/$idev_user_main/Library/Application\ Support/MobileSync/Backup/$idev_main/$sub_idev_main
				done
			fi
		done
		for dev_info in /Users/$idev_user_main/Library/Preferences/com.apple.iPod.plist
		do
			if ! [ -d $macos_parser_file/Users/$idev_user_main/Library/Preferences ]
			then
				mkdir -p $macos_parser_file/Users/$idev_user_main/Library/Preferences
			fi
			plutil -p $dev_info ? $macos_parser_file/Users/$idev_user_main/Library/Preferences/com.apple.iPod.plist
		done
	done
}

mac_imessage () {
	for mess_user in /Users/*
	do
		mess_user_main=$(basename $mess_user)
		for message in /Users/$mess_user_main/Library/Messages/chat.db*
		do
			message_main=$(basename $message)
			if ! [ -d $macos_parser_file/Users/$mess_user_main/Library/Messages ]
			then
				mkdir -p $macos_parser_file/Users/$mess_user_main/Library/Messages
			fi
			cp -r $message $macos_parser_file/Users/$mess_user_main/Library/Messages/$message_main
		done
		for imess in /Users/$mess_user_main/Library/Messages/Attachments/*
		do
			imess_main=$(basename $imess)
			if ! [ -d $macos_parser_file/Users/$mess_user_main/Library/Messages/Attachments ]
			then
				mkdir -p $macos_parser_file/Users/$mess_user_main/Library/Messages/Attachments
			fi
			cp -r $imess $macos_parser_file/Users/$mess_user_main/Library/Messages/Attachments/$imess_main
		done
	done
}

mac_inetaccounts () {
	for inet_user in /Users/*
	do
		inet_user_main=$(basename $inet_user)
		for inet in /Users/$inet_user_main/Library/Preferences/MobileMeAccounts.plist
		do
			if ! [ -d $macos_parser_file/Users/$inet_user_main/Library/Preferences ]
			then
				mkdir -p $macos_parser_file/Users/$inet_user_main/Library/Preferences
			fi
			cp -r $inet $macos_parser_file/Users/$inet_user_main/Library/Preferences/MobileMeAccounts.plist
		done
		for inet_f in /Users/$inet_user_main/Library/Accounts/Accounts*.*
		do
			inet_f_main=$(basename $inet_f)
			if ! [ -d $macos_parser_file/Users/$inet_user_main/Library/Accounts ]
			then
				mkdir -p $macos_parser_file/Users/$inet_user_main/Library/Accounts
			fi
			cp -r $inet_f $macos_parser_file/Users/$inet_user_main/Library/Accounts/$inet_f_main
		done
		for inet_ff in /Users/$inet_user_main/Library/Accounts/VerifiedBackup/Accounts*.*
		do
			inet_ff_main=$(basename $inet_ff)
			if ! [ -d $macos_parser_file/Users/$inet_user_main/Library/Accounts/VerifiedBackup ]
			then
				mkdir -p $macos_parser_file/Users/$inet_user_main/Library/Accounts/VerifiedBackup
			fi
			cp -r $inet_ff $macos_parser_file/Users/$inet_user_main/Library/Accounts/VerifiedBackup$inet_ff_main
		done
	done
}

mac_interactions () {
	for interact in /private/var/db/CoreDuet/People/interactionC.*
	do
		interact_main=$(basename $interact)
		if ! [ -d $macos_parser_file/private/var/db/CoreDuet/People ]
		then
			mkdir -p $macos_parser_file/private/var/db/CoreDuet/People
		fi
		cp -r $interact $macos_parser_file/private/var/db/CoreDuet/People/$interact_main
	done
}

mac_installhistory () {
	if ! [ -d $macos_parser_file/Library/Receipts ]
	then
		mkdir -p $macos_parser_file/Library/Receipts
	fi
	plutil -p /Library/Receipts/InstallHistory.plist > $macos_parser_file/Library/Receipts/InstallHistory.plist
}

mac_knowledgec_db () {
	for know_db in /private/var/db/CoreDuet/Knowledge/*
	do
		know_db_main=$(basename $know_db)
		if ! [ -d $macos_parser_file/private/var/db/CoreDuet/Knowledge ]
		then
			mkdir -p $macos_parser_file/private/var/db/CoreDuet/Knowledge
		fi
		cp -r $know_db $macos_parser_file/private/var/db/CoreDuet/Knowledge/$know_db_main
	done
	for knowdb_user in /Users/*
	do
		knowdb_user_main=$(basename $knowdb_user)
		for know_db_file in /Users/$knowdb_user_main/Library/Application\ Support/Knowledge/*
		do
			know_db_file_main=$(basename $know_db_file)
			if ! [ -d $macos_parser_file/Users/$knowdb_user_main/Library/Application\ Support/Knowledge ]
			then
				mkdir -p $macos_parser_file/Users/$knowdb_user_main/Library/Application Support/Knowledge
			fi
			cp -r $know_db_file $macos_parser_file/Users/$knowdb_user_main/Library/Application Support/Knowledge/$know_db_file_main
		done
	done
}

mac_keychain () {
	if ! [ -d $macos_parser_file/Library/Keychains ]
	then
		mkdir -p $macos_parser_file/Library/Keychains
	fi
	cp /Library/Keychains/System.keychain $macos_parser_file/Library/Keychains/System.keychain
	if ! [ -d $macos_parser_file/private/var/db ]
	then
		mkdir -p $macos_parser_file/private/var/db/SystemKey
	fi
	cp /private/var/db/SystemKey $macos_parser_file/private/var/db/SystemKey
	for keychain_user in /Users/*
	do
		keychain_user_main=$(basename $keychain_user)
		for keychain in /Users/$keychain_user_main/Library/Keychains/login.keychain*
		do
			keychain_main=$(basename $keychain)
			if ! [ -d $macos_parser_file/Library/Keychains ]
			then
				mkdir -p $macos_parser_file/Library/Keychains
			fi
			cp -r $keychain $macos_parser_file/Library/Keychains/$keychain_main
		done
		for keychain_f in /Users/$keychain_user_main/Library/Keychains/login.keychain-db*
		do
			keychain_f_main=$(basename $keychain_f)
			if ! [ -d $macos_parser_file/Users/$keychain_user_main/Library/Keychains ]
			then
				mkdir -p $macos_parser_file/Users/$keychain_user_main/Library/Keychains
			fi
			cp -r $keychain_f $macos_parser_file/Users/$keychain_user_main/Library/Keychains/$keychain_f_main
		done
		for keychain_nest in /Users/$keychain_user_main/Library/Keychains/*
		do
			if [ -d $keychain_nest ]
			then
				keychain_nest_main=$(basename $keychain_nest)
				for keychain_nest_2 in /Users/$keychain_user_main/Library/Keychains/$keychain_nest_main/keychain-2.db*
				do
					keychain_nest_2_main=$(basename $keychain_nest_2)
					if ! [ -d $macos_parser_file/Users/$keychain_user_main/Library/Keychains/$keychain_nest_main ]
					then
						mkdir -p $macos_parser_file/Users/$keychain_user_main/Library/Keychains/$keychain_nest_main
					fi
					cp -r $keychain_nest_2 $macos_parser_file/Users/$keychain_user_main/Library/Keychains/$keychain_nest_main/$keychain_nest_2_main
				done
				for keychain_nest_3 in /Users/$keychain_user_main/Library/Keychains/$keychain_nest_main/user.kb
				do
					keychain_nest_3_main=$(basename $keychain_nest_3)
					if ! [ -d $macos_parser_file/Users/$keychain_user_main/Library/Keychains/$keychain_nest_main ]
					then
						mkdir -p $macos_parser_file/Users/$keychain_user_main/Library/Keychains/$keychain_nest_main 
					fi
					cp -r $keychain_nest_3 $macos_parser_file/Users/$keychain_user_main/Library/Keychains/$keychain_nest_main/$keychain_nest_3_main
				done
			fi
		done
	done
}

mac_mru () {
	for mru_user in /Users/*
	do
		mru_user_main=$(basename $mru_user)
		for mru in /Users/$mru_user_main/Library/Preferences/com.apple.finder.plist
		do
			if ! [ -d $macos_parser_file/Users/$mru_user_main/Library/Preferences ]
			then
				mkdir -p $macos_parser_file/Users/$mru_user_main/Library/Preferences
			fi
			plutil -p $mru > $macos_parser_file/Users/$mru_user_main/Library/Preferences/com.apple.finder.plist
		done
		for mru_2 in /Users/$mru_user_main/Library/Preferences/.GlobalPreferences.plist
		do
			if ! [ -d $macos_parser_file/Users/$mru_user_main/Library/Preferences ]
			then
				mkdir -p $macos_parser_file/Users/$mru_user_main/Library/Preferences
			fi
			plutil -p $mru_2 > $macos_parser_file/Users/$mru_user_main/Library/Preferences/com.apple.finder.plist
		done
		for mru_3 in /Users/$mru_user_main/.ssh/known_hosts
		do
			if ! [ -d $macos_parser_file/Users/$mru_user_main/.ssh ]
			then
				mkdir -p $macos_parser_file/Users/$mru_user_main/.ssh
			fi
			cp -r $mru_3 $macos_parser_file/Users/$mru_user_main/.ssh/known_hosts
		done
		for mru_4 in /Users/$mru_user_main/Library/Preferences/*.LSSharedFileList.plist
		do
			mru_4_main=$(basename $mru_4)
			if ! [ -d $macos_parser_file/Users/$mru_user_main/Library/Preferences ]
			then
				mkdir -p $macos_parser_file/Users/$mru_user_main/Library/Preferences 
			fi
			plutil -p $mru_4 > $macos_parser_file/Users/$mru_user_main/Library/Preferences/$mru_4_main
		done
		for mru_5 in /Users/$mru_user_main/Library/Preferences/com.apple.recentitems.plist
		do
			if ! [ -d $macos_parser_file/Users/$mru_user_main/Library/Preferences ]
			then
				mkdir -p $macos_parser_file/Users/$mru_user_main/Library/Preferences
			fi
			plutil -p $mru_5 > $macos_parser_file/Users/$mru_user_main/Library/Preferences/com.apple.recentitems.plist
		done
		for mru_6 in /Users/$mru_user_main/Library/Preferences/com.apple.sidebarlists.plist
		do
			if ! [ -d $macos_parser_file/Users/$mru_user_main/Library/Preferences ]
			then
				mkdir -p $macos_parser_file/Users/$mru_user_main/Library/Preferences
			fi
			plutil -p $mru_6 > $macos_parser_file/Users/$mru_user_main/Library/Preferences/com.apple.sidebarlists.plist
		done
		for mru_7 in /Users/$mru_user_main/Library/Application\ Support/com.apple.sharedfilelist/*.sfl*
		do
			mru_7_main=$(basename $mru_7)
			if ! [ -d $macos_parser_file/Users/$mru_user_main/Library/Application\ Support/com.apple.sharedfilelist ]
			then
				mkdir -p $macos_parser_file/Users/$mru_user_main/Library/Application\ Support/com.apple.sharedfilelist
			fi
			cp -r $mru_7 $macos_parser_file/Users/$mru_user_main/Library/Application\ Support/com.apple.sharedfilelist/$mru_7_main
		done
		for mru_8 in /Users/$mru_user_main/Library/Application\ Support/com.apple.sharedfilelist/*
		do
			mru_8_main=$(basename $mru_8)
			if [ -d $mru_8 ]
			then
				for mru_8_nest in /Users/$mru_user_main//Library/Application\ Support/com.apple.sharedfilelist/$mru_8_main/*.sfl*
				do
					mru_8_nest_main=$(basename $mru_8)
					if ! [ -d $macos_parser_file/Users/$mru_user_main//Library/Application\ Support/com.apple.sharedfilelist/$mru_8_main ]
					then
						mkdir -p $macos_parser_file/Users/$mru_user_main//Library/Application\ Support/com.apple.sharedfilelist/$mru_8_main
					fi
					cp -r $mru_8_nest $macos_parser_file/Users/$mru_user_main//Library/Application\ Support/com.apple.sharedfilelist/$mru_8_main/$mru_8_nest_main
				done
			fi
		done
		for mru_9 in /Users/$mru_user_main/Library/Preferences/com.microsoft.office.plist
		do
			if ! [ -d $macos_parser_file/Users/$mru_user_main/Library/Preferences ]
			then
				mkdir -p $macos_parser_file/Users/$mru_user_main/Library/Preferences
			fi
			cp -r $mru_9 $macos_parser_file/Users/$mru_user_main/Library/Preferences/com.microsoft.office.plist
		done
		for mru_10 in /Users/$mru_user_main/Library/Containers/com.microsoft.*
		do
			mru_10_main=$(basename $mru_10)
			if [ -d $mru_10 ]
			then
				for mru_10_nest in /Users/$mru_user_main/Library/Containers/$mru_10_main/Data/Library/Preferences/com.microsoft.*.securebookmarks.plist
				do
					mru_10_nest_main=$(basename $mru_10_nest)
					if ! [ -d $macos_parser_file/Users/$mru_user_main/Library/Containers/$mru_10_main/Data/Library/Preferences/ ]
					then
						mkdir -p $macos_parser_file/Users/$mru_user_main/Library/Containers/$mru_10_main/Data/Library/Preferences/
					fi
					plutil -p $mru_10_nest > $macos_parser_file/Users/$mru_user_main/Library/Containers/$mru_10_main/Data/Library/Preferences/$mru_10_nest_main
				done
			fi
		done
	done
	for pppvar in /private/var/*
	do
		pppvar_main=$(basename $pppvar)
		for pppvar_1 in /private/var/$pppvar_main/Library/Preferences/com.apple.finder.plist
		do
			if ! [ -d $macos_parser_file/private/var/$pppvar_main/Library/Preferences ]
			then
				mkdir -p $macos_parser_file/private/var/$pppvar_main/Library/Preferences
			fi
			plutil -p $pppvar_1 > $macos_parser_file/private/var/$pppvar_main/Library/Preferences/com.apple.finder.plist
		done
		for pppvar_2 in /private/var/$pppvar_main/Library/Preferences/com.apple.sidebarlists.plist
		do
			if ! [ -d $macos_parser_file/private/var/$pppvar_main/Library/Preferences ]
			then
				mkdir -p $macos_parser_file/private/var/$pppvar_main/Library/Preferences
			fi
			plutil -p $pppvar_2 > $macos_parser_file/private/var/$pppvar_main/Library/Preferences/com.apple.sidebarlists.plist
		done
		for pppvar_3 in /private/var/$pppvar_main/Library/Application\ Support/com.apple.sharedfilelist/*
		do
			pppvar_3_main=$(basename $pppvar_3)
			if [ -d $pppvar_3 ]
			then
				for pppvar_3_nest in /private/var/$pppvar_main/Library/Application\ Support/com.apple.sharedfilelist/$pppvar_3_main/*.sfl*
				do
					pppvar_3_nest_main=$(basename $pppvar_3_nest)
					if ! [ -d $macos_parser_file/private/var/$pppvar_main/Library/Application\ Support/com.apple.sharedfilelist/$pppvar_3_main ]
					then
						mkdir -p $macos_parser_file/private/var/$pppvar_main/Library/Application\ Support/com.apple.sharedfilelist/$pppvar_3_main
					fi
					cp -r $pppvar_3_nest $macos_parser_file/private/var/$pppvar_main/Library/Application\ Support/com.apple.sharedfilelist/$pppvar_3_main/$pppvar_3_nest_main
				done
			fi
		done
		for pppvar_4 in /private/var/$pppvar_main/Library/Containers/com.microsoft.*
		do
			pppvar_4_main=$(basename $pppvar_4)
			if [ -d $pppvar_4 ]
			then
				for pppvar_4_nest in /private/var/$pppvar_main/Library/Containers/$pppvar_4_main/Data/Library/Preferences/com.microsoft.*.securebookmarks.plist
				do
					pppvar_4_nest_main=$(basename $pppvar_4_nest)
					if ! [ -d $macos_parser_file/private/var/$pppvar_main/Library/Containers/$pppvar_4_main/Data/Library/Preferences ]
					then
						mkdir -p $macos_parser_file/private/var/$pppvar_main/Library/Containers/$pppvar_4_main/Data/Library/Preferences
					fi
					plutil -p $pppvar_4_nest > $macos_parser_file/private/var/$pppvar_main/Library/Containers/$pppvar_4_main/Data/Library/Preferences/$pppvar_4_nest_main
				done
			fi
		done
	done
}

mac_msoffice () {
	for off_user in /Users/*
	do
		off_user_main=$(basename $off_user)
		for office in /Users/$off_user_main/Library/Preferences/com.microsoft.office.plist
		do
			if ! [ -d $macos_parser_file/Users/$off_user_main/Library/Preferences ]
			then
				mkdir -p $macos_parser_file/Users/$off_user_main/Library/Preferences 
			fi
			cp -r $off_user $macos_parser_file/Users/$off_user_main/Library/Preferences/com.microsoft.office.plist
		done
		for office_2 in /Users/$off_user_main/Library/Containers/com.microsoft.*
		do
			office_2_main=$(basename $office_2)
			for office_2_nest in /Users/$off_user_main/Library/Containers/$office_2_main/Data/Library/Preferences/com.microsoft.*.plist
			do
				office_2_nest_main=$(basename $office_2_nest)
				if ! [ -d $macos_parser_file/Users/$off_user_main/Library/Containers/$office_2_main/Data/Library/Preferences ]
				then
					mkdir -p $macos_parser_file/Users/$off_user_main/Library/Containers/$office_2_main/Data/Library/Preferences
				fi
				cp -r $office_2_nest $macos_parser_file/Users/$off_user_main/Library/Containers/$office_2_main/Data/Library/Preferences/$office_2_nest_main
			done
			for office_3 in /Users/$off_user_main/Library/Containers/$office_2_main/Data/Library/Preferences/com.microsoft.*.securebookmarks.plist
			do
				office_3_main=$(basename $office_3)
				if ! [ -d $macos_parser_file/Users/$off_user_main/Library/Containers/$office_2_main/Data/Library/Preferences ]
				then
					mkdir -p $macos_parser_file/Users/$off_user_main/Library/Containers/$office_2_main/Data/Library/Preferences
				fi
				cp -r $office_3 $macos_parser_file/Users/$off_user_main/Library/Containers/$office_2_main/Data/Library/Preferences/$office_3_main
			done
		done
		for office_4 in /Users/$off_user_main/Library/Group\ Containers/*.Office
		do
			office_4_main=$(basename $office_4)
			for office_4_nest in /Users/$off_user_main/Library/Group\ Containers/$office_4_main/MicrosoftRegistrationDB.reg*
			do
				office_4_nest_main=$(basename $office_4_nest)
				if ! [ -d $macos_parser_file/Users/$off_user_main/Library/Group\ Containers/$office_4_main ]
				then
					mkdir -p $macos_parser_file/Users/$off_user_main/Library/Group\ Containers/$office_4_main
				fi
				cp -r $office_4_nest $macos_parser_file/Users/$off_user_main/Library/Group\ Containers/$office_4_main/$office_4_nest_main
			done
		done


}

mac_netusage () {
	for netusage in /private/var/networkd/netusage.sqlite*
	do
		netusage_main=$(basename $netusage)
		if ! [ -d $macos_parser_file/private/var/networkd ]
		then
			mkdir -p $macos_parser_file/private/var/networkd
		fi
		cp -r $netusage $macos_parser_file/private/var/networkd/$netusage_main
	done
	for netuage_2 in /private/var/networkd/db/netusage.sqlite*
	do
		netusage_2_main=$(basename $netusage_2)
		if ! [ -d $macos_parser_file/private/var/networkd/db ]
		then
			mkdir -p $macos_parser_file/private/var/networkd/db
		fi
		cp -r $netusage_3 $macos_parser_file/private/var/networkd/db/$netusage_2_main
	done
}

mac_networking () {
	if ! [ -d $macos_parser_file/private/var/db/dhcpclient ]
	then
		mkdir -p $macos_parser_file/private/var/db/dhcpclient
	fi
	cp -r /private/var/db/dhcpclient/DUID_IA.plist $macos_parser_file/private/var/db/dhcpclient/DUID_IA.plist
	for netw in /private/var/db/dhcpclient/leases/*
	do
		netw_main=$(basename $netw)
		if ! [ -d $macos_parser_file/private/var/db/dhcpclient/leases ]
		then
			mkdir -p $macos_parser_file/private/var/db/dhcpclient/leases
		fi
		cp -r $netw $macos_parser_file/private/var/db/dhcpclient/leases/$netw_main
	done
	if ! [ -d $macos_parser_file/private/var/run ]
	then
		mkdir -p $macos_parser_file/private/var/run
	fi
	cp -r /private/var/run/resolv.conf $macos_parser_file/private/var/run/resolv.conf
	if ! [ -d $macos_parser_file/private/etc ]
	then
		mkdir -p /private/etc
	fi
	cp -r /private/etc/hosts $macos_parser_file/private/etc/hosts
	if ! [ -d $macos_parser_file/Library/Preferences/SystemConfiguration ]
	then
		mkdir -p $macos_parser_file/Library/Preferences/SystemConfiguration
	fi
	plutil -p /Library/Preferences/SystemConfiguration/NetworkInterfaces.plist > $macos_parser_file/Library/Preferences/SystemConfiguration/NetworkInterfaces.plist
	if ! [ -d $macos_parser_file/Library/Preferences/SystemConfiguration ]
	then
		mkdir -p $macos_parser_file/Library/Preferences/SystemConfiguration 
	fi
	plutil -p /Library/Preferences/SystemConfiguration/preferences.plist > $macos_parser_file/Library/Preferences/SystemConfiguration/preferences.plist
	if ! [ -d $macos_parser_file/Library/Preferences/SystemConfiguration ]
	then
		mkdir -p /Library/Preferences/SystemConfiguration
	fi
	plutil -p /Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist > $macos_parser_file/Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist
}

mac_notes () {
	for note_user in /Users/*
	do
		note_user_main=$(basename $note_user)
		for note in /Users/$note_user_main/Library/Containers/com.apple.Notes/Data/Library/Notes/*
		do
			note_main=$(basename $note)
			if ! [ -d $macos_parser_file/Users/$note_user_main/Library/Containers/com.apple.Notes/Data/Library/Notes ]
			then
				mkdir -p $macos_parser_file/Users/$note_user_main/Library/Containers/com.apple.Notes/Data/Library/Notes
			fi
			cp -r $note $macos_parser_file/Users/$note_user_main/Library/Containers/com.apple.Notes/Data/Library/Notes/$note_main
		done
		for note_2 in /Users/$note_user_main/Library/Group\ Containers/group.com.apple.notes/NoteStore.sqlite*
		do
			note_2_main=$(basename $note_2)
			if ! [ -d $macos_parser_file/Users/$note_user_main/Library/Group\ Containers/group.com.apple.notes ]
			then
				mkdir -p $macos_parser_file/Users/$note_user_main/Library/Group\ Containers/group.com.apple.notes 
			fi
		done
}

mac_notifications () {
	for notify_user in /Users/*
	do
		notify_user_main=$(basename $notify_user)
		for notification in /Users/$notify_user_main/Library/Application\ Support/NotificationCenter/*.db*
		do
			notification_main=$(basename $notification)
			if ! [ -d $macos_parser_file/Users/$notify_user_main/Library/Application\ Support/NotificationCenter ]
			then
				mkdir -p $macos_parser_file/Users/$notify_user_main/Library/Application\ Support/NotificationCenter
			fi
			cp -r $notification $macos_parser_file/Users/$notify_user_main/Library/Application\ Support/NotificationCenter/$notification_main
		done
	done
	for notification_2 in  /private/var/folders/*
	do
		notification_2_main=$(basename $notification_2)
		for notification_2_nest in /private/var/folder/$notification_2_main/*
		do
			notification_2_nest_main=$(basename $notification_2_nest)
			for notification_2_nest_nest in /private/var/folder/$notification_2_main/$notification_2_nest_main/0/com.apple.notificationcenter/db/db*
			do
				notification_2_nest_nest_main=$(basename $notification_2_nest_nest)
				if ! [ -d $macos_parser_file/private/var/folder/$notification_2_main/$notification_2_nest_main/0/com.apple.notificationcenter/db ]
				then
					mkdir -p $macos_parser_file/private/var/folder/$notification_2_main/$notification_2_nest_main/0/com.apple.notificationcenter/db
				fi
				cp -r $notification_2_nest_nest $macos_parser_file/private/var/folder/$notification_2_main/$notification_2_nest_main/0/com.apple.notificationcenter/db/$notification_2_nest_nest_main
			done
			for notification_3 in /private/var/folder/$notification_2_main/$notification_2_nest_main/0/com.apple.notificationcenter/db2/db*
			do
				notification_3_main=$(basename $notification_3)
				if ! [ -d $macos_parser_file/private/var/folder/$notification_2_main/$notification_2_nest_main/0/com.apple.notificationcenter/db2 ]
				then
					mkdir -p $macos_parser_file/private/var/folder/$notification_2_main/$notification_2_nest_main/0/com.apple.notificationcenter/db2
				fi
				cp -r $notification_3 $macos_parser_file/private/var/folder/$notification_2_main/$notification_2_nest_main/0/com.apple.notificationcenter/db2/$notification_3_main
			done
		done
	done
}

mac_powerlog () {
	for powerl in /private/var/db/powerlog/Library/BatteryLife/*
	do
		powerl_main=$(basename $powerl)
		if ! [ -d $macos_parser_file/private/var/db/powerlog/Library/BatteryLife ]
		then
			mkdir -p $macos_parser_file/private/var/db/powerlog/Library/BatteryLife
		fi
		cp -r $powerl $macos_parser_file/private/var/db/powerlog/Library/BatteryLife/$powerl_main
	done
	for powerl_2 in  /private/var/db/powerlog/Library/BatteryLife/Archives/*
	do
		powerl_2_main=$(basename $powerl_2)
		if ! [ -d $macos_parser_file/private/var/db/powerlog/Library/BatteryLife/Archives ]
		then
			mkdir -p $macos_parser_file/private/var/db/powerlog/Library/BatteryLife/Archives
		fi
		cp -r $powerl_2 $macos_parser_file/private/var/db/powerlog/Library/BatteryLife/Archives/$powerl_2_main
	done
}

mac_printjobs () {
	for pjobs in /private/var/spool/cups/*
	do
		pjobs_main=$(basename $pjobs)
		if ! [ -d $macos_parser_file/private/var/spool/cups ]
		then
			mkdir -p $macos_parser_file/private/var/spool/cups
		fi
		cp -r $pjobs $macos_parser_file/private/var/spool/cups/$pjobs_main
	done
}

mac_quarantine () {
	for quarantine_user in /Users/*
	do
		quarantine_user_main=$(basename $quarantine_user)
		for quarantine in /Users/$quarantine_user_main/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2
		do
			if ! [ -d $macos_parser_file/Users/$quarantine_user_main/Library/Preferences ]
			then
				mkdir -p $macos_parser_file/Users/$quarantine_user_main/Library/Preferences
			fi
			cp -r $quarantine $macos_parser_file/Users/$quarantine_user_main/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2
		done
	done
	for pquarantine	in /private/var/*
	do
		pquarantine_main=$(basename $pquarantine)
		for pquarantine_2 in /private/var/$pquarantine_main/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2
		do
			if ! [ -d $macos_parser_file/private/var/$pquarantine_main/Library/Preferences ]
			then
				mkdir -p $macos_parser_file/private/var/$pquarantine_main/Library/Preferences
			fi
			cp -r $pquarantine_2 $macos_parser_file/private/var/$pquarantine_main/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2
		done
	done
	if ! [ -d $macos_parser_file/private/var/db ]
	then
		mkdir -p  $macos_parser_file/private/var/db
	fi
	cp -r /private/var/db/.LastGKReject $macos_parser_file/private/var/db/.LastGKReject
}

if [ $(uname) = 'Linux' ]
then
    if [ "$EUID" -eq 0 ]
    then
	name=$(whoami)
	hname=$(hostname)
	linux_parser_file="$name-$hname"
	mkdir $linux_parser_file
	for user in $(awk -F: '{if ($6 ~ /^\/home/ ) print $1}' /etc/passwd)
	do
	    users+=( $user )
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
    if [ "$EUID" -eq 0 ]
    then
		name=$(whoami)
		hname=$(hostname)
		macos_parser_file="$name-$hname"
		mkdir $macos_parser_file
		mac_autoruns
		mac_ard
		mac_asl
		mac_applist
		mac_cmdhistory
		mac_coreanalytics
		mac_cfurl_cache
		mac_activer_directory
		mac_bluetooth
		mac_bash_file
		mac_dock_items
		mac_documentrevisions
		mac_dynamictext
		mac_filesharing
		mac_firefox
		mac_fsevents
		mac_idevice
		mac_imessage
		mac_inetaccounts
		mac_interactions
		mac_installhistory
		mac_knowledgec_db
		mac_keychain
		mac_mru
		mac_msofficce
		mac_netusage
		mac_networking 
		mac_notes
		mac_notifications
		mac_powerlog
		mac_printjobs
		mac_quarantine
    fi
else
    echo "This is not MacOS or Linux sorry"
fi
