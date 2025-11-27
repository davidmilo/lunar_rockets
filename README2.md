# Solution Description

Looking forward to discussing the solution in person.
Here are a few high-level facts about my implementation:
- I chose **Ruby** and **Ruby on Rails** because that’s the language I’m most productive in.
- The solution consists of:
  - API service – handles all HTTP endpoints. Built with Rails.
  - Background workers – responsible for processing ingested messages and calculating rocket state. Implemented using Sidekiq, which allows multi-threaded job execution.
  - PostgreSQL – main data store.
  - Redis – required by Sidekiq for job queue storage.
- `/messages` endpoint is intentionally very lightweight. It only persists the raw message and enqueues a background job.
- Background jobs process new messages for each rocket ID, ensuring correct sequencing and state updates.
