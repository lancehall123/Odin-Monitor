#!/bin/bash
# nodemon 1.0 - Odin Masternode Monitoring

#Processing command line params
if [ -z $1 ]; then dly=1; else dly=$1; fi   # Default refresh time is 1 sec

datadir="/root/.odin"   # Default datadir is /root/.odin
txid="64eff2f8baf15dfbbc915e01b0b4066a9fa49e91ad3d29423209d1a010c3a92e"  ####CHANGE THIS

# Install jq if it's not present
dpkg -s jq 2>/dev/null >/dev/null || sudo apt-get -y install jq

watch -ptn $dly "echo '===========================================================================
Outbound connections to other Odin nodes [Odin datadir: $datadir]
===========================================================================
Node IP               Ping    Rx/Tx     Since  Hdrs   Height  Time   Ban
Address               (ms)   (KBytes)   Block  Syncd  Blocks  (min)  Score
========================================================================='

odin-cli -datadir=$datadir getpeerinfo | jq -r '.[] | select(.inbound==false) | \"\(.addr),\(.pingtime*1000|floor) ,\
\(.bytesrecv/1024|floor)/\(.bytessent/1024|floor),\(.startingheight) ,\(.synced_headers) ,\(.synced_blocks)  ,\
\((now-.conntime)/60|floor) ,\(.banscore)\"'| column -t -s ',' &&
echo '============================Server Info============================================'
uptime
echo '==============================Scores========================================='
echo 'Masternode Scores: ' && odin-cli -datadir=$datadir getmasternodescores | grep $txid
echo '===========================Masternode Status======================================'
echo 'Masternode Status: ' && odin-cli -datadir=$datadir getmasternodestatus
echo '==========================================================================='
echo 'Usage: nodemon.sh [refresh delay]'
echo 'Example: nodemon.sh 10 will run every 10 seconds'
echo '\n\nPress Ctrl-C to Exit...'"
