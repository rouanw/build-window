# Build Window

[![Build Status](https://travis-ci.org/rouanw/build-window.svg?branch=master)](https://travis-ci.org/rouanw/build-window)
[![GitHub license](https://img.shields.io/github/license/rouanw/build-window.svg)](https://github.com/rouanw/build-window/blob/master/LICENSE)

Dashboard built using [Dashing](http://shopify.github.com/dashing). Currently supports Jenkins, Travis, TeamCity, Bamboo and Go.

## Example

![Screen shot of build window](http://rouanw.github.io/images/build_health_screenshot.png "Example build dashboard")

## Getting started

Get the code. It's probably best to fork this repo so you can keep your config in source code, otherwise you can just clone it:

```sh
git clone git@github.com:rouanw/build-window.git && cd build-window
```

Run `bundle install`.

Edit `config/builds.json` with the configuration for your builds:

```
{
  "bambooBaseUrl": "https://ci.openmrs.org",
  "teamCityBaseUrl": "https://teamcity.jetbrains.com",
  "goBaseUrl":"https://build.go.cd",
  "jenkinsBaseUrl": "https://builds.apache.org",
  "builds": [
    {"id": "sinatra/sinatra", "server": "Travis"},
    {"id": "IntelliJIdeaCe_CommunityTestsLinuxJava8", "server": "TeamCity"},
    {"id": "Lucene-Solr-Maven-5.4", "server": "Jenkins"},
    {"id": "BB-BDB", "server": "Bamboo"},
    {"id": "build-linux", "server": "Go"}
  ]
}
```

Run `dashing start`.

Runs at `http://localhost:3030/builds` by default.

Run `dashing start -d -p 3031` to run it as a daemon and to specify the port. You can stop the daemon with `dashing stop`.

See https://github.com/Shopify/dashing/wiki for more details.

### Authentication

Place your API credentials in a `.env` file at the root of the project. (Please note that authentication is currently only supported for Go CD and Jenkins.) Example:

#### Go

```
GO_USER=view
GO_PASSWORD=password
```

#### Jenkins

```
JENKINS_USER=user
JENKINS_TOKEN=password
```

## Docker support

You can spin up a Docker container with build-window by running:

`docker-compose up -d`

The application will be ready at `http://localhost:3030` (Linux) or at `http://<DOCKER_HOST_IP>:3030` (Windows/OS X).

You can also build the image and run a container separately, but [Docker Compose](https://docs.docker.com/compose/install/) makes this process much simpler.

## Contributing

Pull requests welcome. Run the tests with `rspec`.

## Contributions

Thanks to Max Lincoln ([@maxlinc](https://github.com/maxlinc)) for coming up with the name __Build Window__.
