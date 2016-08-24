# Phamello

Phamello is an example of a **Ph**oenix + **Am**azon S3 + Tr**ello** integration.
After having uploaded an image, this will be pushed to S3, then used to publish a card on Trello.
A demo is currently available at [https://gentle-wildwood-53699.herokuapp.com/](https://gentle-wildwood-53699.herokuapp.com/)

Highlights:

  * Authenticate through Github
  * Persist the images _both_ on the application's host and on S3. Images on the application's host won't be removed after being pushed to S3 (although this can be easily tweaked)
  * Uploading to S3 and publishing on Trello are both handled through asyncronous tasks, and orchestrated through a `GenServer`
  * Tasks will notify the browser after completion (just in case you see the logotype buzzing)

## Configuration

The application is setup to be easily deployable (in this case, to Heroku).
For that reason, most of the configuration settings are setup through a `.env` file.
Checkout `.env.example` for a complete list of required settings.

  * Fill all of the required external credentials
  * For `SECRET_KEY_BASE` and `GUARDIAN_SECRET_KEY` vars, you can easily generate a value with `mix phoenix.gen.secret`

After creating your `.env` file, remember to `source` it before running any `iex` or `mix` related command.

## Setup

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server` (rember to `source` your `.env` file!)

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Deploying

A deployable version is available in the branch `heroku-deploy`.
Before deploying yourself, remember to change your app's `Endpoint` configuration in `config/prod.exs`.
This should match your Heroku application's host:

```
url: [scheme: "https", host: "my-application-name.herokuapp.com", port: 443],
```
