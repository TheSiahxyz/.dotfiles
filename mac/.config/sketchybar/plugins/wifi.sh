#!/bin/bash

POPUP_OFF="sketchybar --set wifi popup.drawing=off"
POPUP_CLICK_SCRIPT="sketchybar --set wifi popup.drawing=toggle"

source "$CONFIG_DIR/globalstyles.sh" # Loads defined colors

INFO="$(/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I | awk -F ' SSID: ' '/ SSID: / {print $2}')"
IS_VPN=$(/usr/local/bin/piactl get connectionstate)
CURRENT_WIFI="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I)"
IP_ADDRESS="$(ipconfig getifaddr en0)"
SSID="$(echo "$CURRENT_WIFI" | grep -o "SSID: .*" | sed 's/^SSID: //')"
CURR_TX="$(echo "$CURRENT_WIFI" | grep -o "lastTxRate: .*" | sed 's/^lastTxRate: //')"

# ICON="$([ -n "$INFO" ] && echo "$WIFI_CONNECTED" || echo "$WIFI_DISCONNECTED")"

if [ -n "$INFO" ]; then
	ICON_COLOR=$GREEN
	ICON="$WIFI_CONNECTED"
elif [ -z "$INFO" ]; then
	ICON="$WIFI_DISCONNECTED"
elif [[ $IS_VPN != "Disconnected" ]]; then
	ICON_COLOR=$HIGHLIGHT
	ICON=􀎡
elif [[ $SSID = "Ebrietas" ]]; then
	ICON_COLOR=$WHITE
	ICON=􀉤
elif [[ $SSID != "" ]]; then
	ICON_COLOR=$WHITE
	ICON=􀐿
elif [[ $CURRENT_WIFI = "AirPort: Off" ]]; then
	ICON_COLOR=$RED
	ICON=􀐾
else
	ICON_COLOR=$WHITE_25
	ICON=􀐾
fi

render_bar_item() {
	sketchybar --set $NAME \
		icon.color=$ICON_COLOR \
		icon=$ICON \
		click_script="$POPUP_CLICK_SCRIPT"
}

render_popup() {
	if [ "$SSID" != "" ]; then
		args=(
			--set wifi click_script="$POPUP_CLICK_SCRIPT"
			--set wifi.ssid label="$SSID"
			--set wifi.strength label="$CURR_TX Mbps"
			--set wifi.ipaddress label="$IP_ADDRESS"
			click_script="printf $IP_ADDRESS | pbcopy;$POPUP_OFF"
		)
	else
		args=(
			--set wifi click_script="")
	fi

	sketchybar "${args[@]}" >/dev/null
}

update() {
	render_bar_item
	render_popup
	source "$CONFIG_DIR/icons.sh"
	INFO="$(/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I | awk -F ' SSID: ' '/ SSID: / {print $2}')"
	LABEL="$INFO ($(ipconfig getifaddr en0))"
	ICON="$([ -n "$INFO" ] && echo "$WIFI_CONNECTED" || echo "$WIFI_DISCONNECTED")"
	sketchybar --set $NAME icon="$ICON" label="$LABEL"
}

click() {
	CURRENT_WIDTH="$(sketchybar --query $NAME | jq -r .label.width)"

	WIDTH=0
	if [ "$CURRENT_WIDTH" -eq "0" ]; then
		WIDTH=dynamic
	fi

	sketchybar --animate sin 20 --set $NAME label.width="$WIDTH"
}

popup() {
	sketchybar --set "$NAME" popup.drawing="$1"
}

case "$SENDER" in
"routine" | "forced")
	update
	;;
"mouse.entered")
	popup on
	;;
"mouse.exited" | "mouse.exited.global")
	popup off
	;;
"wifi_change")
	update
	;;
"mouse.clicked")
	click
	;;
esac
