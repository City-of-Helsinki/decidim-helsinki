# README for Helsinki Decidim participatory budgeting system

2017, 2018

If/when you clone the software ('app' from now on) for to be executed
as a web service, read section 1.

If you are a developer, read other sections as well.

## 1 The use modes: a config.use_mode switch

Before running the app as a Rails server, set the "use mode" variable.

Instead of duplicating effort, we have bundled 2 use cases for this
project. Which mode to use is defined in the app source. The app
can only be in either of the two modes.

The switch is in source file:
    ./config/application.rb
Variable name is set on a line like this:
```
  config.use_mode = 'kuva'  
```
Read below for explanation of the 2 modes.

### Mode config.use_mode='kuva'

'kuva' = Using this for Decidim for Kulttuuri- ja vapaa-aika (Helsinki)
         Now the application will use Tunnistamo authorization for all
         users, automatically. No public (unauthorized user) viewing is allowed.
         This is the sort of "intranet" use mode for City employees-only.

To run this on development, you can use the `development_kuva` environment as
follows:

`RAILS_ENV=development_kuva bundle exec rails s`

#### Specific notable features in KuVa use

* login is mandatory: no public pages/resources
* UI differs from that of other use mode(s)
* no sign ups (accounts cannot be created via the app)
* Helsinki Tunnistamo used as a point of user administration and
  used also for authenticating users to system

### What is the "Tunnistamo" ?

Tunnistamo is a user federation / administration service for City of
Helsinki use.
Check out more docs at:
[Tunnistamo in github](https://github.com/City-of-Helsinki/tunnistamo/)

### Mode config.use_mode='ibud' (default)

'ibud' = Interactive budgeting (Helsinki (original, pilot usage of Decidim)

         The Helsinki Participatory Budgeting - open to public (citizens)
         Users who use the system are authenticated also by using Tunnistamo,
         but they may have

## 2 What is Helsinki Participatory Budgeting?

This is the side of our Decidim implementations that was initially
used as a pilot project City of Helsinki. The software allows democratic participation online. People can cast their vote on how the City should
spend some of their budgeted money on projects.
It is based on open source project called 'Decidim'.

## 3: The software stack: a fork of Decidim 0.12

Technically the software is a Ruby on Rails project. In particular,
this is Rails 5.x

The Decidim core is made in Ruby on Rails as well, naturally. What
is used in this particular project, is our (Mainio Tech's)
fork of the version 0.6 Decidim master branch.

Customization has been done in ie.
- terminology
- translations (i18n)

## About notation used in this doc

Ordinary Markdown rules apply. Check Markdown notation
[here](https://guides.github.com/pdfs/markdown-cheatsheet-online.pdf)

If the link broken, just google for "markdown syntax"

## About the Origins of the Decidim open source platform

The Decidim is an open source project rooted in the web
at https://github.com/decidim
[Decidim homepage](http://www.decidim.org/)

It was initiated to be used in city of Barcelona, Spain.

<<<<<<< HEAD
### Decidim Administrator's Handbook

Check:
[Decidim Admin 0.10](https://decidim.org/pdf/Decidim_AdminManual_EN_0.10.pdf)
Note that the PDF is for 0.10, whilst we are running a earlier (older)
version 0.6 at 05/2018
Read with this in mind. Some text may not apply.

## The Helsinki Decidim software

This is a "fork" of the open source master branch of Decidim.

Some modifications have been done to suit Helsinki's use case:
- term 'idea' is used instead of Decidim's organic "Proposition"
- the look and feel (layout, colors etc) was done using BootStrap 3
and the Helsinki style guide

These above modifcations, however, were technically reverted (taken
away) on 11th-15th June 2018; after which the styling used
was changed to Decidim's original choice of Foundation CSS
framework.

### Logic behind showing Processes or Groups on main page

On Main page there are now both Processes and Groups shown, as is
the default behavior in Decidim. 

## Origins of Helsinki Decidim (OSBU)

The project used to use Decidim 0.6 core. 

On 06/2018, the core was updated to 0.12-stable

The core features and concepts are as-is from Decidim, as this is
important for the integrity of the democratic voting process.

## Tips for a Rails developer

If you know Rails like your own pockets, no need to check the
below section. This lists Rails essentials, verbatim, so that
the examples work with Decidim.

### Running a rake task

For background on what rake tasks are, see Ruby Guides. (Google)

Most of the rake tasks are Rails' (and Decidim's) default ones,
but some are added specifically for our project.

Rake tasks are meant to be helpers, often manually run
to make a automated task like importing data, or some
other housekeeping task.

We have currently these custom rake tasks:

  ruuti:import_processes
  kuva:import_proposals
  db:size
  db:tables:size

"ruuti" was used to import (seed) Proposals into the Decidim in the
end of 2017s. Word Ruuti comes from the project's name,
ruuti (Finn.) = gunpowder. It's a way for the youth of Helsinki city
to get their voice heard by enabling participatory action.

"kuva" is used to import off-line data from Excel; proposals from free-time
organizations who operate within Helsinki, 04/2018.  

You can list the rake tasks available by

```
    rake -T
```

To run a task:

```
    RAILS_ENV=development bundle exec rake <rest_of_parameters>
```

Note: rake tasks might take additional CLI parameters. View the
code and check how the task fingerprint (definitions) is set up.

### 'kuva' - a rake task

This helper converts data in a external .xlsx file into the Decidim
system. See the rake file itself for usage:
./lib/tasks/kuva.rake

### db:size utility rake task

Running:
```
	RAILS_ENV=development rake db:size
```
shows overall size of the database.

### db:tables:size utility rake task

Specifics sizes for each table in database:
```
	RAILS_ENV=development rake db:tables:size
```

### Kuva rake task

This helper converts data in a external .xlsx file into the Decidim
system. See the rake file itself for usage.
./lib/tasks/kuva.rake

## Running the server (production)

Production run is when the server is not at developer's
hands, but in real environment.

### New code updates to production server

The production updates are run using Capistrano with the `production`
environment. Please see the `config/deploy` folder for all environments.

Running Capistrano:
https://github.com/capistrano/capistrano/blob/master/README.md

This will take all phases of the deployment into account, including:

- backing up a version of the previous production code
- migrations to bring db schema up to date
- bringing service up again
- possible other actions to take (see Rails related Capistrano tasks)

## Running the dev server

To enable quick code / test loop, ie. running the Decidim code
and hosting it in "localhost", use the batteries-included
Puma web server to test drive your code, live.

Launch Puma in the project root folder:

```
   cd $HKI_DECIDIM_ROOT
   bundle exec RAILS_ENV=development
```

You should soon see a message saying:
=> Booting Puma
...
* Environment: development
* Listening on tcp://0.0.0.0:3000

When the server has run, it shows up in http://localhost:3000/
(use web browser)

The CLI console keeps showing you important debug information, so
keep it visible.

### Limitations and known bugs

- be careful with HTML sanitization when using 'kuva' rake task
  - if you suspect that the Excel file may contain data in the fields
    that would cause trouble when shown on a web page (links, JavaScript
    code) then sanitize the Excel manually, or
    add code to kuva rake task method called:
``` 
    def raw_to_ssp(raw_html) 
```

  - currently (04/2018) the task trusts all data in the .xlsx Excel
    file so as to not contain so called

### Optional: make a bash alias for quickly running dev server

Add this to your workstation shell's list of aliases:
```
    alias br='RAILS_ENV=development bundle exec rails s'
```
So you don't have to remember always the long and kludgy string.
The name of the command, br, is up to you; I use 'br' as in "bundle rails".

## For You Who Improve this documentation

If you provide examples of CLI commands, please make sure
they can be copy-pasted and run as-is. If not, explain
what needs to be changed. This way we ensure all developers
who are in the beginning and familiarizing with this project
have a nice time learning.

Eg. this is an example:

```
    rake -T
```
will work, as long as user has a Ruby on Rails -environment installed.

A more complex example that has variable parameters, should always
be explained briefly.
  bootstrap
* develop
  ibudnew
  ibudrawx
  kuva
  master
