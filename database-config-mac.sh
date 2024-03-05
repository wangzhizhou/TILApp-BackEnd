#!/usr/bin/env bash
#-*-coding: utf-8 -*-

install_docker() {  
	brew install --cask docker
	open -a docker
	if [ $? -eq 0 ];
	then
		echo Docker has been Launched
	fi
}

uninstall_docker() {
	brew uninstall --cask docker
	brew autoremove 
}

remove_database() {

	echo remove database

	POSTGRES=psql
	docker stop $POSTGRES
	docker rm $POSTGRES

	POSTGRES_TEST=psql-test
	docker stop $POSTGRES_TEST
	docker rm $POSTGRES_TEST

	remove_docker_image postgres

	echo removed!!!
}

remove_docker_image() {
	image_name=$(docker images | grep $1 | cut -d' ' -f 1)
	if [ -n "$image_name" ]; then
		docker rmi postgres
	fi
}

reset_database() {
	remove_database
	configure_database
}

configure_database() {

	echo Configuring Postgres Database...

	docker run \
		--name psql \
		-e POSTGRES_DB=vapor_database \
		-e POSTGRES_USER=vapor_username \
		-e POSTGRES_PASSWORD=vapor_password \
		-p 5432:5432 \
		-d postgres

	docker run \
		--name psql-test \
		-e POSTGRES_DB=vapor_test \
		-e POSTGRES_USER=vapor_username \
		-e POSTGRES_PASSWORD=vapor_password \
		-p 5433:5432 \
		-d postgres

	if [ $? -eq 0 ];
	then
		docker ps -a | grep postgres
		docker ps -a | grep postgres-test
	fi

	echo Database configure completed!
}

usage() {
	echo Usage:
	echo "	$0 [ -i | -d | -r | -u]"
	echo 
	echo Description:
	echo "	-i, install docker"
	echo "	-c, configure database postgres"
	echo "	-r, reset database"
	echo "	-u, unstall docker"

}

main() {

    if [ $# -eq 0 ]
    then
        usage
        exit 1
    fi

    while getopts "icru" opt
    do
        case "$opt" in
        i)
            install_docker
            ;;
        c)
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