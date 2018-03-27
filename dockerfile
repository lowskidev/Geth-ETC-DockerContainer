#Install ubuntu 16 Image
FROM ubuntu:16.04

# Classic Geth install DIR
COPY install /install

# Define environment variable
#ENV 

# Run Config
RUN sh /install/init

#point
ENTRYPOINT exec /.ethereum-classic/startGeth.sh
