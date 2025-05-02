# Sleep Tracker API

A RESTful JSON API for logging and tracking user sleep activity.

---
## 🚀 Features

- User authentication using `Basic Auth`)
- Record Sleep Activity (sleep & wake times)
- View Sleep History
- Follow/Unfollow Friends
- View Friends' Sleep Records
---

## 📦 Setup Instructions
To follow this documentation smoothly, make sure you have the following installed and a basic understanding of each:

- [Docker](https://www.docker.com/)
- [Git](https://git-scm.com/downloads)

### 1. Clone the repository
```
git clone git@github.com:tantyasaputra/sleep-tracker-api.git
cd sleep-tracker-api
```
### 2. Pull all the docker images needed
```
docker pull ruby:3.3-alpine
docker pull postgres:15
```
### 3. Create `.env` file
```
RAILS_ENV=development
DATABASE_HOST=database
POSTGRES_USER=postgres
POSTGRES_PASSWORD=some-long-secure-password
POSTGRES_DB=sleep_tracker_development
BASE_URL=http://localhost:3000/
SECRET_KEY=securepassword
```
### 4. Setup Database
```
# spin up the database container
docker-compose up 

# run this in different terminal (keep db container up)
docker-compose run -rm api bundle exec rails db:create 
docker-compose run -rm api bundle exec rails db:migrate
```
### 5. Seed data
```
# Optionally you can modify the seed data on /data/seeds.rb
docker-compose run -rm api bundle exec rails db:seed
```
### 6. Run the server
```
docker-compose down
docker-compose up
```
Open `localhost:3000/up` in your browser.


---
## 🧪 Running Tests
Run RSpec tests with:
```
# Run Rspec 
docker-compose run --rm -e RAILS_ENV=test api bundle exec rspec
```
Run Linter with:
```
# Check/lint the code
docker-compose run --rm api bundle exec rubocop
```

--- 
## 🌱 Seed Data
To generate more users and sleep log records, you can seed the data by running:
```
# seed users data
docker compose run --rm api bundle exec bin/rake seed:users

# seed random sleep logs for all the users
docker compose run --rm api bundle exec bin/rake seed:sleep_logs
```

---

## 📘 API Endpoints
### 👥 Users Management

- **`GET /users/profiles`** — View profiles of current users.
- **`GET /users/index`** — List all users.
- **`POST /users/:id/follow`** — Follow another user.
- **`POST /users/:id/unfollow`** — Unfollow a user.

### 💤Sleep Tracking

- **`POST /sleep_logs/clock_in`** — Clock in to start sleep tracking.
- **`POST /sleep_logs/clock_out`** — Clock out to end sleep tracking.
- **`GET /sleep_logs?page=1&per_page=10&past_days=7&sort=-created_at`** — Get list of user's sleep logs records. 


### 💕 Social Features

- **`GET /sleep_logs/following?page=1&per_page=10&past_days=7&sort=-duration`** 
— View the list of users you are following and their sleep logs activities.

### 🚑 System Health

- **`GET /up`** — Check if the Sleep Tracker API service is up and running.

---

## 📈 Scalability & Performance Strategies
To efficiently handle a growing user base, high data volumes, and concurrent requests in a Sleep Tracker engineering strategies must be implemented across infrastructure, backend design, and data handling layers. Here's a documented breakdown:

### 1. Database Optimization
####  Indexing 
Index commonly queried fields. In this app, the sleep_logs table is frequently accessed and often queried using the user_id, sleep_at, and wake_at fields. To optimize performance, I’ve created indexes for these fields.

####  Partitioning / Archiving
For high data volumes, older data can be archived or partitioned (e.g. PostgreSQL table partitioning) to optimize performance on recent data queries.

####  DB Replica
Implement DB Replica when dealing with read-heavy workloads like dashboards, reporting, and analytics (e.g., querying sleep_logs for charts).

### 2. Service Optimization
#### Query Optimization
Avoid N+1 queries with eager loading (includes, preload in ActiveRecord). Implement pagination o avoid fetching thousands of records at once.

#### Caching
Use Rails.cache or Redis to cache repetitive computations. For endpoints where the response rarely changes, it's efficient to cache the entire API response to reduce processing time and database load.

#### Background Processing
Offload non-critical or time-consuming tasks (e.g., email reports, syncing to third-party APIs) to background jobs using tools like **Sidekiq** or **Resque**.

### 3. Infrastructure Optimization

#### Load Balancing & Horizontal Scaling
A load balancer is a system that sits in front of your application servers and distributes incoming traffic to them, like a traffic cop for your backend.
Instead of making a single server more powerful (vertical scaling), horizontal scaling means adding more servers to share the load.

#### Monitoring & Auto-Scaling
Integrate **metrics and logging** tools (e.g., Datadog, New Relic, Prometheus, ELK stack).
Set up **auto-scaling policies** in cloud environments based on CPU/memory or request count.
