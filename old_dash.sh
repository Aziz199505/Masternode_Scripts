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
apt-get install -y build-essential libtool autotools-dev pkg-config libssl-dev libboost-all-dev autoconf automake



apt-get install -y git
git clone https://github.com/bitcoin-core/secp256k1
cd ~/secp256k1
./autogen.sh
./configure
make
./tests
make install


apt-get install -y libqt4-dev libminiupnpc-dev
apt-get install -y libgmp-dev
apt-get install -y openssl
apt-get install -y libevent-dev


apt-get install -y software-properties-common && add-apt-repository -y ppa:bitcoin/bitcoin
apt-get update -y
apt-get install -y libdb4.8-dev libdb4.8++-dev

dd if=/dev/zero of=/var/swap.img bs=1024k count=1000
mkswap /var/swap.img
swapon /var/swap.img
chmod 0600 /var/swap.img
chown root:root /var/swap.img

echo "/var/swap.img none swap sw 0 0" >> $fstab

cd ~
git clone $github

if [ "$coinCommand" = "chaincoind" ]
then
	cd ~/chaincoin/
	./autogen.sh 
	./configure --without-gui
	make
	make install
	sleep 5 
	$coinCommand --daemon
	sleep 5
	pkill -9 $coinCommand
	sleep 5
	cd
	

else
	cd ~/$coinName/src
	make -f makefile.unix # Headless	
	strip $coinCommand
	cp $coinCommand /usr/bin/
	$coinCommand &
	sleep 5
	$coinCommand stop
	sleep 5	
fi




#To be continue on configuration
rm -rf $confPath
echo "rpcuser=$rpcuser" > $confPath
echo "rpcpassword=$rpcpassword" >> $confPath
echo "rpcport=$rpcport" >> $confPath
echo "server=1" >> $confPath
echo "listen=1" >> $confPath
echo "daemon=1" >> $confPath
echo "masternodeaddr=$masternodeaddr:$mnport" >> $confPath
echo "masternode=1" >> $confPath
echo "masternodeprivkey=$masternodeprivkey" >> $confPath
if [ "$coinCommand" = "magnetd" ]
then
	echo "addnode=35.195.167.40:17177" >> $confPath
	echo "aaddnode=35.199.188.194:17177" >> $confPath
	echo "addnode=104.196.155.39:17177" >> $confPath
	echo "addnode=35.197.228.109:17177" >> $confPath
	echo "addnode=35.198.35.45:17177" >> $confPath
	echo "addnode=35.197.145.93:17177" >> $confPath
	echo "addnode=35.199.1.114:17177" >> $confPath
	echo "addnode=35.201.4.254:17177" >> $confPath
	echo "addnode=35.188.240.39:17177" >> $confPath
	echo "addnode=35.199.48.8:17177" >> $confPath
	echo "addnode=146.148.79.31:17177" >> $confPath
	echo "addnode=104.196.202.240:17177" >> $confPath
	echo "addnode=35.200.247.198:17177" >> $confPath
	echo "addnode=35.198.82.29:17177" >> $confPath
	echo "addnode=35.200.22.69:17177" >> $confPath
	echo "addnode=35.201.14.20:17177" >> $confPath
	echo "addnode=35.198.23.18:17177" >> $confPath
	
	nohup $coinCommand &

	for i in {1..6}
	do
	   	sleep 600
		$coinCommand stop
		sleep 10
		nohup $coinCommand &
	done

		

else
	nohup $coinCommand &	

fi




