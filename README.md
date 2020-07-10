# King County Equity Now - Seattle Participatory Budgeting Site

This participatory democracy system is built on the City of Helsinki's fork of the Decidim platform. 

Please check out their README's and documentation for instructions:

* [Decidim](https://github.com/decidim/decidim)
* [City of Helsinki's modified fork of Decidim](https://github.com/City-of-He<F2>lsinki/decidim-helsinki)

## Setup

### Setup (osx)

Run `script/dev-setup` and follow the instructions until you see:

`>> You're all set up!`

What it's going to do:

* Install the asdf package manager (if you prefer rbenv, check out the windows/linux setup below)
* Install ruby via asdf
* Install Postgresql via homebrew
* Create and set up the database

People sometimes run into problems with database connection issues. If that's the case, chances are postgres is shutting down right after starting up and to find out why, run `brew info postgresql` and check out the instructions on how to start postgresql manually. That's usually enough to get people unblocked.

### Setup (windows/linux, or people who hate the streamlined script for whatever reason)

Please see the core Decidim docs:
https://github.com/decidim/decidim/blob/master/docs/getting_started.md

## Running the server

`bin/rails server`

## Decidim Documentation and Administration Manual

Documentation and administration manual for Decidim can be found from the
following URLs:

- https://decidim.org/docs/
- https://docs.decidim.org/

## Fork of a fork of a fork?

The City of Helsinki spent a bunch of time and money making some lovely
UI changes to Decidim, and we wanted to piggyback on their good work for
our Seattle Participatory Budgeting site.
 
With all customizations and modifications, try to keep the application as
maintainable as possible against the Decidim core. Try to avoid hard core
customizations which require lots of efforts to maintain over Decidim's core
updates.

## Deploying

### Setup

1. Ask to be invited to the `staging-substantial` team of ECEN
2. Download and install the [heroku CLI tools](https://devcenter.heroku.com/articles/heroku-command-line)
3. `heroku login`
4. `git remote add heroku-staging https://git.heroku.com/decidim-seattle-staging.git`

### Deploying staging

`git push heroku-staging master`

