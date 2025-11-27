# README

## Table of Contents
- [Solution overview](#solution-overview)
- [Scope clarifications](#scope-clarifications)
- [Solution notes](#solution-notes)
- [How to read/understand Ruby on Rails code](#how-to-readunderstand-ruby-on-rails-code)
- [APIs](#apis)
  - [POST /messages](#post-messages)
  - [GET /rockets](#get-rockets)
  - [GET /rockets/{rocket_id}](#get-rocketsrocket_id)
  - [GET /rockets/{rocket_id}/rocket_messages](#get-rocketsrocket_idrocket_messages)
- [How to run](#how-to-run)
  - [Prerequisites](#prerequisites)
  - [1. Build images](#1-build-images)
  - [2. Set up the production database (one‑time)](#2-set-up-the-production-database-one-time)
  - [3. Run the services](#3-run-the-services)
- [Running tests](#running-tests)
  - [1. Set up the test database (one‑time)](#1-set-up-the-test-database-one-time)
  - [2. Run the test suite](#2-run-the-test-suite)

## Solution overview

I’m looking forward to discussing the solution in person. Here are a few high‑level facts about it:

- I chose **Ruby** and **Ruby on Rails** because that’s the ecosystem I know best.
- The solution consists of:
  - **API service** – handles all HTTP endpoints (Ruby on Rails).
  - **Background jobs** – process ingested messages and calculate rocket state projections. Implemented using **Sidekiq**, a common Ruby background processing library that uses threads to parallelize work.
  - **PostgreSQL** – primary data store.
  - **Redis** – store for Sidekiq job queues.
- The `/messages` endpoint is intentionally kept simple and fast. It only:
  - persists the incoming message
  - enqueues a background job to process “new rocket messages” for the given rocket
- Background jobs are responsible for:
  - loading a specific rocket and locking it for processing to avoid race conditions
  - finding all **unprocessed** events
  - ordering them by messageNumber
  - applying them in order to update the rocket’s current state
- This separation keeps ingestion fast and makes the system scalable: more workers can be added without affecting API latency.
- There can be a small delay between a message being ingested and the message being processed, as those are two separate processes.
- The API for fetching rocket info ([GET /rockets/{rocket_id}](#get-rocketsrocket_id)) includes a counter of unprocessed messages which clients can use to determine if there are missing updates—either due to a missing event or processing delay.

## Scope clarifications

The assignment description leaves some behavior open to interpretation. These are the main decisions I made:

- Messages can arrive **out of order**. This means that you can end up in a situation where many newer messages arrive, but one earlier message is missing. I decided to treat the message sequence as **strictly ordered**: if a message is missing, processing for that rocket stops at the last contiguous message. I considered adding a timeout mechanism (e.g. skipping gaps older than X seconds/minutes), but chose to keep the behaviour simple and deterministic for this exercise.

## Solution notes

Some details about the solution which I thought would be good to mention.

All data is stored in two tables: `rockets` and `rocket_messages`. I considered making the design more generic, with tables like events and projections so it could apply to different domains, but I decided to keep it simple and specific to the rocket use case.

I am using internal IDs as primary keys in the rockets table instead of the channel/UUID. I believe it’s better to treat the channel/UUID as an external identifier and let the database manage its own primary keys.

I haven’t spent much time optimizing queries with indexes, but that’s something we can discuss in person if needed.

Most of the code is tested, but some simpler parts are not due to time constraints. More tests could always be added, but I think the current balance is appropriate. Another good topic to discuss in person!

Ruby on Rails convention is to use snake_case everywhere. The incoming data in the examples is camelCased. I mostly stuck to snake_case and kept camelCase only where it felt appropriate. This could probably be improved in terms of consistency and handling.

I am using Single Table Inheritance (STI) in Rails, which allows you to have one database table but multiple models representing its rows based on a type field. This is a great fit for the `rocket_messages` table, since it contains different message types and STI lets you implement type-specific logic cleanly. The naming convention for STI is to use the parent model as a namespace and the child class name as the value stored in the `type` column. So with a table called `rocket_messages` and its corresponding ORM model `RocketMessage`, a message of type `RocketLaunched` would use the type value `RocketMessages::RocketLaunched`, which maps directly to an ORM subclass with the same name.

`docker-compose` has been optimized for easy running—this meant I inlined most of the env variables which would normally not be there.

No authentication of any kind has been implemented, as it was not the purpose of the assignment.

No special CI/CD or deployment setup has been implemented, as it was not the purpose of the assignment. It is, however, dockerized for easy localhost running/testing (more below).

## How to read/understand *Ruby on Rails* code

As Ruby on Rails can be a bit unfamiliar if you haven’t used it before, here’s a short guide on where to find the important parts of the codebase. Hope it helps a little bit.

Rails can run with different configurations in different environments. By default, it comes with `development`, `test` and `production`. 

You may see a lot of folders and files. A default "empty"/new Rails app comes with many existing folders and files. As it can be a little confusing, I made a brief overview of the files which actually matter:

- `db/schema.rb` Rails’ representation of the database schema, generated automatically from migrations using Rails’ schema DSL.
- `config/routes.rb`  Defines all HTTP routes/endpoints using Rails’ routing DSL.
- Tests are in the `spec/` folder
  - `spec/unit` Small, isolated tests for individual classes.
  - `spec/integration` Higher-level tests covering interactions across multiple components.
  - `spec/requests` - Full-stack HTTP endpoint tests; slower but great for verifying end-to-end behaviour and smoke testing.
- `app/` - The main application code lives here, structured by responsibility.
- `app/models` - ORM classes (ActiveRecord models) that represent database tables.
- `app/actions` - simple classes representing different controller actions. For example, if you have a controller `MessagesController` with a `show` action, the class handling the logic would be called `MessagesShowAction`.
- `app/controllers` - Rails controllers. I keep these thin and delegate most logic to separate classes to maintain clean separation between framework code and business logic.
- `app/utils` - Small, focused classes containing core business logic.
- `app/jobs` - Background job definitions. These are intentionally kept small and mainly delegate work to other objects.

## APIs

I implemented four endpoints.

#### `POST /messages`

Ingests rocket messages exactly as described in the exercise.  

The endpoint:
- validates the basic structure of the payload
- stores the message in the database
- enqueues a background job to process new messages for the relevant rocket

#### `GET /rockets`

Returns a paginated list of rockets. Supports the following query parameters:

**speed_below**  
- Filter by speed – only rockets with `speed < speed_below`.

**speed_above**  
- Filter by speed – only rockets with `speed > speed_above`.

**rocket_type**  
- Filter by rocket type – exact match.

**mission**  
- Filter by mission – exact match.

**status**  
- Filter by status – exact match.  
- Possible values: `"launched"`, `"exploded"`.

**sort**  
- Default: sort by `id` descending (most recently created first).
- Supported values:
  - `speed_asc`
  - `speed_desc`

**per_page**  
- Integer, default: `20`.
- Minimum: `10`, maximum: `25`.

**page**  
- Integer, default: `1`.
- Selects which page of results to return.

#### `GET /rockets/{rocket_id}`

Returns details for a single rocket identified by `rocket_id`.

> Note: `rocket_id` is the internal primary key, **not** the external `channel/uuid` from incoming messages.

#### `GET /rockets/{rocket_id}/rocket_messages`

Returns paginated messages for a given rocket.

Supported query parameters:

**per_page**  
- Integer, default: `20`.  
- Minimum: `20`, maximum: `100`.

**page**  
- Integer, default: `1`.

## How to run

The solution is dockerized to make it easy to run without a local Ruby/Rails setup.

There are separate services for different environments. For the assignment review, you only need the production‑like stack.

**Development**
- `api-dev`
- `jobs-dev`
- `postgres-dev`
- `redis-dev`

**Test**
- `api-test`
- `postgres-test`

**Production‑like**
- `api-prod`
- `jobs-prod`
- `postgres-prod`
- `redis-prod`

### Prerequisites

- `docker`
- `docker compose`

### 1. Build images

```bash
docker compose build
```

### 2. Set up the production database (one‑time)

```bash
docker compose run api-prod bin/rails db:setup
```

You should see output similar to:

> Created database 'rockets_production'

If you ever need to reset the database to a clean state:

```bash
docker compose run -e DISABLE_DATABASE_ENVIRONMENT_CHECK=1 api-prod bin/rails db:reset
```

### 3. Run the services

```bash
docker compose up jobs-prod api-prod
```

This will start:

- the API server
- the background job processor (Sidekiq)

By default, the API will be available at:

```
http://localhost:6024
```

(You can change the port in `docker-compose.yml` if needed.)

Sidekiq has a simple web UI where you can see the status of job processing. You can access it under `/sidekiq`. 

```
http://localhost:6024/sidekiq
```

## Running tests

Similar steps are needed for the test environment.

### 1. Set up the test database (one‑time)

```bash
docker compose run api-test bin/rails db:setup
```

### 2. Run the test suite

```bash
docker compose run api-test bundle exec rspec
```

This will run all RSpec tests against the test environment.
