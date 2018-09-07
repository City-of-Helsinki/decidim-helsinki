# Helsinki Decidim participatory democracy system

Helsinki participatory democracy system, built on the Decidim platform.

The first wider need is to use the participatory budgeting feature in the city
wide participatory budgeting ([read more](https://kuntalehti.fi/uutiset/kaupunkilaisille-paatosvalta-44-miljoonasta-eurosta-ja-aanioikeus-12-vuotta-tayttaneille-helsinki-kehittaa-lahidemokratiaa/)).

Before this system has been evaluated in distributing funds for youth projects
in Helsinki ([read more](https://digi.hel.fi/digipalveluopas/tarinat/miten-budjetti-jaetaan-osallistava-budjetointi/)).

This system is also internally being used at Helsinki to apply participatory
decision making within the organization as well.


## What is Helsinki participatory budgeting?

This is the side of our Decidim implementations that was initially used as a
pilot project City of Helsinki. The software allows democratic participation
online. People can cast their vote on how the City should spend some of their
budgeted money on publicly funded projects.

The live instance is visible in the following address:

https://osallistu.hel.fi/


## The software stack

Technically the software is a Ruby on Rails project. In particular,
this is Rails 5.x.

The Decidim core is made on top of the Ruby on Rails framework as well.

The Decidim is an open source project participatory democracy system built in
Barcelona, Spain.

[Read more about Decidim](http://www.decidim.org/)

[Participate in Decidim's development in Metadecidim](http://meta.decidim.org/)

### Decidim Documentation and Administration Manual

Documentation and administration manual for Decidim can be found from the
following URLs:

- https://decidim.org/docs/
- https://docs.decidim.org/

Please note the version numbers the documents have been written to. Generally
documentation lacks behind the software itself because it is constantly
evolving as a rather new project.


## Helsinki's Decidim instance

This is an instance of the Decidim platform, using Decidim's core as is. Some
modifications particularly to the UI have been made. Also, some customizations
are made to the application to suit Helsinki's use case.

With all customizations and modifications, try to keep the application as
maintainable as possible against the Decidim core. Try to avoid hard core
customizations which require lots of efforts to maintain over Decidim's core
updates.

### Custom rake tasks

Most of the rake tasks are Rails' (and Decidim's) default ones, but some are
added specifically for this project.

Note: rake tasks might take additional CLI parameters. View the code and check
how the task fingerprint (definitions) is set up.

#### ruuti:import_processes

"ruuti" was used to import (seed) Proposals into the Decidim in the
end of 2017s. Word Ruuti comes from the project's name,
ruuti (Finn.) = gunpowder. It's a way for the youth of Helsinki city
to get their voice heard by enabling participatory action.

#### kuva:import_proposals

"kuva" is used to import off-line data from Excel; proposals from free-time
organizations who operate within Helsinki, 04/2018.  

This helper converts data in a external .xlsx file into the Decidim system.
See the rake file itself for usage:
./lib/tasks/kuva.rake

Be careful with HTML sanitization when using 'kuva' rake task. If you suspect
that the Excel file may contain data in the fields that would cause trouble
when shown on a web page (links, JavaScript code) then sanitize the Excel
manually, or add code to kuva rake task method called:

```
  def raw_to_ssp(raw_html)
```

Currently (04/2018) the task trusts all data in the .xlsx Excel file so as to
not contain so called.

#### db:size utility rake task

Shows overall size of the database.

Running:

```
  RAILS_ENV=development rake db:size
```

#### db:tables:size utility rake task

Specifics sizes for each table in database.

Running:

```
  RAILS_ENV=development rake db:tables:size
```


### The use modes: a config.use_mode switch

Before running the app as a Rails server, set the "use mode" variable.

Instead of duplicating effort, we have bundled 2 use cases for this
project. Which mode to use is defined in the app source. The app
can only be in either of the two modes.

The switch is in source file: `./config/application.rb`

Variable name is set on a line like this:

```
  config.use_mode = 'kuva'
```

Read below for explanation of the 2 modes.

#### config.use_mode='kuva'

'kuva' = Using Decidim for the Ideapaahtimo instance, forcing all users to
         authenticate before they can access the service. Used to be Kulttuuri-
         ja vapaa-aika (Helsinki, i.e. "KUVA", thus the name). After setting
         this, the application will force authentication to the platform for all
         users, automatically. No public (unauthorized user) viewing is allowed.
         This is the sort of "intranet" use mode for City employees-only.

To run this on development, you can use the `development_kuva` environment as
follows:

`RAILS_ENV=development_kuva bundle exec rails s`

Specific notable features in KuVa (Ideapaahtimo) use:

* Login is mandatory: no public pages/resources
* UI differs from that of other use mode(s)
* No sign ups (accounts cannot be created via the app)
* Helsinki Tunnistamo used as a point of user administration and
  used also for authenticating users to system

Tunnistamo is a user federation / administration service built by the City of
Helsinki. Check out more docs at:
[Tunnistamo in github](https://github.com/City-of-Helsinki/tunnistamo/)

#### config.use_mode='ibud' (default)

'ibud' = Interactive budgeting (Helsinki (original, pilot usage of Decidim)
         The Helsinki Participatory Budgeting - open to public (citizens)
         Users who use the system are authenticated also by using Tunnistamo,
         but they may have


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


## Deploying the Code (production)

For deployment instructions, please refer to Decidim's own guide:

https://github.com/decidim/decidim/blob/master/docs/getting_started.md#deploy


### New code updates to production server

The production updates are run using Capistrano with the `production`
environment. Please see the `config/deploy` folder for all environments.

For security reasons, the deployment configs are kept in a separate repository.

Running Capistrano:
https://github.com/capistrano/capistrano/blob/master/README.md

This will take all phases of the deployment into account, including:

- backing up a version of the previous production code
- migrations to bring db schema up to date
- bringing service up again
- possible other actions to take (see Rails related Capistrano tasks)
