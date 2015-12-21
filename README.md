# Build Health Dashboard

Dashboard built using [Dashing](http://shopify.github.com/dashing). Currently supports Bamboo. Pull requests welcome.

## Getting started

Run `bundle install`.

Edit `config/builds.json` with the configuration for your builds:

```
{
  "bambooBaseUrl": "https://ci.openmrs.org/",
  "maxBuilds": "25",
  "builds": [
    "AS-ASML",
    "BB-BDB",
    "CA-CA",
    "EBOLA-EEM"
  ]
}
```

Run `dashing start`.

Runs at `http://localhost:3030/builds` by default. See https://github.com/Shopify/dashing/wiki for details on how to run it elsewhere, as a service and more.
