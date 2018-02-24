#!/bin/sh

echo '###################################################################################################################################################'
echo 'This script is intended on helping you setup and run a GETH ETC Node in a Docker container '
echo 'This will allow you to easily and seperatly run multiple instances of the GETH ETC Node on one machine with specific ports'
echo '###################################################################################################################################################'

echo '#################################################'
echo 'Are we installing Docker?'
echo '#################################################'
read -p 'yes or no: ' installingDocker
if ['$installingDocker' = 'yes'] 
then
	echo '#################################################'
	echo 'Installing Docker'
	echo '#################################################'
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &&
	sudo apt-get update &&
	apt-cache policy docker-ce &&
	sudo apt-get install -y docker-ce make &&

	echo '#################################################'
	echo 'Allow current user to use Docker without "sudo"'
	echo 'REQUIRES SSH session logout + login'
	echo '#################################################'
	sudo usermod -aG docker ${USER} &&
	
	echo '##################################################################################################'
	echo 'Docker CE succesfully installed please restart your ssh session to use docker without SUDO'
	echo '##################################################################################################'
fi
	
echo '##################################################################################################'
echo 'Would you like to setup GETH ETC Node container from Docker HUB Image or build from Dockerfile?'
echo 'Chosing D will build from dockerfile, chosing I to build from Docker Hub Image'
echo '##################################################################################################'
read -p 'D:Dockerfile or I:Docker Hub Image: ' instType	
	
if ['$instType' = 'D']; then
    read -p 'Enter name for docker image: ' imageName
	docker build -t $imageName . &&
else
	docker pull bakon3/etcnode:v.08  &&
fi

echo '#################################################'
echo 'Would you like to run the container now?'
echo '#################################################'
read -p 'Run Container?:y or n 'runContainer

if ['$runContainer' = 'y']
then
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
	echo '#################################################'	
	mkdir $HOME/.ethereum-classic/$containerName &&
	touch $HOME/.ethereum-classic/$containerName/startGeth.sh
	chmod 755 $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo '#!/bin/sh' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo '#uncomment geth command that best fits your needs to start geth' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo '#If you know what you are doing feel free to write your custom start geth commands here' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo '###############################################################################################' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo '#Start Geth fast sync DO this first before you start with mining' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo 'geth --sputnikvm --fast --identity=$containerName --rpc --maxpeers=55 --verbosity=6' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	
	if ['$instType' = 'D'] 
	then
		docker run -tid --name $containerName -p $gethPort:30303/tcp -p $rpcPort:8545/tcp --mount type=bind,source=$HOME/.ethereum-classic/$containerName,target=/.ethereum-classic/ $imageName
	else
		docker run -tid --name $containerName -p $gethPort:30303/tcp -p $rpcPort:8545/tcp --mount type=bind,source=$HOME/.ethereum-classic/$containerName,target=/.ethereum-classic/ bakon3/etcnode:v.08
	fi
else
	echo '##################################################################################################'
	echo 'If you decide to run the conatiner at a later time just run this installation script again.'
	echo '##################################################################################################'
fi
