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

### Environment variables

Number of authentication tries before locking an account.

> MAXIMUM_ATTEMPTS=5

Time interval in seconds to unlock the account.

> UNLOCK_IN_SECS=86400

### Run server
> bundle exec rackup -p 9393


## Usage

*Note: API subject to change*

### Admin registration of users

#### Admin user registers user

    POST [host]/admin/:admin_authentication_token/users

    # with JSON body:

    { "user": { "email": "joe.bloggs@example.com" } }

Success:

    201 Created

    {"email":"joe.bloggs@example.com","confirmation_token":"b614285c-6a10"}

    # and confirmation email is sent to "joe.bloggs@example.com"

Failure due to invalid admin authentication_token:

    401 Unauthorized

    '{"error":"Invalid token."}'

Failure due to invalid email:

    422 Unprocessable Entity

    {"errors":{"email":["is invalid"]}}


#### Activate registration

    POST [host]/users/activation/[confirmation_token]

    # with JSON body:

    { "user": { "password": "s3kr!tpa55" } }

Success:

    204 No Content

Failure due to invalid confirmation_token:

    401 Unauthorized

    '{"error":"Invalid token."}'

Failure due to invalid password:

    422 Unprocessable Entity

    {"errors":{"password":["is too short (minimum is 8 characters)"]}}



### Self registration

#### Register user

    POST [host]/users

    # with JSON body:

    { "user": { "email": "joe.bloggs@example.com", "password": "s3kr!tpa55"} }

Success:

    201 Created

    {"email":"joe.bloggs@example.com","confirmation_token":"b614285c-6a10"}

Failure due to invalid parameters:

    422 Unprocessable Entity

    {"errors":{"email":["is invalid"],"password":["can't be blank"]}}


#### Confirm registration

    POST [host]/users/confirmation/[confirmation_token]

Success:

    204 No Content

Failure due to invalid parameters:

    401 Unauthorized

    '{"error":"Invalid token."}'


### Sign in user

    POST [host]/sessions

    # with JSON body:

    { "user": { "email": "joe.bloggs@example.com", "password": "s3kr!tpa55"} }

Success:

    201 Created

    {"email":"joe.bloggs@example.com","authentication_token":"Pm2tbZfcwfD7B1jK_wzo"}

Failure due to invalid credential(s):

    401 Unauthorized

    {"error":"Invalid email or password."}

Failure after > MAXIMUM_ATTEMPTS failed attempts results in locked account:

    401 Unauthorized

    {"error":"Your account is locked."}


### Verify user token

    GET [host]/users/[authentication_token]

Success:

    200 OK

    HTTP headers:

    X-USER-ID: joe.bloggs@example.com

Failure due to invalid token:

    401 Unauthorized



### User change password

    PATCH [host]/users/[authentication_token]

    # with JSON body:

    { "user": { "password": "n3w-s3kr!tpa55" } }

Success:

    204 No Content

Failure due to invalid authentication_token:

    401 Unauthorized

    '{"error":"Invalid token."}'

Failure due to invalid password:

    422 Unprocessable Entity

    {"errors":{"password":["is too short (minimum is 8 characters)"]}}




### Sign out user

    DELETE [host]/sessions/[token]

Success:

    204 No Content

Failure due to invalid token:

    401 Unauthorized


## High level design (proposed - not all implemented yet)

An API to provide authenication functionality to a simple authentication layer. This 'layer' protects underlying APIs from unauthenticated access from user-facing applications, as shown below:

![image](docs/auth-high-level-design.png)

The authentication layer is intended to be a standalone reverse proxy. However, currently it is implemented as a [ruby/rack middleware application](https://github.com/ministryofjustice/x-moj-auth) and a PHP membrane application.

## User states (proposed - not all implemented yet)

Each user is known to the authentication API, and can exist in a number of persistent states:

![image](docs/auth-state-transition.png)

