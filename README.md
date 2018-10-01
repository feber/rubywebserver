# GoWebServer

## Description
GoWebServer is an example of building web service by following microservice standards using Golang. This web service provides HTTP endpoints which lets user perform Create, Read, Update and Delete operations in database.

## Endpoints

The web server provide a set of endpoints with different functions.

- #### Metrics: Provides an HTTP handler that can be used by Prometheus to scrap metrics

  ```
  GET /metrics
  ```

  Example

  ```sh
  curl -X GET "http://localhost:1234/metrics"
  ```

  Output (text/plain)

  ```
  metrics
  ```


- #### Healthz: Health check

  ```
  GET /healthz
  ```

  Example

  ```sh
  curl -X GET "http://localhost:1234/healthz"
  ```

  Output (application/json)

  ```json
  ok
  ```

- #### Get all Books: Return all `Books` from database

  ```
  GET /books
  ```

  Example

  ```sh
  curl -X GET "http://localhost:1234/books"
  ```

  Output (application/json)

  ```json
  [{"id":1,"title":"number one","category":"action"}, {...}]
  ```

- #### Post Book: Retreive user's data and save to database

  ```
  POST /books
  ```

  Example

  ```sh
  curl -X POST "http://localhost:1234/books" -d "title=number one&category=action"
  ```

  Output (application/json)

  ```json
  {"id":1,"title":"number one","category":"action"}]
  ```

- #### Get a Book: Retrieve a single `Book` determined by `:id`

  ```
  GET /books/:id
  ```

  Example

  ```sh
  curl -X GET "http://localhost:1234/books/1"
  ```

  Output (application/json)

  ```json
  {"id":1,"title":"number one","category":"action"}]
  ```

- #### Update a Book: Updates a single `Book` determined by `:id`

  ```
  POST /books/:id
  ```

  Example

  ```sh
  curl -X POST "http://localhost:1234/books/1" -d "title=number double o one"
  ```

  Output (application/json)

  ```json
  {"id":1,"title":"number double o one","category":"action"}]
  ```

- #### Delete a Book: Deletes a `Book` in database determined by `:id`

  ```
  DELETE /books/:id
  ```

  Example

  ```sh
  curl -X DELETE "http://localhost:1234/books/1"
  ```

  Outputs nothing


## SLO and SLI
* Availability: 99%
* Mean Response Time: < 100 ms

## Architecture Diagram
```
? <==> ?
```

## Owner
SRE (sre@bukalapak.com)

## Contact and On-Call Information
See [Contact and On-Call Information](https://bukalapak.atlassian.net/wiki/display/INF/Contact+and+On-Call+Information)

## On-Call Runbooks
Plese see [Contact and On-Call Information](https://bukalapak.atlassian.net/wiki/display/INF/Contact+and+On-Call+Information)

## Onboarding and Development Guide
This documentation is designed to help new comers to catch up with the stack.

### Dependencies

- Git
- Ruby 2.3 or later
- Bundler
- Rubocop

### Setup

- Install Git

  See [Git Installation](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

- Install Ruby

  See [Ruby Installation](https://www.ruby-lang.org/en/documentation/installation/) or [RVM](https://rvm.io/rvm/install)

- Install bundler

  See [Bundler Installation](http://bundler.io/)

- Install rubocop

  ```sh
  gem install rubocop
  ```

- Setup SQLite for you operating system

- Clone this repo

- Install dependencies

  ```sh
  bundle install
  ```

- Run the server

  ```sh
  bundle exec puma -p 1234 app/web/config.ru
  ```

### Development

- Make new branch with descriptive name about the change(s) and checkout to the new branch

  ```sh
  git checkout -b branch-name
  ```

- Make your change(s) and make the test(s)

- Beautify and review the codes by running this command (note: **this is a must!**)

  ```sh
  rubocop
  ```

  If there are any errors after executing the command, please fix them first

- Save dependencies

  ```sh
  govendor add +external
  govendor fetch -v +outside
  ```

- Commit and push your change to upstream repository

  ```sh
  git commit -m "a meaningful commit message"
  git push origin branch-name
  ```

- Open Pull Request in Repository

- Pull request should be merged only if review phase is passed

### Request Flows, Endpoints, and Dependencies

None, self sufficient

## Links
- [Project Structure - Ruby](https://bukalapak.atlassian.net/wiki/spaces/INF/pages/123207808/Project+Structure+-+Ruby)

## FAQ
This project is a part of First-Two-Weeks task. This  assignment aims to adapt your mindset with our coding standards in SRE Bukalapak.
