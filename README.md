CoachUP!
==========================
[CoachUP!](https://coachup.herokuapp.com) is a web app that lets you take or give sport lessons!

## Installation guide

Prior Notice for external services : In your facebook app, add http://<your-domain>/auth/facebook/callback as a valid OAuth redirect URI for example

#### Install on Heroku:
1. Pull the repo and create an app on your Heroku account

2. Set the environment variables on Heroku for:

  ```
  SMTP_USERNAME=
  SMTP_PASSWORD=
  GOOGLE_CLIENT=
  GOOGLE_SECRET=
  CLOUDINARY_KEY=
  CLOUDINARY_SECRET=
  FACEBOOK_KEY=
  FACEBOOK_SECRET=
  ```
  
3. Install the Schedule add-on on Heroku and schedule two daily tasks with the following commands: 

   * `rake jobs:training_entries`
   * `rake jobs:session_reminder`

4. Use `git subtree push --prefix coachup heroku master` from the root folder to push the app folder to Heroku

5. If needed run `heroku run rake db:migrate`

#### Install on your server:
:warning: You'll have to create your own cron jobs to schedule the email sending and the entry writing in the database (Take a look at the file jobs.rake) :warning:


1. Install PostgreSQL and have an instance running

2. Pull the repo

3. Fill in the `.env.example` file right next to your `Gemfile` and rename it to `.env`

4. Create the database (`rake db:create`)

5. Run `bin/rails server`

## Course

Project done for the Advanced Software Engineering Course at UniFR
