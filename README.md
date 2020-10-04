# Helsinki Decidim participatory democracy system

Helsinki participatory democracy system, built on the Decidim platform.

This software is mainly used for Helsinki City participatory budgeting needs.
Read more:

https://www.hel.fi/helsinki/fi/kaupunki-ja-hallinto/osallistu-ja-vaikuta/vaikuttamiskanavat/osallisuus-ja-vuorovaikutusmalli/osallistuva-budjetointi/

This system has also internally been used at Helsinki to apply participatory
decision making within the organization as well.


## What is Helsinki participatory budgeting?

This Decidim implementations was initially used as a pilot project City of
Helsinki. The software allows democratic participation online. People can cast
their vote on how the City should spend some of their budgeted money on publicly
funded projects.

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

### The use modes: a config.use_mode switch

Before running the app as a Rails server, set the "use mode" variable.

Instead of duplicating effort, we have bundled 2 use cases for this
project. Which mode to use is defined in the app source. The app
can only be in either of the two modes.

The switch is in source file: `./config/application.rb`

Variable name is set on a line like this:

```
  config.use_mode = 'private'
```

Read below for explanation of the 2 modes.

#### config.use_mode='private'

'private' = Using Decidim for the Ideapaahtimo instance, forcing all users to
            authenticate before they can access the service. After setting this,
            the application will force authentication to the platform for all
            users, automatically. No public (unauthorized user) viewing is
            allowed. This is the sort of "intranet" use mode for City
            employees-only.

To run this on development, you can use the `development_kuva` environment as
follows:

`RAILS_ENV=development_kuva bundle exec rails s`

Specific notable features in private use (Ideapaahtimo/KuVa):

* Login is mandatory: no public pages/resources
* UI differs from that of other use mode(s)
* No sign ups (accounts cannot be created via the app)
* Helsinki Tunnistamo used as a point of user administration and
  used also for authenticating users to system

Tunnistamo is a user federation / administration service built by the City of
Helsinki. Check out more docs at:
[Tunnistamo in github](https://github.com/City-of-Helsinki/tunnistamo/)

#### config.use_mode='normal' (default)

'normal' = Normal mode, application is open to public (citizens) users, no login
           required before accessing the content.


## Development

### Running the dev server

To enable quick code / test loop, ie. running the Decidim code and hosting it
in "localhost", use the batteries-included Puma web server to test drive your
code, live.

Launch Puma in the project root folder:

```
  cd /path/to/project
  RAILS_ENV=development bundle exec rails s
```

### Comments component

The comments component has been extracted from the main Decidim application to
apply local changes to it. The main reason for this was to make it IE11
compatible.

The comments component works as a standalone React application which is bundled
for the Rails assets pipeline. Every time making changes to the app, please
rebuild the application bundle.

The application sources live at `vendor/decidim-comments`. The sources are
bundled locally to the app directory using Webpack.

Follow Decidim's own instructions regarding developing the comments component:

https://github.com/decidim/decidim/tree/master/decidim-comments

In short:

- Install npm dependencies with:
  `npm i`
- During development, run the webpack watcher with (it will rebuild the app
  every time you make changes):
  `npm start`
- Make your changes to the React app at `vendor/decidim-comments`
- Test it in the browser
- Once you are finished, stop the watcher and run tests with:
  `npm test`
- If some tests fail, fix them
- Build the production version of the application bundle with:
  `npm run build:prod`
- Commit your changes along with the new bundle created at
  `app/assets/javascripts/decidim/comments/bundle.js`


### Testing OmniAuth bindings (Tunnistamo, Suomi.fi, MPASSid, etc.)

The used OmniAuth bindings are enabled by default for all environments. However,
they may not automatically work in case you do not provide their configuration
values in your local environment variables. You can define them for the
application e.g. using [rbenv](https://github.com/rbenv/rbenv).

#### Tunnistamo

Tunnistamo requires the following environment variables to be available:

- `OMNIAUTH_OPENIDCONNECT_APP_ID` - The OIDC app ID assigned for the environment
- `OMNIAUTH_OPENIDCONNECT_APP_SECRET` - The OIDC app secret for the environment

In order to learn more about Tunnistamo or install it locally to test the
connectivity, please refer to the Tunnistamo documentation:

https://github.com/City-of-Helsinki/tunnistamo

#### Suomi.fi

Suomi.fi requires the following environment variables to be available:

- `SUOMIFI_MODE` - Defines the Suomi.fi environment to connect to. Either
  `"test"` or `"production"`.
  * For the development environment, use `"test"`
- `SUOMIFI_ENTITY_ID` - The entity ID for Suomi.fi
  * For the development environment, you can define this as:
    `http://localhost:3000/users/auth/suomifi/metadata`
- `SUOMIFI_CERT_FILE` - A certificate file that contains the certificate sent
  to Suomi.fi as part of the metadata. This is used to encrypt messages at
  Suomi.fi before they are sent to the service.
  * For the development environment, you can use the development certificate
    from the `decidim-suomifi` repository: https://git.io/fjdaM
- `SUOMIFI_PKEY_FILE` - The private key corresponding to the certificate. This
  is used to decrypt messages coming from Suomi.fi.
  * For the development environment, you can use the development private key
    from the `decidim-suomifi` repository: https://git.io/fjda1

#### MPASSid

MPASSid requires the following environment variables to be available:

- `MPASSID_MODE` - Defines the MPASSid environment to connect to. Either
  `"test"` or `"production"`.
  * For the development environment, use `"test"`
- `MPASSID_ENTITY_ID` - The entity ID for Suomi.fi
* For the development environment, you can define this as:
  `http://localhost:3000/users/auth/mpassid/metadata`


## Deploying the Code (production)

For deployment instructions, please refer to Decidim's own guide:

https://github.com/decidim/decidim/blob/master/docs/getting_started.md#deploy

For further instructions, consult the organization in charge of the maintenance.
