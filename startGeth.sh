#!/bin/sh
#uncomment geth command that best fits your needs to start geth
#If you know what you're doing feel free to write your custom start geth commands here
###############################################################################################

#Start Geth on Morden chain and fast sync DO this first before you start with mining
geth --sputnikvm --chain=<chainName> --fast --identity=<nameOfGethContainer> --rpc --maxpeers=33 --verbosity=6
