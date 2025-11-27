# README

http://0.0.0.0:5024/rockets?rocket_type=Falcon-9&mission=GEMINI&status=launched&speed_above=400&speed_under=5000&sort=speed_desc

## Solution description

Looking forward to discuss the solution in person. Here are Few high level facts about my solution:
- I decided to use **Ruby** and **Ruby on Rails** for my solution as I have most experience with it.
- Solution consist of:
  - API - which handsles all the API calls. Built in *Ruby on Rails*.
  - Background jobs - for processing the ingested messages and calculating rocket projections. This is implemented using sidekiq - very common solution for background processing for Ruby which uses threads to paralelize work. 
  - PostgreSQL as database for the data
  - Redis as a storage for the background job queues (primary storage used by sidekiq)
- `/messages` API is kept simple and is only used for simple/fast ingestion of messages into the database. After ingestion, it triggers background job to "process new rocket messages" for a specific rocket id
- Background jobs are responsible for picking a specific rocket, finding all unprocessed events and process them. 

### Scope clarifications 
As the description is not covering every single aspect of a potential solution, there were few things I needed to make a decision on. I will try to summarise it here:
- As events can arrive **out of order**, there is a decision to be made how to handle scenario when lot of new messages ahve arrived but there is one event missing which is blocking the processing of the state for a certain rocket. I decided to leave it like this. events will not be processed. I thoguht about doing a solution where you could define some kind of timeout after which we could skip the missing event but decided to keep it simple and just simply block the processing until missing event arrives.
- 


## APIs

I implemented 3 APIs:

#### `POST /messages`

Endpoint to ingest rocket messages as described in the excercise.

#### `GET /rockets`

Endpoint which returns list of all rockets in the system. Supports following params:

**speed_below**
- filtering based on rocket speed - only rockets with speed lower than the value

**speed_above**
- filtering based on rocket speed - only rockets with speed higher than the value

**rocket_type**
- filtering based on rocket type - only exact matches

**mission**
- filtering based on rocket mission - only exact matches

**status**
- filtering based on rocket status - only exact matches
- possible values: "launched", "exploded"

**sort**
- default is sorting by id from highest to lowest
- possible values: speed_asc and speed_desc to sort by the speed

**per_page**
- integer, default: 20
- specifies how many results you wnat per page, min allowed: 10, max allowed: 25

**page**
- integer, default: 1
- Specifies which page of the results you want


#### `GET /rockets/{rocket_id}`

Endpoint which returns details about a specific rocket using `rocket_id` (This is not the same as channel/uuid in the messages but rather internal identifier for rockets)

#### `GET /rockets/{rocket id}/rocket_messages`

Endpoint for returning all rocket messages for a specific `rocket_id`. Supported params:

**per_page**
- integer, default: 20
- specifies how many results you wnat per page, min allowed: 20, max allowed: 100

**page**
- integer, default: 1
- Specifies which page of the results you want


## How to run
As this is implemented in *Ruby on Rails* and it could be a bit tricky to explain the whole setup to someone who is not familiar with it, I decided to dockerize the solution.

There are several services in different environments. I expect you to only use production one but here is the overview of all of them:
For development
- api-dev
- jobs-dev
- postgres-dev
- redis-dev

For runnign tests:
- api-test
- postgres-test

For production mode:
- api-prod
- jobs-prod
- postgres-prod
- redis-prod

Assuming you have `docker` and `docker compose` installed, you can the app running with few commands:

build the code

```bash
docker compose build
```

[one time only] setup a database

```bash
docker compose run api-prod bin/rails db:setup
```

it should print something like: *Created database 'rockets_production* if it was sucessful. 

If you ever by any chance need to reset your database and start with clean state, you can run:

```bash
docker compose run -e DISABLE_DATABASE_ENVIRONMENT_CHECK=1 api-prod bin/rails db:reset
```

You should be able to run the solution with:

```bash
docker-compose up jobs-prod api-prod
```

This will start the api server which will run on port http://localhost:6024[http://localhost:6024]. You can change the port in docker-compose.yml if you want.

## Running tests

To run the tests, you need to do similar steps:

One time DB setup:

```bash
docker compose run api-test bin/rails db:setup
```

Run the tests:

```bash
docker compose run api-test bundle exec rspec
```
