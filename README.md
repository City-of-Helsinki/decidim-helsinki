# Helsinki Decidim participatory democracy system

Helsinki participatory democracy system, built on the Decidim platform.

This software is mainly used for Helsinki City participatory budgeting needs.
Read more:

https://www.hel.fi/helsinki/fi/kaupunki-ja-hallinto/osallistu-ja-vaikuta/vaikuttamiskanavat/osallisuus-ja-vuorovaikutusmalli/osallistuva-budjetointi/


## What is Helsinki participatory budgeting?

This Decidim implementation is used for running the participatory budgeting
processes for the City of Helsinki. The software allows democratic participation
online. People can cast their vote on how the city should spend some of their
budgeted money on publicly funded projects.

The live instance is visible in the following address:

https://omastadi.hel.fi/


## The software stack

Technically the software is based on the Decidim participatory framework built
on the Ruby on Rails framework.

Decidim is an open source project participatory democracy system built in
Barcelona, Spain.

[Read more about Decidim](http://www.decidim.org/)

[Participate in Decidim's development in Metadecidim](http://meta.decidim.org/)

### Decidim Documentation and Administration Manual

Documentation and administration manual for Decidim can be found from the
following URLs:

https://docs.decidim.org/

Please note the version numbers the documents have been written to. Generally
documentation lacks behind the software itself because it is constantly
evolving as a rather fresh project.


## Helsinki's Decidim instance

This is an instance of the Decidim platform, using Decidim's core with some
custom modules and customizations.

With all customizations and modifications, try to keep the application as
maintainable as possible against the Decidim core. Try to avoid hard core
customizations which require lots of efforts to maintain during Decidim's core
updates.

### Custom rake tasks

This repository contains some custom Rake tasks mainly to import and export data
from the live instances. These are mostly used on an as-needed basis and they
may not always be up to date.


## Development

### Testing OmniAuth bindings (Helsinki profile, MPASSid, etc.)

The used OmniAuth bindings are enabled by default for all environments. However,
they may not automatically work in case you do not provide their configuration
values in your local environment variables. You can define them for the
application e.g. using [rbenv](https://github.com/rbenv/rbenv).

#### Helsinki profile

Tunnistamo requires the following environment variables to be available:

- `HELSINKIPROFILE_SERVER_URI` - The server URI for the OICD authentication endpoint
- `HELSINKIPROFILE_CLIENT_ID` - The OIDC app ID assigned for the environment
- `HELSINKIPROFILE_CLIENT_SECRET` - The OIDC app secret for the environment

In order to learn more about Helsinki profile, please refer to:

https://digi.hel.fi/english/helsinki-city-data-strategy/helsinki-datastrategy-chapter-3/35-chapter/

#### MPASSid

MPASSid requires the following environment variables to be available:

- `MPASSID_MODE` - Defines the MPASSid environment to connect to. Either
  `"test"` or `"production"`.
  * For the development environment, use `"test"`
- `MPASSID_ENTITY_ID` - The entity ID for MPASSid
* For the development environment, you can define this as:
  `http://localhost:3000/users/auth/mpassid/metadata`


## Deploying the Code (production)

For deployment instructions, please refer to Decidim's own guide:

https://docs.decidim.org/en/install/#_deploy

For further instructions, consult the organization in charge of the maintenance.
