#!/bin/bash

echo -e '\e[92m###################################################################################################################################################'
echo -e 'This script is intended on helping you setup and run a GETH ETC Node in a Docker container '
echo -e 'This will allow you to easily and seperatly run multiple instances of the GETH ETC Node on one machine with specific ports'
echo -e '###################################################################################################################################################'
echo ''
echo -e '#################################################'
echo -e 'Are we installing Docker?:yN'
echo -e '#################################################'
echo ''
read installingDocker
echo ''
if [ $installingDocker = 'y' ]; then
	echo '#################################################'
	echo 'Installing Docker'
	echo -e '#################################################\e[0m'
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &&
	sudo apt-get update &&
	apt-cache policy docker-ce &&
	sudo apt-get install -y docker-ce make &&
	echo ''
	echo -e '\e[92m#################################################'
	echo 'Allow current user to use Docker without "sudo"'
	echo 'SSH Session restart will be needed'
	echo -e '#################################################\e[0m'
	sudo usermod -aG docker ${USER}
	echo ''	
	echo -e '\e[92m##################################################################################################'
	echo 'Docker CE succesfully installed'
	echo -e '##################################################################################################\e[0m'
else
	echo ''
	echo -e '\e[92m##################################################################################################'
	echo 'Ommiting Docker Install'
	echo -e '##################################################################################################\e[0m'
	echo ''
fi	
echo -e '\e[92m##################################################################################################'
echo 'Would you like to setup GETH ETC Node container from Docker HUB Image or build from Dockerfile?'
echo 'Chosing "d" will build from dockerfile, chosing "i" will build from Docker Hub Image(Much Faster)'
echo -e '##################################################################################################\e[0m'
echo ''
read instType	
if [ $instType = 'd' ]; then
    read -p 'Enter name for docker image: ' imageName
	sudo docker build -t ${imageName,,} .
else
	sudo docker pull bakon3/etcnode:v.08
fi
echo -e '\e[92m##################################################################################################'
echo 'Would you like to run the container now?yN'
echo '##################################################################################################'
read runContainer
if [ $runContainer = 'y' ]; then
	echo '##################################################################################################'
	echo 'Type in the name for your container'
	echo '##################################################################################################'
	read -p 'Container Name: ' containerName
	echo ''
	echo '##################################################################################################'
	echo 'Select port on which GETH will listen for peers, port should be 4 - 6 digits long'
	echo '##################################################################################################'
	read -p 'Container GETH Port: ' gethPort
	echo ''
	echo '##################################################################################################'
	echo 'Select port on which GETH will listen for RPC connections, port should be 4 - 6 digits long'
	echo '##################################################################################################'
	read -p 'Container GETH RPC Port: ' rpcPort
	echo ''
	echo '##################################################################################################'
	echo 'Creating directorioes and startGeth.sh file'
	echo -e '##################################################################################################\e[0m'		
	mkdir -pv $HOME/.ethereum-classic/$containerName &&
	touch $HOME/.ethereum-classic/$containerName/startGeth.sh
	chmod 755 $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	#Create startGeth File
	echo '#!/bin/sh' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo '#If you know what you are doing feel free to write your custom start geth commands here' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo '###############################################################################################' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo '' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo '#Start Geth' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo 'geth --sputnikvm --fast --identity='$containerName' --rpc --maxpeers=55 --verbosity=6' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo ''
	echo -e '\e[92m#################################################'
	echo 'Starting Container'
	echo -e '#################################################\e[0m'
	if [ $instType = 'd' ]; then
		sudo docker run -tid --name $containerName -p $gethPort:30303/tcp -p $rpcPort:8545/tcp --mount type=bind,source=$HOME/.ethereum-classic/$containerName,target=/.ethereum-classic/ $imageName
	else
		sudo docker run -tid --name $containerName -p $gethPort:30303/tcp -p $rpcPort:8545/tcp --mount type=bind,source=$HOME/.ethereum-classic/$containerName,target=/.ethereum-classic/ bakon3/etcnode:v.08
	fi
	echo -e '\e[92m##################################################################################################'
	echo 'The container has been starterd. you can use sudo docker attach ' $containerName ' to view status'
	echo -e '##################################################################################################\e[0m'
	sudo docker ps
else
	echo -e '\e[92m##################################################################################################'
	echo 'If you decide to run the conatiner at a later time just run this installation script again.'
	echo -e '##################################################################################################\e[0m'
fi

