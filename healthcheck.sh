#!/bin/bash
PATH=/usr/local/enumivo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
script="$(readlink -f $0)"
wd="$(dirname ${script})"
# log file
logfile="${wd}/healthcheck_monitor.log"
# PushBullet configuration
push_token='<PushBullet Token>'
# enable/disable PushBullet notifications. If you set the variable to 1 will be anabled.
# anything else meanse disabled. By default is enabled.
pushbullet=1

# Telegram configuration
# telegram bot token ID
bot_token='<Telegram Config+ID>'
# private chat ID
chat_id='<Telegram private chat ID>'
# enable/disable Telegram chat. If you set the variable to 1 will be anabled.
# anything else meanse disabled. By default is enabled.
telechat=1

TS="$(date '+[%Y-%m-%d %H:%M:%S]')"

pid=$(pgrep enunode)
if [[ -z ${pid} ]]; then
	# grab last epoch time written in the logs
	lasttime=$(tail -1 ${logfile} 2>/dev/null)
	if [[ -z ${lasttime} ]]; then
		sms="Node was not running."
	else
		now_epoch=$(date +"%s")
		time_diff=$(((${now_epoch}-${lasttime})/60))
		sms="Node is not running for ${time_diff} minute(s)"
	fi
	if [[ ${pushbullet} -eq 1 ]]; then
		curl -s -u ${push_token}: https://api.pushbullet.com/v2/pushes -d type=note -d title="Node not running alert!" -d body="${TS} ${sms}"
	fi
	if [[ ${telechat} -eq 1 ]]; then
		curl -s https://api.telegram.org/bot${bot_token}/sendMessage -d chat_id="${chat_id}" -d text="${TS} ${sms}" > /dev/null
	fi
else
	echo $(date +"%s") > ${logfile}
fi
