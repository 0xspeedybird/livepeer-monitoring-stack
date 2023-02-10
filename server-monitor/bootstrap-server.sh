#!/bin/bash

set -e
Color_Off='\033[0m'       # Text Reset
BGreen='\033[1;32m'       # Bold Green

while getopts ':i:b:c:d:e:' opt; do
  case "$opt" in
    i)
      arg="$OPTARG"
      echo "User supplied Orchestrator IP/DNS value as '${OPTARG}'"
      orchestrator_ip_or_dns=$OPTARG
      ;;

    b)
      arg="$OPTARG"
      echo "User supplied Telegram Bot Token value as '${OPTARG}'"
      tg_bot_token=$OPTARG
      ;;

    c)
      arg="$OPTARG"
      echo "User supplied Telegram Chat Id value as '${OPTARG}'"
      tg_chat_id=$OPTARG
      ;;

    d)
      arg="$OPTARG"
      echo "User supplied Loki DNS host value as '${OPTARG}'"
      loki_dns_host_name=$OPTARG
      ;;

    e)
      arg="$OPTARG"
      echo "DNS Email value as '${OPTARG}'"
      loki_dns_host_email=$OPTARG
      ;;

    h)
      echo "Usage: $(basename $0) [-i arg] [-b arg] [-c arg] [-d arg] [-e arg]"
      echo "i = Your Orchestrator IP address/DNS"
      echo "b = Your Telegram Bot Token"
      echo "c = Your Telegram Chat Id"
      echo "d = Your Loki DNS Host Name (e.g. loki.speedybird.xyz)"
      echo "e = Your email used for Loki DNS registration"
      exit 0
      ;;

    ?)
      echo -e "Invalid command option.\nUsage: $(basename $0) [-i arg] [-b arg] [-c arg] [-d arg] [-e arg]"
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

checkargs(){
  error_out=0
  if [ "$orchestrator_ip_or_dns" = "" ]; then
      echo -e "The Orchestrator IP/DNS is required.  Please supplied a valid value."
      error_out=1
  fi
  if [ "$tg_bot_token" = "" ]; then
      echo -e "The Telegram Bot Token is required.  Please supplied a valid value."
      error_out=1
  fi
  if [ "$tg_chat_id" = "" ]; then
      echo -e "The Telegram Bot Chat Id is required.  Please supplied a valid value."
      error_out=1
  fi
  if [ "$loki_dns_host_name" = "" ]; then
      echo -e "The DNS Host name for the server is required.  Please supplied a valid value."
      error_out=1
  fi
  if [ "$loki_dns_host_email" = "" ]; then
      echo -e "The email address associated with your Loki DNS is required.  Please supplied a valid value."
      error_out=1
  fi
  if [ $error_out = 1 ]; then
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

mkdir ~/speedy-livepeer
cd ~/speedy-livepeer
docker volume create grafana_data
docker volume create prometheus_data
docker volume create loki_data
git clone https://github.com/0xspeedybird/livepeer-monitoring-stack.git
cd livepeer-monitoring-stack/server-monitor

echo -e "Updating configs with supplied settings...."
echo -e "Orchestrator IP/DNS: ${orchestrator_ip_or_dns}"
echo -e "Telegram Bot Token: ${tg_bot_token}"
echo -e "Telegram Chat Id: ${tg_chat_id}"
echo -e "Loki DNS: ${loki_dns_host_name}"
echo -e "Loki DNS Account Email: ${loki_dns_host_email}"
echo -e "Note: If any of these values need to be updated later, you will have to do it manually.  This script is only able to update these settings on its first run."

sed -i "s/PutYourOrchestartorIPOrDNSHere/$orchestrator_ip_or_dns/" configs/prometheus/prometheus.yml
sed -i "s/PutYourBotTokenHere/$tg_bot_token/" configs/prometheus/alertmanager.yml
sed -i "s/PutYourChatIdHere/$tg_chat_id/" configs/prometheus/alertmanager.yml
sed -i "s/PutYourEmailHere/$loki_dns_host_email/" configs/traefik.yml
sed -i "s/PutYourDNSHostNameHere/$loki_dns_host_name/" docker-compose.yml

echo -e "Done.  Starting containers via Docker compose...."
docker compose up -d
echo -e "${BGreen}ALL DONE!${Color_Off}"
echo -e "================================================================"
echo -e "${BGreen}Grafana here -> https://${loki_dns_host_name}/grafana${Color_Off}"
echo -e "================================================================"
echo -e "${BGreen}To view logs of the containers in the stack, run 'docker logs ...'\n[replace ... with one of the container names (grafana, loki, prometheus, alertmanger)]${Color_Off}"
echo -e "================================================================"
echo -e "================================================================"
