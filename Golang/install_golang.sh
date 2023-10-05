#!/bin/bash

golang_version=go$golang_version
#Function Slack Notification
function Slack_notification() {
# Send notification messages to a Slack channel by using Slack webhook
# 
# input parameters:
#   color = good; warning; danger
#   $text_slack - main text
######
  local message="payload={\"attachments\":[{\"text\":\"$text_slack\",\"color\":\"$color\"}]}"
  curl -X POST --data-urlencode "$message" ${SLACK_WEBHOOK_URL}
}


# Check if Go is already installed
if [[ ! $(command -v go) ]]; then
  echo "Go is not installed. Installing..."
  # Install Go using the installer
  wget https://golang.org/dl/$golang_version.linux-amd64.tar.gz
  if [ $? -gt 0 ]; then text_slack="Go error download version $golang_version in $(hostname)."; color='danger'; Slack_notification; exit 1; fi;
  tar -C /usr/local -xzf $golang_version.linux-amd64.tar.gz
  if [ $? -gt 0 ]; then text_slack="Go error unpack version $golang_version in $(hostname)."; color='danger'; Slack_notification; exit 1; fi;
  echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a /etc/profile; source /etc/profile;
  
  # Remove the downloaded archive
  rm $golang_version.linux-amd64.tar.gz
  
  if [ $? -eq 0 ] 
	then 
		text_slack="Go is installed to version $golang_version in $(hostname)." 
		color='good'
		Slack_notification 
	else 
		text_slack="Go error installed to version $golang_version in $(hostname)." 
		color='danger' 
		Slack_notification
	fi
else
  # Get the current Go version
  current_version=$(go version | awk '{print $3}')
  update_version=go$golang_version

  # Check if an update is needed
  if [[ $current_version != $golang_version ]]; then
    echo "Updating Go to version $golang_version..."
    wget https://golang.org/dl/$golang_version.linux-amd64.tar.gz
	if [ $? -gt 0 ]; then text_slack="Go error download version $golang_version in $(hostname)."; color='danger'; Slack_notification; exit 1; fi;
	tar -C /usr/local -xzf $golang_version.linux-amd64.tar.gz
	if [ $? -gt 0 ]; then text_slack="Go error unpack version $golang_version in $(hostname)."; color='danger'; Slack_notification; exit 1; fi;
    rm $golang_version.linux-amd64.tar.gz
	if [ $? -eq 0 ] 
	then 
		text_slack="Go is updated to version $golang_version in $(hostname)." 
		color='good'
		Slack_notification
	else 
		text_slack="Go error updated to version $golang_version in $(hostname)." 
		color='danger'
		Slack_notification
	fi
  fi
fi