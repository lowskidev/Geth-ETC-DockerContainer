#!/bin/bash
#Functions
function installDocker(){
	#Ask if docker is Ubuntu or CentOs
	echo -e '\e[92m###################################################################################################################################################'
	echo -e 'Install docker for Ubuntu or CentOs?:U/C'
	echo -e '###################################################################################################################################################\e[0m'	
	read -n 1 osType
	if [[ $osType == 'u' ]]; then
		echo -e '\e[92m###################################################################################################################################################'
		echo 'Installing Docker for Ubuntu'
		echo -e '###################################################################################################################################################\e[0m'
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
		sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &&
		sudo apt-get update &&
		apt-cache policy docker-ce &&
		sudo apt-get install -y docker-ce make &&
		echo
		echo -e '\e[92m###################################################################################################################################################'
		echo 'Allow current user to use Docker without "sudo"'
		echo 'SSH Session restart will be needed'
		echo -e '###################################################################################################################################################\e[0m'
		sudo usermod -aG docker ${USER}
		echo
		echo -e '\e[92m###################################################################################################################################################'
		echo 'Docker CE succesfully installed'
		echo -e '###################################################################################################################################################\e[0m'
	elif [[ $osType == 'c' ]]; then
		echo -e '\e[92m###################################################################################################################################################'
		echo 'Installing Docker for CentOs 7'
		echo -e '###################################################################################################################################################\e[0m'
		sudo yum install -y yum-utils \
			 device-mapper-persistent-data \
			 lvm2 && 
		sudo yum-config-manager \
			--add-repo \
			https://download.docker.com/linux/centos/docker-ce.repo
		sudo yum -y install docker-ce &&
		sudo systemctl enable docker &&
		sudo systemctl start docker &&
		sudo groupadd docker &&
		sudo usermod -aG docker $USER
		echo
		echo -e '\e[92m###################################################################################################################################################'
		echo 'Docker CE succesfully installed'
		echo -e '###################################################################################################################################################\e[0m'
	else
		installDocker
	fi
}
function buildImage(){
	if [[ $instType == 'd' ]]; then
		read -p 'Enter name for docker image: ' imageName
		sudo docker build -t ${imageName,,} .
	else
		sudo docker pull bakon3/etcnode:v.08
		imageName = 'bakon3/etcnode:v.08'
	fi
	echo -e '\e[92m###################################################################################################################################################'
	echo 'Image ' imageName 'has been created'
	echo -e '###################################################################################################################################################\e[0m'
}
function startContainer(){
	echo -e '\e[92m###################################################################################################################################################'
	echo 'Type in the name for your container'
	echo -e '###################################################################################################################################################\e[0m'
	read -p 'Container Name: ' containerName
	echo
	echo -e '\e[92m###################################################################################################################################################'
	echo 'Select port on which GETH will listen for peers, port should be 4 - 5 digits long'
	echo '1-65535 are available, and ports in range 1-1023 are the privileged ones so dont use them'
	echo -e '###################################################################################################################################################\e[0m'
	read -p 'Container GETH Port: ' gethPort
	echo
	echo -e '\e[92m###################################################################################################################################################'
	echo 'Select port on which GETH will listen for RPC connections, port should be 4 - 5 digits long'
	echo '1-65535 are available, and ports in range 1-1023 are the privileged ones so dont use them'
	echo -e '###################################################################################################################################################\e[0m'
	read -p 'Container GETH RPC Port: ' rpcPort
	echo
	echo -e '\e[92m###################################################################################################################################################'
	echo 'Creating directorioes and startGeth.sh file'
	echo -e '###################################################################################################################################################\e[0m'
	mkdir -pv $HOME/.ethereum-classic/$containerName &&
	touch $HOME/.ethereum-classic/$containerName/startGeth.sh
	chmod 755 $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	#Create startGeth File
	echo '#!/bin/sh' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo '#If you know what you are doing feel free to write your custom start geth commands here' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo '###############################################################################################' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo '' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo '#Start Geth' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo 'geth --sputnikvm --fast --identity='$containerName' --rpc --cache=1024 --rpcaddr=0.0.0.0 --rpccorsdomain="*" --maxpeers=55 --verbosity=6' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo
	echo -e '\e[92m#################################################'
	echo 'Starting Container'
	echo -e '#################################################\e[0m'
	if [[ $instType == 'd' ]]; then
		sudo docker run -tid --name $containerName -p $gethPort:30303/tcp -p $gethPort:30303/udp -p $rpcPort:8545/tcp --mount type=bind,source=$HOME/.ethereum-classic/$containerName,target=/.ethereum-classic/ ${imageName,,}
	else
		sudo docker run -tid --name $containerName -p $gethPort:30303/tcp -p $gethPort:30303/udp -p $rpcPort:8545/tcp --mount type=bind,source=$HOME/.ethereum-classic/$containerName,target=/.ethereum-classic/ bakon3/etcnode:v.08
	fi

	echo -e '\e[92m###################################################################################################################################################'
	echo 'If you received an error about docker starting at this point, Just correct the inputs it has an issue with and run ./install.sh again.'
	echo 'Other wise if you see your container running you can attach to it by running docker attach '$containerName 
	echo 'If for any reason you need to remove the container with docker rm '$containerName
	echo 'Next time you run install.sh and re use the same container name you did before you will not lose any sycned data.'
	echo -e '###################################################################################################################################################\e[0m'
	sudo docker ps
}
echo -e '\e[92m###################################################################################################################################################'
echo -e 'This script is intended on helping you setup and run a GETH ETC Node in a Docker container '
echo -e 'This will allow you to easily and seperatly run multiple instances of the GETH ETC Node on one machine with specific ports'
echo -e '###################################################################################################################################################\e[0m'
echo
#Ask if user wants to install docker
echo -e '\e[92m###################################################################################################################################################'
echo -e 'Are we installing Docker?:yN'
echo -e '###################################################################################################################################################\e[0m'
read -n 1 installingDocker
if [[ $installingDocker == 'y' ]]; then
	installDocker
else
	echo
	echo -e '\e[92m###################################################################################################################################################'
	echo 'Ommiting Docker Install'
	echo -e '###################################################################################################################################################\e[0m'
	echo
fi
#Ask how to create image for container
echo -e '\e[92m###################################################################################################################################################'
echo 'Would you like to setup GETH ETC Node container from Docker HUB Image or build from Dockerfile?'
echo 'Chosing "d" will build from dockerfile, chosing "i" will build from Docker Hub Image(Much Faster)'
echo -e '###################################################################################################################################################\e[0m'
read -n 1 instType
buildImage
#Run Container
echo -e '\e[92m###################################################################################################################################################'
echo 'Would you like to run the container now? "yN"'
echo -e '###################################################################################################################################################\e[0m'
read -n 1 runContainer
if [[ $runContainer == 'y' ]]; then
	startContainer
else
	echo -e '\e[92m###################################################################################################################################################'
	echo 'If you decide to run the conatiner at a later time just run this installation script again, and use the same image name as before'
	echo -e '###################################################################################################################################################\e[0m'
fi
