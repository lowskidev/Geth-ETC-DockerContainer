#!/bin/sh
#uncomment geth command that best fits your needs to start geth
#If you know what you're doing feel free to write your custom start geth commands here
###############################################################################################

#If you don't wish to use pm2 to report status to http://teststats.epool.io/ or  http://etcstats.net/ just comment it out
pm2 start /.ethereum-classic/process.json

#Start Geth on Morden chain and fast sync DO this first before you start with mining
geth --sputnikvm --chain=morden --fast --identity=<nameOfGethContainer> --rpc

#ONLY AFTER SYNC IS DONE Start Geth on the morden chain and start CPU mining with two threads to the test faucet
#geth --sputnikvm --chain=morden --identity=<nameOfGethContainer> --rpc --mine --minerthreads=2 --etherbase 0x2843c155c51494a684906e386120e8c2582dff5d

#Start Geth on Mainnet chain and fast sync - DO this first before you start with mining
#geth --sputnikvm --fast --identity=<nameOfGethContainer> --rpc

#ONLY AFTER SYNC IS DONE Start Geth on the Main chain and start CPU mining with two threads to the test faucet Usually for mainnet CPU mining is not recommended.
#geth --sputnikvm --identity=<nameOfGethContainer> --rpc --mine --minerthreads=2 --etherbase 0x0450f61ac77c50137b61fff46630eb36029d8dc1
