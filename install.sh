#!/bin/bash
#Functions
function installDocker(){
	#Ask if user wants to install docker
	echo -e '\e[92m###################################################################################################################################################'
	echo -e 'Are we installing Docker?:yN'
	echo -e '###################################################################################################################################################\e[0m'
	read -n 1 installingDocker
	if [[ $installingDocker == 'y' ]]; then
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
			echo -e '\e[92m###################################################################################################################################################'
			echo 'Please Chose your Docker OS installation'
			echo -e '###################################################################################################################################################\e[0m'
			installDocker
		fi
	else
		echo -e '\e[92m###################################################################################################################################################'
		echo 'Skipping Docker Install'
		echo -e '###################################################################################################################################################\e[0m'
	fi
}
function buildImage(){
#Ask how to create image for container
echo -e '\e[92m###################################################################################################################################################'
	echo 'Please select how you would like to build the image'
	echo '"d" build image from dockerfile, "i" build image from Docker Hub Image(Much Faster)'
	echo -e '###################################################################################################################################################\e[0m'
	read -n 1 instType
	if [[ $instType == 'd' ]]; then
		read -p 'Enter name for docker image: ' imageName
		sudo docker build -t ${imageName,,} .
		echo -e '\e[92m###################################################################################################################################################'
		echo 'Image '${imageName,,}' has been created'
		echo -e '###################################################################################################################################################\e[0m'
	elif [[ $instType == 'i' ]]; then
		sudo docker pull bakon3/etcnode
		echo -e '\e[92m###################################################################################################################################################'
		echo 'Image bakon3/etcnode has been pulled'
		echo -e '###################################################################################################################################################\e[0m'
	else
		buildImage
	fi
}
function selectChain(){
	echo -e '\e[92m###################################################################################################################################################'
	echo 'Will this be a Mainnet or Morden(Test) node?'
	echo 'Default: Mainnet.'
	echo -e '###################################################################################################################################################\e[0m'
	read -p 'Mainenet or Morden?:mainnet/morden ' chain
	if [[ $chain != 'morden' ]]; then
		chain='mainnet'
	fi
	echo $chain
}
function setupDiecoveryPort(){
	echo -e '\e[92m###################################################################################################################################################'
	echo 'Select wich port will to expose for GETH 30303, port should be 4 - 5 digits long'
	echo 'Ports in range 1-1023 are the privileged ones so dont use them 1-65535 are available.'
	echo 'Default Discovery port for GETH is 30303'
	echo 'PLEASE USE INTEGERS ONLY'
	echo -e '###################################################################################################################################################\e[0m'
	read -p 'Container GETH Port: ' gethPort
	if ! [[ "$gethPort" =~ ^[0-9]+$ ]]; then
		setupPorts
	fi
	echo $gethPort
}
function setupRPC(){
	echo -e '\e[92m###################################################################################################################################################'
	echo 'Would you like to expose the RPC port(8545 default) on the container?'
	echo 'Exposing this PORT will give you access to the RPC end point of GETH inside that container'
	echo -e '###################################################################################################################################################\e[0m'
	read -p 'Expose RPC Port y/N?: ' exposeRPC
		if [[ $exposeRPC == 'y' ]]; then
			echo -e '\e[92m###################################################################################################################################################'
			echo 'Select wich port # to expose'
			echo 'Ports in range 1-1023 are the privileged ones so dont use them 1-65535 are available.'
			echo 'Default port is 8545'
			echo 'PLEASE USE INTEGERS ONLY'
			echo -e '###################################################################################################################################################\e[0m'
			read -p 'Container GETH Port: ' rpcPort
			if ! [[ "$rpcPort" =~ ^[0-9]+$ ]]; then
				setupRPC
			fi
			echo $rpcPort
			echo
			echo -e '\e[92m###################################################################################################################################################'
			echo 'Would you like to setup CORS for the RPC API endpoint?Leave blank do disable CORS'
			echo 'This allows you to remotely connect to the NODEs RPC API'
			echo 'Default will not setup CORS and NODE RPC Wont be available outside of the container if field left blank.'
			echo 'You can use "*" to set up wild card CORS'
			echo 'LEAVE BLANK TO DISABLE CORS'
			echo -e '###################################################################################################################################################\e[0m'
			read -p 'CORS Access: ' CORS
			if [[ $CORS == '' ]]; then
				CORS='false'
			fi
	    else
			echo -e '\e[92m###################################################################################################################################################'
			echo 'RPC Port will not be EXPOSED' 
			echo -e '###################################################################################################################################################\e[0m'
		fi
}
function createDirectories(){
	echo -e '\e[92m###################################################################################################################################################'
	echo 'Creating directorioes, startGeth.sh, app.json for netstats api file'
	echo -e '###################################################################################################################################################\e[0m'
	mkdir -pv $HOME/.ethereum-classic/$containerName &&
	rm $HOME/.ethereum-classic/$containerName/startGeth.sh
	touch $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	chmod 755 $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	rm $HOME/.ethereum-classic/$containerName/app.json &&
	touch $HOME/.ethereum-classic/$containerName/app.json
}
function createStartGeth(){
	#Declare morden boot nodes.
	#mordenBootnodes='--bootnodes enode://1fac84e8fe252d63764563f4f526323393b52aaaf832693f7a8a1637f6920311d7d04a7cb91945273e6c644d5c3b01a6bf8a172ae653c918e1bf8eb79e7e6baf@94.152.212.32:40404,enode://2ebc9ab101ec8bb98ec114792fe28e85dea1daf9213b5425ada2619bf3d2f860481cf77e0c222b60e3ab37935c5258385843a7ef0f232081177280ea02e45c8b@144.202.111.197:30303'
	#Create startGeth File
	echo '#!/bin/sh' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo '#If you know what you are doing feel free to write your custom start geth commands here' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo '###############################################################################################' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	#Start Netstats with PM2
	echo 'cd $HOME/etc-net-intelligence-api &&' 	>> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo 'pm2 start /.ethereum-classic/app.json &&'	>> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo '###############################################################################################' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	echo '' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&
	#Start Geth
	echo '#Start Geth' >> $HOME/.ethereum-classic/$containerName/startGeth.sh &&    
	if [[ $exposeRPC == 'y' ]]; then 
		echo 'geth --chain='$chain' --sputnikvm --fast --identity='$containerName' --cache=1024 --rpc --rpcaddr=0.0.0.0 --rpccorsdomain='$CORS' --maxpeers=55 --verbosity=6 ' >> $HOME/.ethereum-classic/$containerName/startGeth.sh
	else
		echo 'geth --chain='$chain' --sputnikvm --fast --identity='$containerName' --cache=1024 --rpc --maxpeers=55 --verbosity=6 ' $ >> $HOME/.ethereum-classic/$containerName/startGeth.sh
	fi
}
function createAppJSON(){
	if [[ $chain == 'morden' ]]; then
		echo -e '\e[92m###################################################################################################################################################'
		echo 'Creating app.json files' 
		echo -e '###################################################################################################################################################\e[0m'
		echo '[' 								>>  $HOME/.ethereum-classic/$containerName/app.json
		echo  '{' 								>>  $HOME/.ethereum-classic/$containerName/app.json 	
		echo    '"name"              : "etc-netstats-api",' 			>>  $HOME/.ethereum-classic/$containerName/app.json
		echo    '"script"            : "/root/etc-net-intelligence-api/app.js",'	>>  $HOME/.ethereum-classic/$containerName/app.json
		echo    '"log_date_format"   : "YYYY-MM-DD HH:mm Z",' 			>>  $HOME/.ethereum-classic/$containerName/app.json
		echo    '"merge_logs"        : false,' 					>>  $HOME/.ethereum-classic/$containerName/app.json
		echo    '"watch"             : false,' 					>>  $HOME/.ethereum-classic/$containerName/app.json
		echo    '"max_restarts"      : 10,' 					>>  $HOME/.ethereum-classic/$containerName/app.json
		echo    '"exec_interpreter"  : "node",' 				>>  $HOME/.ethereum-classic/$containerName/app.json
		echo    '"exec_mode"         : "fork_mode",' 				>>  $HOME/.ethereum-classic/$containerName/app.json
		echo    '"env":' 							>>  $HOME/.ethereum-classic/$containerName/app.json
		echo    '{' 								>>  $HOME/.ethereum-classic/$containerName/app.json
		echo      '"NODE_ENV"        : "production",'				>>  $HOME/.ethereum-classic/$containerName/app.json
		echo      '"RPC_HOST"        : "localhost",'				>>  $HOME/.ethereum-classic/$containerName/app.json
		echo      '"RPC_PORT"        : "8545",'					>>  $HOME/.ethereum-classic/$containerName/app.json
		echo      '"LISTENING_PORT"  : "30303",'				>>  $HOME/.ethereum-classic/$containerName/app.json
		echo      '"INSTANCE_NAME"   : "'$containerName'",'			>>  $HOME/.ethereum-classic/$containerName/app.json
		echo      '"CONTACT_DETAILS" : "",'					>>  $HOME/.ethereum-classic/$containerName/app.json
		echo      '"WS_SERVER"       : "mordenstats.ethertrack.io",'		>>  $HOME/.ethereum-classic/$containerName/app.json
		echo      '"WS_SECRET"       : "crazyBakon",'				>>  $HOME/.ethereum-classic/$containerName/app.json
		echo      '"VERBOSITY"       : 2'					>>  $HOME/.ethereum-classic/$containerName/app.json
		echo    '}'								>>  $HOME/.ethereum-classic/$containerName/app.json
		echo  '}'								>>  $HOME/.ethereum-classic/$containerName/app.json
		echo ']'								>>  $HOME/.ethereum-classic/$containerName/app.json
	else
		echo -e '\e[92m###################################################################################################################################################'
		echo 'Creating app.json files' 
		echo -e '###################################################################################################################################################\e[0m'
		echo '[' 								>>  $HOME/.ethereum-classic/$containerName/app.json
		echo  '{' 								>>  $HOME/.ethereum-classic/$containerName/app.json 	
		echo    '"script"            : "/root/etc-net-intelligence-api/app.js",' 	>>  $HOME/.ethereum-classic/$containerName/app.json
		echo    '"script"            : "app.js",'			 	>>  $HOME/.ethereum-classic/$containerName/app.json
		echo    '"log_date_format"   : "YYYY-MM-DD HH:mm Z",' 			>>  $HOME/.ethereum-classic/$containerName/app.json
		echo    '"merge_logs"        : false,' 					>>  $HOME/.ethereum-classic/$containerName/app.json
		echo    '"watch"             : false,' 					>>  $HOME/.ethereum-classic/$containerName/app.json
		echo    '"max_restarts"      : 10,' 					>>  $HOME/.ethereum-classic/$containerName/app.json
		echo    '"exec_interpreter"  : "node",' 				>>  $HOME/.ethereum-classic/$containerName/app.json
		echo    '"exec_mode"         : "fork_mode",' 				>>  $HOME/.ethereum-classic/$containerName/app.json
		echo    '"env":' 							>>  $HOME/.ethereum-classic/$containerName/app.json
		echo    '{' 								>>  $HOME/.ethereum-classic/$containerName/app.json
		echo      '"NODE_ENV"        : "production",'				>>  $HOME/.ethereum-classic/$containerName/app.json
		echo      '"RPC_HOST"        : "localhost",'				>>  $HOME/.ethereum-classic/$containerName/app.json
		echo      '"RPC_PORT"        : "8545",'					>>  $HOME/.ethereum-classic/$containerName/app.json
		echo      '"LISTENING_PORT"  : "30303",'				>>  $HOME/.ethereum-classic/$containerName/app.json
		echo      '"INSTANCE_NAME"   : "'$containerName'",'			>>  $HOME/.ethereum-classic/$containerName/app.json
		echo      '"CONTACT_DETAILS" : "",'					>>  $HOME/.ethereum-classic/$containerName/app.json
		echo      '"WS_SERVER"       : "etcstats.ethertrack.io",'		>>  $HOME/.ethereum-classic/$containerName/app.json
		echo      '"WS_SECRET"       : "crazyBakon",'				>>  $HOME/.ethereum-classic/$containerName/app.json
		echo      '"VERBOSITY"       : 2'					>>  $HOME/.ethereum-classic/$containerName/app.json
		echo    '}'								>>  $HOME/.ethereum-classic/$containerName/app.json
		echo  '}'								>>  $HOME/.ethereum-classic/$containerName/app.json
		echo ']'								>>  $HOME/.ethereum-classic/$containerName/app.json
	fi
}
function dockerRUN(){
	if [[ $chain == 'morden' ]]; then
		echo -e '\e[92m###################################################################################################################################################'
		echo 'Since you are running the Morden Chain Container you can view its stats on'
		echo 'http://mordenstats.ethertrack.io/ just look for your container Name: '$containerName
		echo -e '###################################################################################################################################################\e[0m'
	fi
	sleep 5
	echo
	echo -e '\e[92m###################################################################################################################################################'
	echo 'CONTAINER NETWORK INFORMATION'
	echo 'Container External IP Address: '$wanip
	echo 'Container Local IP Address: '$lanip
	echo 'Container Discovery Port: '$gethPort
	echo 'Container RPC API Port: '$rpcPort
	echo -e '###################################################################################################################################################\e[0m'
	sleep 5
	echo -e '\e[92m###################################################################################################################################################'
	echo 'Your new Container ' $containerName ' for the network ' $chain ' is about to be launched'
	echo 'THANK YOU FOR SUPPORTING THE ETHEREUM CLASSIC NETWORK'
	echo -e '###################################################################################################################################################\e[0m'
	sleep 5
	echo -e '\e[92m###################################################################################################################################################'
	echo 'Starting Container in attached mode.'
	echo 'Press CTRL-Q and CTRL-P at the same time to exit without shutting off the container'
	echo -e '###################################################################################################################################################\e[0m'
	sleep 5
	#Run the container based on above setup
	if [[ $instType == 'd' ]]; then
		if [[ $exposeRPC == 'y' ]]; then
			sudo docker run -ti --name $containerName --restart unless-stopped -p $gethPort:30303/tcp -p $gethPort:30303/udp -p $rpcPort:8545/tcp --mount type=bind,source=$HOME/.ethereum-classic/$containerName,target=/.ethereum-classic/ ${imageName,,}
		else
			sudo docker run -ti --name $containerName --restart unless-stopped -p $gethPort:30303/tcp -p $gethPort:30303/udp --mount type=bind,source=$HOME/.ethereum-classic/$containerName,target=/.ethereum-classic/ ${imageName,,}
		fi
	else
		if [[ $exposeRPC == 'y' ]]; then
			sudo docker run -ti --name $containerName --restart unless-stopped -p $gethPort:30303/tcp -p $gethPort:30303/udp -p $rpcPort:8545/tcp --mount type=bind,source=$HOME/.ethereum-classic/$containerName,target=/.ethereum-classic/ bakon3/etcnode
		else
			sudo docker run -ti --name $containerName --restart unless-stopped -p $gethPort:30303/tcp -p $gethPort:30303/udp --mount type=bind,source=$HOME/.ethereum-classic/$containerName,target=/.ethereum-classic/ bakon3/etcnode
		fi
	fi	
}
function startContainer(){
	echo -e '\e[92m###################################################################################################################################################'
	echo 'Would you like to run the container now? "yN"'
	echo -e '###################################################################################################################################################\e[0m'
	read -n 1 runContainer
	if [[ $runContainer == 'y' ]]; then
		echo -e '\e[92m###################################################################################################################################################'
		echo 'Type in the name for your container'
		echo -e '###################################################################################################################################################\e[0m'
		read -p 'Container Name: ' containerName
		echo
		setupDiecoveryPort
		echo
		setupRPC
		echo
		selectChain
		echo
		createDirectories
		echo
		createAppJSON
		echo
		createStartGeth
		echo
		dockerRUN
		echo
		echo -e '\e[92m###################################################################################################################################################'
		echo 'If you received an error about docker starting at this point, Just correct the inputs it has an issue with and run ./install.sh again.'
		echo 'Otherwise if you see your container running you can re-attach to it by running docker attach '$containerName 
		echo 'If for any reason you need to remove the container with docker rm '$containerName
		echo 'Next time you run install.sh and reuse the same container name you did before and you will not lose any sycned blockchain data.'
		echo -e '###################################################################################################################################################\e[0m'
		sudo docker ps
		echo
	else
		echo -e '\e[92m###################################################################################################################################################'
		echo 'If you got to this point you should already have an image build. You can check your images by typing in "sudo docker images"'
		echo 'If you already have a docker image build from previously running instlall.sh'
		echo 'You can just skip straight to running a new container'
		echo -e '###################################################################################################################################################\e[0m'
	fi
}
#Get Container IP
wanip=$(dig +short myip.opendns.com @resolver1.opendns.com)
lanip=$(hostname -I | head -n1 | cut -d " " -f1)
#Start Input
echo -e '\e[92m###################################################################################################################################################'
echo -e 'This script is intended on helping you setup and run a GETH ETC Node in a Docker container '
echo -e 'This will allow you to easily and seperatly run multiple instances of the GETH ETC Node on one machine with specific ports'
echo 'If you got to this point you should already have n image build. You can check your images by typing in "sudo docker images"'
echo 'If you already have a docker image build from previously running this instlall.sh'
echo 'You can just skip straight to running a new container'
echo -e '###################################################################################################################################################\e[0m'
echo
#Ask if user wants to install docker
echo -e '\e[92m###################################################################################################################################################'
echo -e 'DETECT DOCKER INSTALL'
echo -e '###################################################################################################################################################\e[0m'
installDocker
#Ask how to create image for container
echo -e '\e[92m###################################################################################################################################################'
echo 'STARTING DOCKER IMAGE CREATION'
echo -e '###################################################################################################################################################\e[0m'
buildImage
#Run Container
echo -e '\e[92m###################################################################################################################################################'
echo 'SPINNING UP NEW CONTAINER'
echo -e '###################################################################################################################################################\e[0m'
startContainer
