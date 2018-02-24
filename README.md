# bakon-Geth-ETC-DockerContainer
Docker Container containing - Classic Ethereum Geth Node Software compiled with latest version of SputnikVM

*NOTE*: This version only supports linux docker hosts, windows version coming soon.

Quickest way to spin up a container is:

On your linux box create a folder in you $home directory: 

`mkdir -p $HOME/.ethereum-classic/<dockerGethContainerName>`

Next cd into that directory:

`cd $HOME/.ethereum-classic/<dockerGethContainerName>`

Now we're going to clone this repo in the following way:

`git clone https://github.com/DialogueSolutions/bakon-Geth-ETC-DockerContainer.git ./`

Now you have two options:

1)Use the provided docker file and install to build the docker image for your conatiner or you can use:

**--Building the container from docker file:**
example: `docker build -t bakon3/etcnode:v.08 .`
**--Puilling image from docker hub:**
example: `docker pull bakon3/etcnode:v.08`

Right now the tags are versioned and no `latest` image has been created until release version.

Before executing `docker run` make sure you edit the paramteres in `startGeth.sh` and also make sure you `chmod` startGeth.sh to at least 755, `chmod 755 startGeth.sh`. 

Specify `--chain=<chainName>` and `--identity=<nameOfGethContainer>` and if you plan on accessing RPC remotly make sure you also specify allowed CORS with `--rpc-cors-domain="http://domain.com"`

Once you have that setup we can execute the container.

`docker run -tid --name <ContainerName> -p <tcpGethPort>:30303/tcp -p <rpcPort>:8545/tcp --mount type=bind,source=$HOME/.ethereum-classic/<nameOfNodeDirecotrory>,target=/.ethereum-classic/ bakon3/etcnode:v.08`

If everything was setup correctly you should see your contianer runnin with: `docker ps`
