#Download GETH Source
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
cp geth /usr/local/bin/

#copy geth runtime to bin folder
echo -e '\e[92m###########################################################################'
echo 'LATEST VERSION OF GETH AND SPUTNIKVM COMPILED AND READY TO GO TO THE MOON'
echo -e '###########################################################################\e[0m'
