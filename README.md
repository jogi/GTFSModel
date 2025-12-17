# GTFSModel

A Swift package providing data models and database schema for GTFS (General Transit Feed Specification) transit data.

## Features

- Complete Swift data models for all GTFS entities
- SQLite persistence using GRDB
- Type-safe database schema following GTFS specification
- GRDB associations for relational queries
- Date/time formatters for GTFS formats
- Database maintenance utilities (vacuum, reindex)

## Requirements

- Swift 5.5+
- macOS 11+ or iOS 12+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/jogi/GTFSModel", .branch("main"))
]
```

## Entities

GTFSModel provides Swift types for all standard GTFS entities:

- `Agency` - Transit agency information
- `Calendar` - Service calendar (which days services run)
- `CalendarDate` - Calendar exceptions (added/removed service days)
- `Route` - Transit routes
- `Trip` - Individual trip instances
- `Stop` - Stop/station locations
- `StopTime` - Arrival/departure times for each stop on each trip
- `Shape` - Geographic paths for routes
- `FareAttribute` - Fare pricing information
- `FareRule` - Rules for applying fares
- `Direction` - Route direction metadata (extension)

## Usage

```swift
import GTFSModel
import GRDB

// Create database
let dbQueue = try DatabaseQueue(path: "gtfs.db")

// Create tables
try dbQueue.write { db in
    try Agency.createTable(db: db)
    try Route.createTable(db: db)
    // ... other tables
}

// Query data
let routes = try dbQueue.read { db in
    try Route.fetchAll(db)
}

// Use associations
let route = try Route.fetchOne(db, key: "101")
let trips = try route?.trips.fetchAll(db)
```

## Database Schema

All entities conform to:
- `DatabaseCreating` - Create database table
- `Codable` - Swift encoding/decoding
- `PersistableRecord` - Save to database
- `FetchableRecord` - Load from database
- `Hashable` - Enable diffing and comparison

Schema follows the official [GTFS Schedule Reference](https://gtfs.org/documentation/schedule/reference/) specification.

## Dependencies

- [GRDB](https://github.com/groue/GRDB.swift) - SQLite toolkit

## Documentation

See [CLAUDE.md](CLAUDE.md) for detailed architecture, schema design, and implementation notes.
