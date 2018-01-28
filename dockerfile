#Install ubuntu 16 Image
FROM ubuntu:16.04

# Classic Geth install DIR
COPY install /install

# Geth/Http-RPC/WS-RPC
EXPOSE 30303 8545 8546 8082 8008 8888 8080

# Define environment variable
#ENV 

# Run Config
RUN sh /install/init

#point
ENTRYPOINT exec /.ethereum-classic/startGeth.sh
