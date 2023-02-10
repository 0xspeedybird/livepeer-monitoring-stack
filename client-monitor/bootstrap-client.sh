#!/bin/bash

set -e
Color_Off='\033[0m'       # Text Reset
BGreen='\033[1;32m'       # Bold Green

while getopts ':i:' opt; do
  case "$opt" in
    i)
      arg="$OPTARG"
      echo "User supplied Loki host name value as '${OPTARG}'"
      host_machine_2_host_name=$OPTARG
      ;;
    h)
      echo "Usage: $(basename $0) [-i arg]"
      echo "i = Loki host name (e.g. loki.speedybird.xyz)"
      exit 0
      ;;

    ?)
      echo -e "Invalid command option.\nUsage: $(basename $0) [-i arg]"
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

checkargs(){
  if [ "$host_machine_2_host_name" = "" ]; then
      echo -e "The Loki host name is required.  Please supplied a valid value."
      exit 1;
  fi
}

checkapp(){
  if ! command -v $1 > /dev/null 2>&1; then
    echo "The \"$1\" program is required by this script. Install \"$1\" and try again."
    exit 1
  fi
}

checkargs
checkapp git
checkapp docker
checkapp docker compose

echo -e "Pre-requisites met.  Proceeding with install..."

mkdir -p ~/speedy-livepeer
cd ~/speedy-livepeer
git clone https://github.com/0xspeedybird/livepeer-monitoring-stack.git
cd livepeer-monitoring-stack/client-monitor

echo -e "Updating configs with supplied settings...."
echo -e "Loki Hostname: ${host_machine_2_host_name}"
echo -e "Note: If any of these values need to be updated later, you will have to do it manually.  This script is only able to update these settings on its first run."

sed -i "s/PutYourLokiDNSHostNameHere/$host_machine_2_host_name/" promtail.yml

echo -e "Done.  Starting container via Docker compose...."
docker compose up -d
echo -e "${BGreen}ALL DONE!${Color_Off}"
echo -e "================================================================"
echo -e "${BGreen}To view logs, run 'docker logs promtail'${Color_Off}"
echo -e "================================================================"
echo -e "================================================================"
