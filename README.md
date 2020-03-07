# Project

A authentication, authorization and simple CRUD operations with PostGraphile, tool which creating a GraphQL server from a PostgreSQL schema.

# How to run

1. `git clone` this repo
2. `npm install`
3. Ensure you have a PostgreSQL server running somewhere. If you don't, start one.
   - E.g.: `docker run --restart=always -p 5432:5432 --name postgres -e POSTGRES_PASSWORD=password -d postgres`
4. Create a `.env` file and paste info from `.env-example` there
5. Load the contents of `dbinit.sql` into your PostgreSQL server
   - E.g.: `psql -h localhost -U postgres -f provision.sql`
6. Start the server
   - `npm start`
7. open in browser http://localhost:3000/graphiql

## Create a user

2. Register a user via GraphQL mutation
   - e.g.

```
mutation {
  registerUser(input: {
    name: "anton"
    email: "anton@gmail.com"
    password: "anton"
  }) {
    user {
      id
      name
      createdAt
    }
  }
}
```

3. Observe the response
   - e.g.

```
{
  "data": {
    "registerUser": {
      "user": {
        "id": 1,
        "name": "anton",
        "createdAt": "2020-03-07T09:49:30.451085"
      }
    }
  }
}
```

# Observe authentication working

4. Try authenticating with a different GraphQL mutation
   - e.g.

```
mutation {
  authenticate(input: {
    email: "anton@gmail.com"
    password: "anton"
  }) {
    jwtToken
  }
}
```

5. Observe the response
   - e.g.:

```
{
  "data": {
    "authenticate": {
      "jwtToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYXV0aF9hdXRoZW50aWNhdGVkIiwidXNlcl9pZCI6MSwiaWF0IjoxNTgzNTc0NjE1LCJleHAiOjE1ODM2NjEwMTUsImF1ZCI6InBvc3RncmFwaGlsZSIsImlzcyI6InBvc3RncmFwaGlsZSJ9.0luUnNN9MY_jxewEfAHvvPS-IFoVHUaeUt5xiCh_oWA"
    }
  }
}
```

## Try making an unauthenticated request when authentication is necessary

6. `currentUser` is protected, so query that

```
query {
  currentUser{
    id
    name
    createdAt
  }
}
```

7. Observe the not-particularly-friendly response

```
{
  "errors": [
    {
      "message": "permission denied for function current_user_id",
      "locations": [
        {
          "line": 2,
          "column": 3
        }
      ],
      "path": [
        "currentUser"
      ]
    }
  ],
  "data": {
    "currentUser": null
  }
}
```

8. or try to create task

```
mutation {
  createtask(input: {description: "test task"}) {
    task {
      description
      id
      createdAt
    }
  }
}
```

9. response

```
{
  "errors": [
    {
      "message": "permission denied for function createtask",
      "locations": [
        {
          "line": 2,
          "column": 3
        }
      ],
      "path": [
        "createtask"
      ]
    }
  ],
  "data": {
    "createtask": null
  }
}
```

## Try making an authenticated request when authentication is necessary

10. You'll need the ability to send your JWT to the server, which unfortunately isn't possible with vanilla Graph<i>i</i>QL.

- If you're in Chrome you can try [ModHeader](https://chrome.google.com/webstore/detail/modheader/idgpnmonknjnojddfkpgkljpfnnfcklj/related)

11. Set an authorization header by copy/pasting the value out of the `jwt` field in the `authenticate` response in step 5.

- `Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYXV0aF9hdXRoZW50aWNhdGVkIiwidXNlcl9pZCI6MSwiaWF0IjoxNDk3MTYwNzA3LCJleHAiOjE0OTcyNDcxMDcsImF1ZCI6InBvc3RncmFwaHFsIiwiaXNzIjoicG9zdGdyYXBocWwifQ.aInZvEVhhDfi9yQDWRzvmSaE7Mk2PufbBrY3rxGlEt8`
- Don't forget the `Bearer` on the right side of the header, otherwise you'll likely see `Authorization header is not of the correct bearer scheme format.`

12. Submit the query with the authorization header attached

````

mutation {
  createtask(input: {description: "test task"}) {
    task {
      description
      id
      createdAt
    }
  }
}

```

11. Observe your now successful response

```

{
  "data": {
    "createtask": {
      "task": {
        "description": "test task",
        "id": 2,
        "createdAt": "2020-03-07T10:13:47.804621"
      }
    }
  }
}

```



# Features plans?

Add customs functions to update and delete tasks (not autogenerated like now)
Add passport into project (for now this is build-in postgre jwt tokens used)
```
````
