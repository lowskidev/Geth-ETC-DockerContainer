bakon-etcnode
Classic Ethereum Geth Node with etc-net-intelligence-api Docker Container

############################################################################################# 

**v.05** - build geth4.2.1 with sputnikVM

docker pull bakon3/etcnode:v.05 
############################################################################################# 

**v.04** - Updated to geth 4.2.1 Added --sputnikvm to geth run in gethStart.sh file(remove --sputnikvm for Morden Chain) 

docker pull bakon3/etcnode:v.04

New versions now compile GETH from source instead of downloading binary. This way, every time a new version of GETH, comes out instead of waiting for me to update my images you can build from dockerfile :).

############################################################################################# v.03 - Updated to geth 4.2.0 Added --sputnikvm to geth run in gethStart.sh file (Disable for Morden Chain) #############################################################################################

Using the classic go-ethereum client(https://github.com/ethereumproject/go-ethereum). This is a docker container that is designed so you could customize your geth run time before running the container, or even stop the container edit the geth run time and restart it.

This is done so you can use one image to create containers for Main or Morden chains. It also lets you setup custom port forwardings, and it includes (etc-net-intelligence-api)https://github.com/Machete3000/etc-net-intelligence-api/wiki.

This container is setup to use --mount method during docker run to use host persistent storage for chaindata.

How to use: After the container has finished building, before running it. In your Docker hosts $HOME Directory under mkdir -p ~/.ethereum-classic/<dockerGethContainerName> create a folder with the name for your Geth container instance.

In that folder create two files: touch startGeth.sh and touch process.json

And lets set the startGeth.sh to be executable with: chmod 755 startGeth.sh

These two files will be used to configure Geth before running the docker container and process.json to configure PM2 run time stats. ############################################################################################### example of startGeth.sh NOTE:If your running GETH on mordern disable or remove the --sputnikvm paramter till further notice, Thank you.

#!/bin/sh
#uncomment geth command that best fits your needs to start geth
#If you know what you're doing feel free to write your custom start geth commands here
###############################################################################################
#If you don't wish to use pm2 to report status to http://teststats.epool.io/ or  http://etcstats.net/ just comment it out
pm2 start /.ethereum-classic/process.json
###############################################################################################
#Start Geth on Morden chain and fast sync DO this first before you start with mining
geth --sputnikvm --chain=morden --fast --identity=<nameOfGethContainer> --rpc
###############################################################################################
#ONLY AFTER SYNC IS DONE Start Geth on the morden chain and start CPU mining with two threads to the test faucet
###############################################################################################
#geth --sputnikvm --chain=morden --identity=<nameOfGethContainer> --rpc --mine --minerthreads=2 --etherbase 0x2843c155c51494a684906e386120e8c2582dff5d
###############################################################################################
#Start Geth on Mainnet chain and fast sync - DO this first before you start with mining
#geth --sputnikvm --fast --identity=<nameOfGethContainer> --rpc
###############################################################################################
#ONLY AFTER SYNC IS DONE Start Geth on the Main chain and start CPU mining with two threads to the test faucet Usually for mainnet CPU mining is not recommended.
#geth --sputnikvm --identity=<nameOfGethContainer> --rpc --mine --minerthreads=2 --etherbase 0x0450f61ac77c50137b61fff46630eb36029d8dc1
###############################################################################################
#########################################################################################
Example of process.json to display stats on test server:

[
  {
    "name"              : "<Name of PM2 Session>",
    "cwd"               : "/root/www",
    "script"            : "app.js",
    "log_date_format"   : "YYYY-MM-DD HH:mm Z",
    "log_file"          : "logs/node-app-log.log",
    "out_file"          : "logs/node-app-out.log",
    "error_file"        : "logs/node-app-err.log",
    "merge_logs"        : false,
    "watch"             : false,
    "max_restarts"      : 10,
    "exec_interpreter"  : "node",
    "exec_mode"         : "fork_mode",
    "env":
    {
      "NODE_ENV"        : "development",
      "RPC_HOST"        : "localhost",
      "RPC_PORT"        : "8545",
      "LISTENING_PORT"  : "30303",
      "INSTANCE_NAME"   : "<Name to show on stats website>",
      "CONTACT_DETAILS" : "bakon",
      "WS_SERVER"       : "ws://teststats.epool.io/",//test server domain
      "WS_SECRET"       : "rockonetc",               //test server password  
      //"WS_SERVER"     : "ws://rpc.etcstats.net", //live server domain
      //"WS_SECRET"     : "5ceuMix4qSM6APj7QwTPU", //live server password
      "VERBOSITY"       : 2
    }
  }
]
######################################################################################### To run the container use you can also use this command instead of docker pull: docker run -tid --name <ContainerName> -p <tcpGethPort>:30303 -p <udpGethPort>:30303/udp -p <rpcPort>:8545 -p <wsPort>:8546 --mount type=bind,source=$HOME/.ethereum-classic/<nameOfNodeDirecotrory>,target=/.ethereum-classic/ bakon3/etcnode:v04

#########################################################################################

To see what Geth is doing in the container you have a two quick choices. You can either attach to the container and will show you direct out put of Geth, or you can use the docker exec -t <container Name> /bin/bash to actually connect to the container and browse it.

#########################################################################################

You can connect to the geth javascript console by either entering the container with geth exec and executing geth attach or geth --chain=morden attach for the test server.

To connect to a containers JS console from the Docker host. You can do so by navigating to the containers mounted directory ~/.ethereum-classic/<Foldername> and executing the command geth attach ipc:geth.ipc Note:You need to have Geth installed on your host machine as well
  
Donate ETC:0xc5bbf1ecdeba58013f17c6ede01aab73a17104a4
