# devise_authentication_api

## Local installation

### Install mongodb

E.g. on mac osx:
> brew install mongodb

### Clone repo and install gems
> git clone https://github.com/ministryofjustice/devise_authentication_api.git

> cd devise_authentication_api

> bundle

### Create indexes
> bundle exec rake db:mongoid:create_indexes

### Run tests
> bundle exec guard

### Run server
> bundle exec rails s


## Usage

*Note: API subject to change*

### Register user

    POST [host]/users.json

    # with JSON body:

    { user: { email: 'joe.bloggs@example.com', password: 's3kr!tpa55'} }

Success:

    201 Created

    {"email":"joe.bloggs@example.com","authentication_token":"Pm2tbZfcwfD7B1jK_wzo"}

Failure due to invalid parameters:

    422 Unprocessable Entity

    {"errors":{"email":["is invalid"],"password":["can't be blank"]}}


### Sign in user

    POST [host]/users/sign_in.json

    # with JSON body:

    { user: { email: 'joe.bloggs@example.com', password: 's3kr!tpa55'} }

Success:

    201 Created

    {"email":"joe.bloggs@example.com","authentication_token":"Pm2tbZfcwfD7B1jK_wzo"}

Failure due to invalid credential(s):

    401 Unauthorized

    {"error":"Invalid email or password."}


### Verify user token

    GET [host]/users/[authentication_token].json

Success:

    200 OK

    {"email":"joe.bloggs@example.com","authentication_token":"LfeEnhm9XYjCWi-Qef-H"}

Failure due to invalid token:

    401 Unauthorized

    {"error":"Invalid token."}


### Sign out user

    DELETE [host]/sessions/[token].json

Success:

    204 No Content

Failure due to invalid token:

    401 Unauthorized

