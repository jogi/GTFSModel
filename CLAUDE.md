# CLAUDE.md - GTFSModel

## Project Overview

GTFSModel is a Swift package that provides data models and database schema for GTFS (General Transit Feed Specification) transit data. It uses GRDB (SQLite) for persistence and follows the official GTFS specification for field types and relationships.

## Architecture

### Project Structure

```
GTFSModel/
├── Sources/GTFSModel/
│   ├── Models/
│   │   ├── Agency.swift           # Transit agency
│   │   ├── Calendar.swift         # Service calendar
│   │   ├── CalendarDate.swift     # Calendar exceptions
│   │   ├── Direction.swift        # Route directions (extension)
│   │   ├── FareAttribute.swift    # Fare information
│   │   ├── FareRule.swift         # Fare application rules
│   │   ├── Route.swift            # Transit routes
│   │   ├── Shape.swift            # Route geographic paths
│   │   ├── Stop.swift             # Stops/stations
│   │   ├── StopTime.swift         # Stop arrival/departure times
│   │   └── Trip.swift             # Individual trip instances
│   ├── Utilities/
│   │   └── Database.swift         # Database helpers (vacuum, reindex)
│   └── Extensions/
│       ├── DateFormatter.swift    # GTFS date/time formatters
│       └── Logger.swift           # OSLog configuration
└── Package.swift                  # Swift Package Manager config
```

### Core Protocols

#### `DatabaseCreating`
Protocol for entities that can create their database table:
```swift
public protocol DatabaseCreating {
    static func createTable(db: Database) throws
}
```

All GTFS entities conform to this protocol to define their schema.

#### GRDB Protocols
Each entity conforms to:
- `Codable`: Swift encoding/decoding
- `PersistableRecord`: Save to database
- `FetchableRecord`: Load from database
- `Hashable`: Enable diffing and comparison

## Entity Models

### Agency
Transit agency information (typically one per feed).

**Properties:**
- `identifier`: Agency ID (primary key)
- `name`: Full agency name
- `url`: Agency website
- `timezone`: Timezone (e.g., "America/Los_Angeles")
- `language`: Two-letter ISO 639-1 code (optional)
- `phone`: Voice phone number (optional)
- `fareURL`: Fare information URL (optional)
- `email`: Customer service email (optional)

### Calendar
Service calendar defining which days services operate.

**Properties:**
- `serviceIdentifier`: Service ID (primary key)
- `startDate`: First date of service
- `endDate`: Last date of service
- `monday` through `sunday`: Availability enum (available/unavailable)

**Date Format:** YYYY-MM-DD with dashes

### CalendarDate
Exceptions to the regular service calendar (added or removed service days).

**Properties:**
- `serviceIdentifier`: References calendar.service_id
- `date`: Exception date
- `exceptionType`: Added (1) or Removed (2)

### Direction
Extended GTFS field for route directions (not in standard spec).

**Properties:**
- `directionIdentifier`: Direction ID (0 or 1)
- `routeIdentifier`: References routes.route_id
- `direction`: Direction code
- `directionName`: Human-readable direction name

**Composite Primary Key:** (direction_id, route_id)

### FareAttribute
Fare pricing information.

**Properties:**
- `identifier`: Fare ID (primary key)
- `price`: Fare price (Float)
- `currencyType`: ISO 4217 currency code
- `paymentMethod`: OnBoard (0) or BeforeBoarding (1)
- `transfers`: Allowed transfers enum
- `agencyIdentifier`: Agency ID (optional)
- `transferDuration`: Transfer window in seconds (optional)

### FareRule
Rules for applying fares to routes and zones.

**Properties:**
- `fareIdentifier`: References fare_attributes.fare_id
- `routeIdentifier`: Route ID (optional)
- `originIdentifier`: Origin zone ID (optional)
- `destinationIdentifier`: Destination zone ID (optional)
- `containsIdentifier`: Contains zone ID (optional)

**Note:** All fields except fare_id are optional (allows flexible fare rules).

### Route
Transit routes (bus lines, rail lines, etc.).

**Properties:**
- `identifier`: Route ID (primary key)
- `type`: Route type enum (bus=3, rail=2, etc.)
- `agencyIdentifier`: References agency.agency_id
- `shortName`: Short route name (e.g., "22")
- `longName`: Full route name (e.g., "Palo Alto TC - Eastridge")
- `routeDescription`: Route description (optional)
- `url`: Route URL (optional)
- `color`: Route color hex code (optional)
- `textColor`: Text color hex code (optional)
- `sortOrder`: Display order (optional, integer)
- `continuousPickup`: Continuous pickup enum (optional)
- `continuousDropoff`: Continuous drop-off enum (optional)

**Type Enums:**
- 0=Tram, 1=Subway, 2=Rail, 3=Bus, 4=Ferry, 5=Cable Tram, 6=Aerial Lift, 7=Funicular, 11=Trolleybus, 12=Monorail

### Shape
Geographic coordinates defining route paths.

**Properties:**
- `identifier`: Shape ID
- `latitude`: Point latitude
- `longitude`: Point longitude
- `sequence`: Point sequence number
- `distanceTraveled`: Distance from first point (optional)

**Note:** No primary key; use (shape_id, sequence) for uniqueness.

### Stop
Stops, stations, entrances, and boarding areas.

**Properties:**
- `identifier`: Stop ID (primary key)
- `code`: Short stop code (optional)
- `name`: Stop name (optional)
- `stopDescription`: Stop description (optional)
- `latitude`: Stop latitude (required)
- `longitude`: Stop longitude (required)
- `zoneIdentifier`: Fare zone ID (optional)
- `locationType`: Location type enum (Stop=0, Station=1, etc.)
- `parentStation`: Parent station ID (optional)
- `timezone`: Stop timezone (optional)
- `wheelchairBoarding`: Wheelchair accessibility enum
- `levelIdentifier`: Level ID (optional)
- `platformCode`: Platform identifier (optional)
- `routes`: Comma-separated route list (optional, added by importer)

**Indexes:** Geographic indexes on latitude and longitude for proximity queries.

### StopTime
Arrival and departure times for stops on each trip.

**Properties:**
- `tripIdentifier`: References trips.trip_id
- `arrivalTime`: Arrival time (HH:MM:SS format)
- `departureTime`: Departure time (HH:MM:SS format)
- `stopIdentifier`: References stops.stop_id
- `stopSequence`: Stop order on trip
- `stopHeadsign`: Headsign override (optional)
- `pickupType`: Pickup method enum (optional)
- `dropoffType`: Drop-off method enum (optional)
- `continuousPickup`: Continuous pickup enum (optional)
- `continuousDropoff`: Continuous drop-off enum (optional)
- `shapeDistanceTraveled`: Distance along shape (optional)
- `timepoint`: Exact (1) or Approximate (0) time (optional)
- `isLastStop`: Last stop flag (optional)

**Time Format:** HH:MM:SS, values >24:00:00 allowed for times after midnight

**Note:** No explicit primary key; use (trip_id, stop_sequence) for uniqueness.

### Trip
Individual trip instances.

**Properties:**
- `identifier`: Trip ID (primary key)
- `routeIdentifier`: References routes.route_id (foreign key)
- `serviceIdentifier`: References calendar.service_id (foreign key)
- `headSign`: Trip destination sign (optional)
- `shortName`: Trip short name (optional)
- `directionIdentifier`: Direction (0 or 1) (optional)
- `blockIdentifier`: Block ID for linked trips (optional)
- `shapeIdentifier`: References shapes.shape_id (optional)
- `wheelchairAccessible`: Wheelchair accessibility enum (optional)
- `bikesAllowed`: Bike allowance enum (optional)

## Database Schema Design

### Type Mapping

GRDB/SQLite types are chosen to match GTFS specification:

| GTFS Type | Swift Type | SQLite Type | Example |
|-----------|-----------|-------------|---------|
| ID | String | TEXT | "VTA", "101" |
| Text | String | TEXT | "Bus Station" |
| URL | URL | TEXT | "https://..." |
| Email | String | TEXT | "email@..." |
| Phone | String | TEXT | "408-123-4567" |
| Color | String | TEXT | "FF0000" |
| Timezone | String | TEXT | "America/Los_Angeles" |
| Language | String | TEXT | "EN" |
| Currency | String | TEXT | "USD" |
| Latitude | Double | DOUBLE | 37.353055 |
| Longitude | Double | DOUBLE | -121.936671 |
| Integer | Int/UInt | INTEGER | 0, 1, 2 |
| Non-negative integer | Int | INTEGER | 101, 102 |
| Float | Float | DOUBLE | 2.50 |
| Date | Date | DATE | "2025-12-17" |
| Time | Date | TEXT | "06:13:00" |
| Enum | Int | INTEGER | 0, 1, 2, 3 |

**Important:**
- **Time fields use TEXT**, not a custom TIME type (SQLite has no native time type)
- **Enums use INTEGER** for GTFS enum fields (0, 1, 2, 3 values)
- **Non-negative integers use INTEGER**, not TEXT (per GTFS spec)

### Column Order

Columns are ordered naturally following the struct definition:
1. Identifier/primary key first
2. Required fields
3. Optional fields
4. Extended/custom fields last

**Why not "legacy order"?** Natural ordering improves:
- Code readability (schema matches struct)
- Maintainability (easier to understand)
- No compatibility issues (apps query by column name, not position)

### Constraints

#### NOT NULL Constraints
Applied only to fields marked "Required" in GTFS spec:
- Primary keys
- Foreign keys when relationships are required
- Fields that must have values per spec

Optional GTFS fields are nullable in the database.

#### PRIMARY KEY
Set on identifier fields for uniqueness and indexing.

#### FOREIGN KEY
Set on reference fields to enforce referential integrity:
- `trips.route_id` → `routes.route_id`
- `trips.service_id` → `calendar.service_id`
- `stop_times.trip_id` → `trips.trip_id`
- `stop_times.stop_id` → `stops.stop_id`

### Indexes

Indexes are created for:
1. **Foreign keys**: Automatically indexed by GRDB
2. **Geographic queries**: `stops.stop_lat`, `stops.stop_lon`
3. **Frequent lookups**: `shapes.shape_id`, `calendar_dates.service_id`

**Index Naming Convention:** `{table}_on_{column}` (e.g., `stops_on_stop_lat`)

## Date/Time Handling

### Date Format
GTFS uses YYYY-MM-DD format with dashes.

```swift
extension DateFormatter {
    static var yyyyMMddDash: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }
}
```

### Time Format
GTFS uses HH:MM:SS format (H:MM:SS also accepted).

```swift
extension DateFormatter {
    static var hhmmss: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }
}
```

**Note:** Times can exceed 24:00:00 (e.g., "25:30:00" = 1:30 AM next day).

## Relationships

### GRDB Associations

```swift
// Route has many trips
extension Route {
    public static let trips = hasMany(Trip.self)
    public var trips: QueryInterfaceRequest<Trip> {
        request(for: Route.trips)
    }
}

// Trip belongs to route
extension Trip {
    public static let route = belongsTo(Route.self)
    public var route: QueryInterfaceRequest<Route> {
        request(for: Trip.route)
    }
}
```

### Query Examples

```swift
// Get all trips for a route
let route = try Route.fetchOne(db, key: "101")
let trips = try route?.trips.fetchAll(db)

// Get route for a trip (with join)
struct TripInfo: Decodable, FetchableRecord {
    var route: Route
    var trip: Trip
}

let tripInfos = try Trip
    .including(required: Trip.route)
    .asRequest(of: TripInfo.self)
    .fetchAll(db)
```

## Adding New Entities

To add a new GTFS entity:

1. **Create Model File** in `Sources/GTFSModel/Models/`:

```swift
public struct NewEntity {
    public var identifier: String
    public var name: String
    // ... other properties
}

extension NewEntity: Hashable {}

extension NewEntity: Codable, PersistableRecord, FetchableRecord {
    public static var databaseTableName = "new_entities"

    public enum CodingKeys: String, CodingKey {
        case identifier = "entity_id"
        case name = "entity_name"
    }
}

extension NewEntity: DatabaseCreating {
    public static func createTable(db: Database) throws {
        try db.drop(table: NewEntity.databaseTableName)

        try db.create(table: NewEntity.databaseTableName) { t in
            t.column(CodingKeys.identifier.rawValue, .text).notNull().primaryKey()
            t.column(CodingKeys.name.rawValue, .text)
        }
    }
}
```

2. **Add to GTFSImporter** if it needs CSV import
3. **Update tests** if applicable

## Database Utilities

### DatabaseHelper

Provides utility functions for database maintenance:

```swift
let helper = try DatabaseHelper(path: "./gtfs.db")

// Optimize database
try helper.vacuum()

// Rebuild indexes
try helper.reindex()
```

## GTFS Specification Compliance

This package follows the official GTFS specification:
- [GTFS Schedule Reference](https://gtfs.org/documentation/schedule/reference/)

### Key Compliance Points

1. **Field Types**: All fields use types specified in GTFS docs
2. **Required Fields**: Match GTFS "Required" designation
3. **Optional Fields**: Match GTFS "Optional" designation
4. **Enum Values**: Use exact integer values from spec
5. **File Names**: CSV column names match GTFS snake_case
6. **Relationships**: Foreign keys match GTFS references

### Deviations

- **Direction**: Extended field not in standard GTFS (used by some agencies)
- **Stop.routes**: Computed field for denormalized route list (added by importer)

## Testing Strategy

### Compatibility Testing
Compare against legacy database output:
1. Import same GTFS feed with legacy and new code
2. Query data by column name (not position)
3. Verify identical values for all common columns
4. Check that new columns don't break legacy queries

### Type Testing
Verify types against GTFS specification:
1. Check integer fields accept GTFS integer values
2. Check text fields accept GTFS text values
3. Verify enum fields only accept valid enum values
4. Test date/time parsing with GTFS formats

## Performance Considerations

### Indexing Strategy
- Index all foreign keys (automatically done by GRDB)
- Index columns used in WHERE clauses (service_id, shape_id)
- Index geographic columns for proximity queries (lat, lon)
- Avoid over-indexing (slows writes, increases database size)

### Bulk Operations
For importing large datasets:
- Use transactions for multiple inserts
- Vacuum after bulk imports
- Reindex after schema changes

### Query Optimization
- Use GRDB's type-safe query builder
- Leverage associations for joins
- Fetch only needed columns
- Use lazy fetching for large result sets

## Common Issues

### Foreign Key Violations
If inserts fail with foreign key errors:
- Ensure parent records exist before inserting children
- Import in dependency order: Agency → Routes → Trips → StopTimes

### Date Parsing Errors
If date parsing fails:
- Verify CSV uses YYYY-MM-DD format
- Check for invalid dates (e.g., "2025-02-30")
- Ensure locale is set to POSIX

### Time Format Issues
If time parsing fails:
- Accept both HH:MM:SS and H:MM:SS
- Allow times > 24:00:00 for next-day service
- Store as TEXT, not DATE or custom TIME type

## Future Enhancements

Potential improvements:
- [ ] Add GTFS-Realtime support
- [ ] Add validation against GTFS spec
- [ ] Add GTFS Pathways support (accessibility)
- [ ] Add GTFS Flex support (demand-responsive transit)
- [ ] Generate Swift types from GTFS JSON schema
- [ ] Add migration system for schema changes
