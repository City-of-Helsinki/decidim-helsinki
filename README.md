# King County Equity Now - Seattle Participatory Budgeting Site

This participatory democracy system is built on the City of Helsinki's fork of the Decidim platform.

Please check out their README's and documentation for instructions:

- [Decidim](https://github.com/decidim/decidim)
- [City of Helsinki's modified fork of Decidim](https://github.com/City-of-Helsinki/decidim-helsinki)

## Setup

### Setup (mac)

Run `script/dev-setup` and follow the instructions until you see:

`>> You're all set up!`

What it's going to do:

- Install the asdf package manager (if you prefer rbenv, check out the windows/linux setup below)
- Install Ruby via asdf
- Install PostgreSQL and ImageMagick via homebrew
- Create and set up the database

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

## Why Decidim?

We considered both [Consul](https://github.com/consul/consul) and Decidim,
but were strongly recommended by the [The Participatory Budgeting Project](https://www.participatorybudgeting.org/mission/),
a nonprofit that encourages PB processes globally, to use Decidim, as it
better aligns with the steering committee PB model that is used in the US.

## Fork of a fork of a fork?

The City of Helsinki spent a bunch of time and money making some lovely
UI changes to Decidim, and we wanted to piggyback on their good work for
our Seattle Participatory Budgeting site. Additionally, the Helsinki fork has the
most users of any Decidim fork and was well-regarded by the Decidim developers
in its implementation. One particularly useful feature is the ability to merge
multiple similar proposals into a single plan that citizens can vote on.

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

If you need to run migrations, follow up with:

`heroku run bin/rails db:migrate`

### Viewing logs

`heroku logs`

### Running migrations

`heroku run bin/rails db:migrate`

### Heroku documentation

https://devcenter.heroku.com/articles/git

## Urls

- Staging: https://decidim-seattle-staging.herokuapp.com/

## Future work

### Translations

As a proof of concept, we have added Seattle's tier 1 languages to the language
dropdown menu, (i.e. `available_locales` configuration). Decidim does not
support these languages out of the box and additional work will have to be done
to add translations. Reference [this documentation](https://docs.decidim.org/develop/en/advanced/managing_translations_i18n/)
to see the work involved to add full translations.

Because of a bug in the plans module, locales with a hyphen in the name, such
as `zh-Hans`, can't be trivially supported. The bug manifests as an error when
trying to edit plans in the admin interface. In the future, we should fix this
bug. For now, as of 7/21/20, we have worked around this bug by using
non-standard locale names `zhHans` (Chinese Simplified) and `zhHant` (Chinese
Traditional), without a hyphen. These are non-standard locale names. Update
the comment in `decidim.rb` when this issue is resolved.

### Social network authentication

Decidim supports single sign-on with Google, Facebook, Twitter, etc, but [it needs to be configured](https://github.com/decidim/decidim/blob/master/docs/services/social_providers.md).
