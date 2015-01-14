# APIPub API

[![Build Status](https://travis-ci.org/bashou/apipub-api.svg)](https://travis-ci.org/bashou/apipub-api)

Official repository of APIPub API 

## Requirements

This application is developed with ruby-2.1 and grape principaly.

## Installation

Clone this repository and then execute:

    $ bundle install

## Usage

Use web server you want. Personnaly, i prefer thin :

	$ RAILS_ENV=<development|production> bundle exec thin start -R config.ru # For thin
	$ RAILS_ENV=<development|production> bundle exec rackup # For rake

## Community

For community purposes, you can enable community mode if you enable set ``community: true`` in your config.yml.

It add many improvements :

**- Possibility to launch checks on several api over the world**

For example, if you ask for a DNS resolution, you will have result from your api and some other in different locations.
Just add ``?community=true`` to your compatible call like DNS Check or URL Checker.

**- Be referenced on ApiPub.net search engine**

You can find some awesome apis who community develop and asked to be registered in ApiPub.

## License

MIT License, see [LICENSE](LICENSE.txt).