# ADR 0001: Use PostgreSQL as the Database

## Context
We need a database to store the application's information. It must be robust, scalable, and support complex transactions well.

## Decision
We have decided to use PostgreSQL as the main database for our application.

## Consequences
- Benefits:
    - PostgreSQL is open-source and free.
    - It supports complex transactions and advanced SQL queries.
    - Good scalability and performance.
- Drawbacks:
    - Learning curve for developers unfamiliar with PostgreSQL.
    - Need to configure and maintain backups and replication.

## Alternatives Considered
- MySQL: Less performant for complex transactions.
- MongoDB: Non-relational, less suited to our current needs.
