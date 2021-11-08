# @markup markdown

# Exchage-API

**This repository has an Academic purpose only.**
The Exchange-API works together with the [Brokers-API](https://github.com/jramiresbrito/brokers-api) in order to allow the
negotiation of Assets.

## Software versions

- Ruby 2.6.6p146
- Rails 6.0.4.1

## Setup

This software was created only to be used in development environment.
Although it is very easy to add, test and production environments are not available.

In order to run the software you will need docker and docker-compose which can be found in:
* [Docker](https://docs.docker.com/install/)
* [Docker Compose](https://docs.docker.com/compose/install/)

A script to manage the containers is available. Therefore, after installing
both **docker** and **docker-compose**, run the following command:
```sh
./scripts/development start
```
> Obs: You should run FIRST the Brokers-API containers. The containers here, lies on the containers there, mainly the rabbitmq and mongodb.

> Obs: all commands may require sudo if your user does not belong
to the [docker group](https://docs.docker.com/install/linux/linux-postinstall/)

To list all running containers, run:
```sh
docker ps
```

You should see a list of containers, including the following ones:
* exchange-rails - the main container that runs the rails server. It binds
the port 3001 from localhost.
* exchange-hutch - the container responsible to send messages using rabbitmq
* exchange-docs - a server that provides the code documentation.
It is accessible through localhost's port 8809.

Also, the docker-compose will use the external newtork named **brokers-bridge** created
by the [Brokers-API](https://github.com/jramiresbrito/brokers-api).

### Atention ⚠
Please make sure **all containers are up and running**. You can manually run a container
if it doesn't work automatically using the provided script.


## Using the API

A [Insomnia](https://insomnia.rest/) json is [available](https://github.com/jramiresbrito/exchange-api/blob/master/insomnia_bolsa_de_valores.json) in the root of both API's.
After import the data you can easily run requests using the Insomnia software.
If you prefer other softwares, such as [Postman](https://www.postman.com/), you can
create your own collections based on the provided json file.