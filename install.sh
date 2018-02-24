#!/bin/bash

echo -e '\e[92m###################################################################################################################################################'
echo -e 'This script is intended on helping you setup and run a GETH ETC Node in a Docker container '
echo -e 'This will allow you to easily and seperatly run multiple instances of the GETH ETC Node on one machine with specific ports'
echo -e '###################################################################################################################################################'
echo ''
echo -e '#################################################'
echo -e 'Are we installing Docker?'
echo -e '#################################################'
read -p 'yN: ' installingDocker

if [ $installingDocker = 'y' ]; then
	echo '#################################################'
	echo 'Installing Docker'
	echo -e '#################################################\e[0m'
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &&
	sudo apt-get update &&
	apt-cache policy docker-ce &&
	sudo apt-get install -y docker-ce make &&

	echo -e '\e[92m#################################################'
	echo 'Allow current user to use Docker without "sudo"'
	echo 'SSH Session restart will be needed'
	echo -e '#################################################\e[0m'
	sudo usermod -aG docker ${USER} &&

	
	echo -e '\e[92m##################################################################################################'
	echo 'Docker CE succesfully installed'
	echo -e '##################################################################################################\e[0m'
else
	echo -e '\e[92m##################################################################################################'
	echo 'Ommiting Docker Install'
	echo -e '##################################################################################################\e[0m'
	echo ''
fi
	
echo -e '\e[92m##################################################################################################'
echo 'Would you like to setup GETH ETC Node container from Docker HUB Image or build from Dockerfile?'
echo 'Chosing D will build from dockerfile, chosing I to build from Docker Hub Image'
echo -e '##################################################################################################\e[0m'
read -p 'd:Dockerfile or i:Docker Hub Image:d/I ' instType
	
if [ $instType = 'd' ]; then
    read -p 'Enter name for docker image: ' imageName
	sudo docker build -t ${imageName,,} .
else
	sudo docker pull bakon3/etcnode:v.08
fi

echo -e '\e[92m#################################################'
echo 'Would you like to run the container now?'
echo '#################################################'
read -p 'yN' runContainer

if [ $runContainer = 'y' ]; then
	echo '#################################################'
	echo 'Type in the name for your container'
	echo '#################################################'
	read -p 'Container Name: 'containerName

	echo '#################################################'
	echo 'Select port which the ETC will listen for connection default is 30303'
	echo '#################################################'
	read -p 'Container GETH Port: 'gethPort

	echo '#################################################'
	echo 'Select port where ETC will listen for RPC connections default is 8545'
	echo '#################################################'
	read -p 'Container GETH RPC Port: 'rpcPort

	echo '#################################################'
	echo 'Creating directorioes and startGeth.sh file'
	echo -e '#################################################\e[0m'	
	mkdir $HOME/.ethereum-classic/$containerName &&
	touch $HOME/.ethereum-classic/$containerName/startGeth.sh
	chmod 755 $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo '#!/bin/sh' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo '#uncomment geth command that best fits your needs to start geth' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo '#If you know what you are doing feel free to write your custom start geth commands here' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo '###############################################################################################' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo '#Start Geth fast sync DO this first before you start with mining' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo 'geth --sputnikvm --fast --identity=$containerName --rpc --maxpeers=55 --verbosity=6' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	
	if [ $instType = 'd ']; then
		sudo docker run -tid --name $containerName -p $gethPort:30303/tcp -p $rpcPort:8545/tcp --mount type=bind,source=$HOME/.ethereum-classic/$containerName,target=/.ethereum-classic/ $imageName
	else
		sudo docker run -tid --name $containerName -p $gethPort:30303/tcp -p $rpcPort:8545/tcp --mount type=bind,source=$HOME/.ethereum-classic/$containerName,target=/.ethereum-classic/ bakon3/etcnode:v.08
	fi
else
	echo -e '\e[92m##################################################################################################'
	echo 'If you decide to run the conatiner at a later time just run this installation script again.'
	echo -e '##################################################################################################\e[0m'
fi

