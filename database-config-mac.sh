#!/usr/bin/env bash
#-*-coding: utf-8 -*-

install_docker() {  
	brew cask install docker

	open -a docker
	if [ $? -eq 0 ];
	then
		echo Docker has been Launched
	fi
}

uninstall_docker() {
	brew cask uninstall docker
}

remove_database() {
	echo remove database
    POSTGRES=$(docker ps -a | grep postgres | cut -d ' ' -f 1)
	if [ -n "$POSTGRES" ];
	then
		docker stop $POSTGRES
		docker rm $POSTGRES
		docker rmi postgres
	fi
	echo removed!!!
}

reset_database() {
	remove_database
	configure_database
}

configure_database() {

	echo Configuring Postgres Database...

	docker run --name postgres -e POSTGRES_DB=vapor \
		-e POSTGRES_USER=vapor -e POSTGRES_PASSWORD=password \
		-p 5432:5432 -d postgres

	if [ $? -eq 0 ];
	then
		docker ps -a | grep postgres
	fi

	echo Database configure completed!
}

usage() {
	echo Usage:
	echo "	$0 [ -i | -d | -r | -u]"
	echo 
	echo Description:
	echo "	-i, install docker"
	echo "	-d, configure database postgres"
	echo "	-r, reset database"
	echo "	-u, unstall docker"

}

main() {

    if [ $# -eq 0 ]
    then
        usage
        exit 1
    fi

    while getopts "iudr" opt
    do
        case "$opt" in
        i)
            install_docker
            ;;
        d)
            configure_database
            ;;
        r)
            reset_database
            ;;
        u)
            uninstall_docker
            ;;
        *)
            usage
            exit 1
            ;;
        esac
    done
}

main $*
