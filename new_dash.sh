#!/bin/bash


#Setting the up the variables
fstab=/etc/fstab


coinCommand="$coinCommand2"
github="$cloneRepo2"
coinName="$coinName2"
fileConf="$fileConf2"

#Conf File
confPath=~/.$coinName/$fileConf
rpcuser="$rpcuser2"
rpcpassword="$rpcpassword2"
rpcport="$rpcport2"
mnport="$mnport2"
masternodeprivkey="$masternodeprivkey2"
masternodeaddr="$masternodeaddr2"

apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
apt-get install -y libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev libboost-all-dev unzip libminiupnpc-dev python-virtualenv

sudo apt-get install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils


apt-get install -y software-properties-common && add-apt-repository -y ppa:bitcoin/bitcoin
apt-get update -y
apt-get install -y libdb4.8-dev libdb4.8++-dev
apt-get install -y git

if [ "$coinCommand" = "monoecid" ]
then
	wget https://github.com/monacocoin-net/monoeci-core/releases/download/0.12.2/monoeciCore-0.12.2-linux64-cli.Ubuntu14.04.tar.gz
	tar xvf monoeciCore-0.12.2-linux64-cli.Ubuntu14.04.tar.gz
	strip $coinCommand
	cp $coinCommand /usr/bin/
	cp monoeci-cli /usr/bin/
	$coinCommand &
	sleep 5	
	monoeci-cli stop
	sleep 5
	
	
	#To be continue on configuration
	rm -rf $confPath
	echo "rpcuser=$rpcuser" > $confPath
	echo "rpcpassword=$rpcpassword" >> $confPath
	echo "rpcallowip=127.0.0.1" >> $confPath
	echo "server=1" >> $confPath
	echo "listen=1" >> $confPath
	echo "daemon=1" >> $confPath
	echo "port=$mnport" >> $confPath
	echo "externalip=$masternodeaddr" >> $confPath
	echo "masternode=1" >> $confPath
	echo "maxconnections=24" >> $confPath
	echo "masternodeprivkey=$masternodeprivkey" >> $confPath
	echo "logtimestamps=1" >> $confPath
	echo "mnconflock=1" >> $confPath

	nohup $coinCommand &

	git clone https://github.com/monacocoin-net/sentinel.git
	cd ~/sentinel/
 	virtualenv ./venv	
	./venv/bin/pip install -r requirements.txt
	echo "monoeci_conf=$confPath" >> ~/sentinel/sentinel.conf

	crontab -l > mycron

	echo "* * * * * cd ~/sentinel/ && ./venv/bin/python bin/sentinel.py >/dev/null 2>&1" >> mycron
	crontab mycron
	rm mycron

fi








