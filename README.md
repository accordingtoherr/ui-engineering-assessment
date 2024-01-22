# Threeflow Full-Stack Challenge - Front-end

## Front-end
- `/fe` directory
### Requirements
- node v20

## Back-end
- `/be`
### Requirements
- rails v7
- sqlite3

## Getting started
- run `bash setup.sh`
  - this will reinstall everything, overwriting data in the DB
- run `bash start_server.sh`
  - this will start both servers and should open the browser

### TODO
- add owner column to events table
- add description column to events table
- endpoint to retrieve owned events
- endpoint for past events?
- endpoint for sign-in (look up user by email)
- fix new event form validation
- create "add attendee" workflow