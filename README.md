# Build Health Dashboard

[![Build Status](https://travis-ci.org/rouanw/build-health-dashboard.svg?branch=master)](https://travis-ci.org/rouanw/build-health-dashboard)

Dashboard built using [Dashing](http://shopify.github.com/dashing). Currently supports Travis, TeamCity, Bamboo and GO CD.

## Example

![Alt text](http://rouanw.github.io/images/build_health_screenshot.png "Example build dashboard")

## Getting started

Run `bundle install`.

Edit `config/builds.json` with the configuration for your builds:

```
{
  "bambooBaseUrl": "https://ci.openmrs.org",
  "teamCityBaseUrl": "https://teamcity.jetbrains.com",
  "goBaseUrl":"https://build.go.cd",
  "builds": [
    {"id": "sinatra/sinatra", "server": "Travis"},
    {"id": "IntelliJIdeaCe_CommunityTestsLinuxJava8", "server": "TeamCity"},
    {"id": "BB-BDB", "server": "Bamboo"},
    {"id": "EBOLA-EEM", "server": "Bamboo"},
    {"id": "build-linux", "server": "Go"}
  ]
}
```

Run `dashing start`.

Runs at `http://localhost:3030/builds` by default. See https://github.com/Shopify/dashing/wiki for details on how to run it elsewhere, as a service and more.

## Contributing

Pull requests welcome. Run the tests with `rspec`.
