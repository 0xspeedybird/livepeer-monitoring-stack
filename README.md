![Power Up](images/power_up.png "Power Up")
# SpeeedyBird Livepeer Monitor
Hi! :baby_chick::baby_chick: This repo contains two docker compose "projects".

One is called "client-monitor".  It is a simple compose file and associated Promtail config.  It is used to connect to the server-monitor.

The other is called "server-monitor".  It is a Grafana Loki Prometheus Grafana (GPG) stack with a pre-built dashboard that visualizes a livepeer Orchestrator's block status.  There are also several alerts provided with this repo.

-   Prometheus Alerts (~/speedy-livepeer/server-monitor/configs/prometheus/rules.yml)   
	- **InstanceDown** -> Orchestrator metrics are not reachable
	- **HighLoadSessionCapacity** -> Orchestrator sessions exceeded 85% of the max available sessions.
	- **ProcessTooManyRestarts** -> A process has had more than two restarts within the last 15 minutes. This indicates potential stability issues.
	- **DailyWinningTicketSummary** -> A daily summary of tickets received. This is an approximation due to Prometheus scrape intervals.
   -   Loki Alerts (~/speedy-livepeer/server-monitor/configs/loki/rules/fake/rules.yml)
	   - **BlockwatchFailure** -> Blockwatch errors indicate a potential issue with your Arbitrum RPC endpoint.
	   - **OrchestratorOverloaded** -> The Orchestrator is overloaded and is throwing "*OrchestratorBusy*" errors.
	   - **GasPriceTooHigh** -> Gas prices are too high to execute transactions (per Orchestrator configuration). Unlikely to occur since Arbitrum Nitro upgrade in 2022.
	   - **FailedSegementUpload** -> May indicate bandwidth issues.
	   - **InsufficientFunds** -> The configured address does not have enough funds to operate (e.g. redeem tickets).
       - **TicketExpired** -> Expired tickets were found. You may need to review them manually and potentially [mark them as redeemed](https://gist.github.com/yondonfu/ea57cfe9510b6526288d456229a3d61e).

# Automated Setup
## Server Monitor

Run the below command but first replace the values prefixed with dollar signs per the following table.

| **Value to Replace** | **New Value** |
| --- | --- |
| $ORCHESTRATOR\_IP\_DNS | The IP address or DNS hostname of the Orchestrator node. Include the port if using something other than 80 or 443. This only supports one Orchestrator.  Update the Prometheus configuration manually to add more.|
| $TG\_BOT\_TOKEN | The token provided by the BotFather from the section [Create a Telegram Bot](#_z0880pkjt81e) |
| $TG\_CHAT\_ID | The chat id where you want to send alerts from the section [Configure Alertmanager Telegram Receiver](#_tqb42d1chxu8) |
| $LOKI\_DNS | The DNS hostname for your Loki system on Host Machine 2.  Do not supply a port.  Port 443 is assumed.|
| $LOKI\_DNS\_Email | The email associated with your DNS provider for the Loki DNS |


    curl -sL https://raw.githubusercontent.com/0xspeedybird/livepeer-monitoring-stack/main/server-monitor/bootstrap-server.sh | sudo bash -s -- -i $ORCHESTRATOR_IP_DNS -b $TG_BOT_TOKEN -c $TG_CHAT_ID -d $LOKI_DNS -e $LOKI_DNS_Email

## Client Monitor

| Value to Replace |  New Value|
|--|--|
| $LOKI\_DNS | The DNS hostname for your Loki system on Host Machine 2.  Do not supply a port.  Port 443 is assumed.|

    curl -sL https://raw.githubusercontent.com/0xspeedybird/livepeer-monitoring-stack/main/client-monitor/bootstrap-client.sh | sudo bash -s -- -i $LOKI_DNS

# Manual Setup

See the [detailed install guide](INSTALL_GUIDE.md) in this repo.

# General Notes on Configs
## Prometheus
### Scrape Configs
All scrape configs are located at: */configs/prometheus/prometheus.yml*  
### Alerting Rules
All Prometheus alert rules configs are located at: */configs/prometheus/rules.yml* 
## Grafana
### Data Sources
Prometheus dashboard located at. *./configs/grafana/provisioning/datasources/prometheus_ds.yml*
### Dashboards
Dashboards and providers located at: *./configs/grafana/provisioning/dashboards*
### Plugins
Plugins are located at: *./configs/grafana/plugins*
## Loki
### Alerting Rules
All Loki alert rules configs are located at: */configs/loki/rules/fake/rules.yml*

# Special Thanks
[Mike Zupper](https://github.com/mikezupper) - for his awesome support and Livepeer contributions