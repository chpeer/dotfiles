function mettle() {
	local METTLE_CACHE='~/.cache/please/build-metadata-store/mettle_lofi/'
    if [[ $* == "on" ]]; then
        export PLZ_CONFIG_PROFILE=remote
    elif [[ $* == "off" ]]; then
        export PLZ_CONFIG_PROFILE=noremote
    elif [[ $* == "clear" ]]; then
        echo "rm -rf $METTLE_CACHE"
        rm -rf $METTLE_CACHE
    else
        echo 'Usage: mettle [on|off|clear]'
        return 1
    fi
	echo PLZ_CONFIG_PROFILE=$PLZ_CONFIG_PROFILE
}

