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
make cmd/geth

#copy geth runtime to bin folder
echo -e '\e[92m#################################################'
echo 'Copying GETH to bin'
echo -e '#################################################\e[0m'
sudo cp bin/geth /usr/local/bin/ &&

#copy geth runtime to bin folder
echo -e '\e[92m###########################################################################'
echo 'LATEST VERSION OF GETH AND SPUTNIKVM COMPILED AND READY TO GO TO THE MOON'
echo -e '###########################################################################\e[0m'
