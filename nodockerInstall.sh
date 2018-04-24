sudo !#/bin/bash

#Update everything before isntalling any extra repositories or packages
sudo apt-get update -y &&
sudo apt-get upgrade -y &&
sudo apt-get install -y build-essential &&
sudo apt-get install -y git wget curl nano redis-server nginx software-properties-common python-software-properties rustc cargo apt-transport-https &&

#Install latest golang on Ubuntu
sudo add-apt-repository -y ppa:longsleep/golang-backports &&
sudo apt-get update -y &&
sudo apt-get install -y golang-go &&
export GOPATH=$HOME/go &&

Download GETH Source
echo -e '\e[92m#################################################'
echo 'Download Latest GETH version from source'
echo -e '#################################################\e[0m'
cd $HOME/ &&
go get -v github.com/ethereumproject/go-ethereum/... &&

#Download sputnikvm build files
echo -e '\e[92m#################################################'
echo 'Download Latest sputnikVM version from source'
echo -e '#################################################\e[0m'
cd $HOME/go/src/github.com/ethereumproject/ &&
git clone https://github.com/ethereumproject/sputnikvm-ffi &&
cd sputnikvm-ffi/c/ffi &&

#Build sputnikvm
echo -e '\e[92m#################################################'
echo 'Building sputnikVM'
echo -e '#################################################\e[0m'
cargo build --release &&
cp $HOME/go/src/github.com/ethereumproject/sputnikvm-ffi/c/ffi/target/release/libsputnikvm_ffi.a $HOME/go/src/github.com/ethereumproject/sputnikvm-ffi/c/libsputnikvm.a &&

#Build geth with sputnikvm
echo -e '\e[92m#################################################'
echo 'Building GETH with SputnikVM'
echo -e '#################################################\e[0m'
cd $HOME/go/src/github.com/ethereumproject/go-ethereum/cmd/geth &&
CGO_LDFLAGS="$HOME/go/src/github.com/ethereumproject/sputnikvm-ffi/c/libsputnikvm.a -ldl" go build -tags=sputnikvm . &&

#copy geth runtime to bin folder
echo -e '\e[92m#################################################'
echo 'Copying GETH to bin'
echo -e '#################################################\e[0m'
sudo cp geth /usr/local/bin/ &&

#Instruction
echo -e '\e[92m#################################################'
echo 'You should now be able to launch GETH Example:'
echo 'geth --sputnikvm --fast --chain=morden --identity=NameOfNode --cache=1024 --rpc --rpcaddr=0.0.0.0 --rpccorsdomain=* --maxpeers=100 --verbosity=6'
echo 'The above example command will run GETH with sputnikVM syncing the ETC Morden test chain, this will also allow remote access to the RPC API on default port:8545'
echo -e '#################################################\e[0m'
