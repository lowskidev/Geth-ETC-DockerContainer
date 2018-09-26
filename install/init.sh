#!/bin/sh
apt update -y &&
apt upgrade -y &&
apt install -y build-essential &&
apt install -y git wget curl nano redis-server nginx software-properties-common python-software-properties rustc cargo &&

#Install latest nodejs
echo -e '\e[92m#################################################'
echo -e 'Installing latest NodeJS'
echo -e '#################################################\e[0m'
curl -sL https://deb.nodesource.com/setup_9.x | bash - &&
apt install -y nodejs &&

#Install latest golang on Ubuntu
add-apt-repository -y ppa:longsleep/golang-backports &&
apt update -y &&
apt install -y golang-go &&
export GOPATH=$HOME/go &&

#Download GETH Source
echo -e '\e[92m#################################################'
echo 'Download Latest GETH version from source'
echo -e '#################################################\e[0m'
cd $HOME/ &&
go get -v github.com/ethereumproject/go-ethereum/... &&

#Build geth with sputnikvm
echo -e '\e[92m#################################################'
echo 'Building GETH with SputnikVM'
echo -e '#################################################\e[0m'
cd $HOME/go/src/github.com/ethereumproject/go-ethereum/ &&
make cmd/geth &&

#copy geth runtime to bin folder
echo -e '\e[92m#################################################'
echo 'Copying GETH to bin'
echo -e '#################################################\e[0m'
cp bin/geth /usr/local/bin/ &&

#Cloning Netstats API
echo -e '\e[92m#################################################'
echo 'Cloning Netstats API and installing PM2'
echo -e '#################################################\e[0m'
#install latest PM2 and etc-net-intelligence-api
cd $HOME &&
git clone https://github.com/ethernodeio/etc-net-intelligence-api.git etc-net-intelligence-api &&
cd etc-net-intelligence-api &&
npm install &&
npm install pm2 -g &&

#Clean up
echo -e '\e[92m#################################################'
echo 'Cleaning up Image after install'
echo -e '#################################################\e[0m'
apt clean &&
rm -rf $HOME/go/