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
> bundle exec rackup -p 9393


## Usage

*Note: API subject to change*

### Register user

    POST [host]/users

    # with JSON body:

    { user: { email: 'joe.bloggs@example.com', password: 's3kr!tpa55'} }

Success:

    201 Created

    {"email":"joe.bloggs@example.com","authentication_token":"Pm2tbZfcwfD7B1jK_wzo"}

Failure due to invalid parameters:

    422 Unprocessable Entity

    {"errors":{"email":["is invalid"],"password":["can't be blank"]}}


### Sign in user

    POST [host]/sessions

    # with JSON body:

    { user: { email: 'joe.bloggs@example.com', password: 's3kr!tpa55'} }

Success:

    201 Created

    {"email":"joe.bloggs@example.com","authentication_token":"Pm2tbZfcwfD7B1jK_wzo"}

Failure due to invalid credential(s):

    401 Unauthorized

    {"error":"Invalid email or password."}


### Verify user token

    GET [host]/users/[authentication_token]

Success:

    200 OK

    HTTP headers:

    X-USER-ID: joe.bloggs@example.com

Failure due to invalid token:

    401 Unauthorized


### Sign out user

    DELETE [host]/sessions/[token]

Success:

    204 No Content

Failure due to invalid token:

    401 Unauthorized

