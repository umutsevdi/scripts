#!/bin/bash
#******************************************************************************
#
# * File: zdt.sh
#
# * Author:  Umut Sevdi
# * Created: 05/01/24
# * Description: Upgrades a container to the latest with no downtime
#*****************************************************************************


DOCKER_COMPOSE=
CONTAINER=
SERVICE=
TIMER=20

scale() {
    docker-compose up $DOCKER_COMPOSE -d --scale $SERVICE=2 --no-recreate
    sleep $TIMER
    docker rm -f $OLD_WEB_APP
    docker-compose up $DOCKER_COMPOSE -d --scale $SERVICE=1 --no-recreate
}

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -c|--compose)
            DOCKER_COMPOSE="$2"
            shift # past argument
            shift # past value
            ;;
        -s|--service)
            SERVICE="$2"
            shift # past argument
            shift # past value
            ;;
        *)  # unknown option
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

