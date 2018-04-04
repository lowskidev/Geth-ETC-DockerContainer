# Geth-ETC-DockerContainer
Docker Container containing - Classic Ethereum Geth Node Software compiled with latest version of SputnikVM

**You do not have to have Docker installed, the included *install.sh* in this repo will guide you through the install of latest Docker if needed, on both Ubuntu 16.04 and CentOS7**

```
**Ethereum Go (Ethereum Classic Blockchain)**

*Official Go language implementation of the Ethereum protocol supporting the original chain. 
Ethereum Classic (ETC) offers a censorship-resistant and powerful application platform for 
developers in parallel to Ethereum (ETHF), while differentially rejecting the DAO bailout.*
```

*NOTE*: This version only supports linux docker hosts, windows version coming soon.

**Quickest way to spin up a container is:**

`git clone https://github.com/DialogueSolutions/Geth-ETC-DockerContainer.git`

`cd Geth-ETC-DockerContainer`

`./install.sh`

Follow the promps on the screen and you should have a running container in no time.
For quicker setup use the option to build container from *Docker Hub* other wise it'll build a whole image from the dockerfile.

This is the first version. If you encounter any errors during the installation, especially when docker is spining up the container. It's usually something you can easily fix with whatever answers you gave to the promps.

You can easily just restart the `install.sh` and continue on pretty much from where you left off.

If for any reason you need to remove the container with `docker rm containerName`
Next time you run install.sh and reuse the same container name you did before you will not lose any sycned data.

#############################################################################################

**USE The below instructions to manualy set everyhting up**

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
#############################################################################################

**Feel free to support this development. :)**
ETC: 0x0450f61AC77C50137B61fff46630eb36029d8dC1
