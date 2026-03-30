#¬/bin/bash

watch --color -d 'nmcli --colors yes -f IN-USE,NAME,SSID,BSSID,MODE,CHAN,FREQ,RATE,SIGNAL,BARS,SECURITY,DEVICE,ACTIVE device wifi'
