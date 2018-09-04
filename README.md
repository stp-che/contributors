# README

The **Contributors** appliction shows top 3 contributors for Github repos and generates PDF certificates for them.

## Run

Build production container:

    $ docker-compose -f docker-compose.prod.yaml build

Run production:

    $ docker-compose -f docker-compose.prod.yaml up

## Development

Build development container:

    $ docker-compose -f docker-compose.dev.yaml build

Run development:

    $ docker-compose -f docker-compose.dev.yaml up

Run specs:

    $ docker-compose -f docker-compose.dev.yaml run --rm web rspec -cfd
