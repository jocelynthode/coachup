CoachUP!
==========================
[CoachUP!](https://coachup.herokuapp.com) is a web app that lets you take or give sport lessons!

## Installation guide

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
3. Use `git subtree push --prefix coachup heroku master` from the root folder to push the app folder to Heroku

4. If needed run `heroku run rake db:migrate`

#### Install on your server:
1. Install PostgreSQL and have an instance running

2. Pull the repo

3. Fill in the `.env.example` file right next to your `Gemfile` and rename it to `.env`

4. Create the database

5. Run `rails s`

## Course

Project done for the Advanced Software Engineering Course at UniFR
