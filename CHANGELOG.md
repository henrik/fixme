# Changelog

## 6.1.1

* No functional changes. Opted into MFA for Gem releases: https://guides.rubygems.org/mfa-requirement-opt-in/

## 6.1.0

* Checks `APP_ENV`, not just `RACK_ENV`, as this is [what Sinatra now encourages using](https://github.com/sinatra/sinatra/blob/master/CHANGELOG.md#200--2017-04-10).

## 6.0.0

* Require zero-padded month and day, i.e. disallow `2019-1-2`. This enforced consistency makes it easier to grep for an exploded FIXME.

## 5.0.0 and earlier

* Please see commit history, or make a pull request to update this file.
