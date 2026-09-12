import GRDB
import Testing

@testable import GTFSModel

struct SchemaContractTests {
    @Test(
        "Declared primary keys match record identity",
        arguments: [
            ("agency", ["agency_id"]), ("routes", ["route_id"]), ("stops", ["stop_id"]),
            ("trips", ["trip_id"]), ("calendar", ["service_id"]),
            ("directions", ["direction_id", "route_id"]), ("fare_attributes", ["fare_id"]),
        ])
    func identity(table: String, columns: [String]) throws {
        let queue = try modelDatabase()
        defer { try? queue.close() }
        try queue.read { (db: Database) throws -> Void in
            #expect(try db.primaryKey(table).columns == columns)
        }
    }

    @Test("Trip and stop-time schema declares its referential constraints")
    func foreignKeys() throws {
        let queue = try modelDatabase()
        defer { try? queue.close() }
        try queue.read { (db: Database) throws -> Void in
            let trips = try db.foreignKeys(on: "trips")
            #expect(trips.map(\.destinationTable) == ["routes"])
            #expect(trips.flatMap(\.originColumns) == ["route_id"])
            #expect(trips.flatMap(\.destinationColumns) == ["route_id"])
            let stopTimes = try db.foreignKeys(on: "stop_times")
            let mappings = stopTimes.flatMap { key in
                key.mapping.map { "\($0.origin)->\(key.destinationTable).\($0.destination)" }
            }
            #expect(Set(mappings) == ["trip_id->trips.trip_id", "stop_id->stops.stop_id"])
        }
    }

    @Test(
        "Geographic and lookup indexes cover the columns queried by clients",
        arguments: [
            ("stops", ["stop_lat", "stop_lon"]), ("trips", ["route_id", "service_id"]),
            ("stop_times", ["trip_id", "stop_id"]), ("shapes", ["shape_id"]), ("calendar_dates", ["service_id"]),
        ])
    func indexes(table: String, expected: [String]) throws {
        let queue = try modelDatabase()
        defer { try? queue.close() }
        try queue.read { (db: Database) throws -> Void in
            let indexes = try db.indexes(on: table).map(\.columns)
            for column in expected { #expect(indexes.contains([column])) }
        }
    }

    @Test("Route associations select matching trips and decode joined TripInfo")
    func associations() throws {
        let queue = try modelDatabase()
        defer { try? queue.close() }
        try queue.write { (db: Database) throws -> Void in
            try db.execute(
                sql: """
                    INSERT INTO routes (route_id, route_type) VALUES ('OTHER', 0);
                    INSERT INTO trips (trip_id,route_id,service_id) VALUES ('U','R','S'), ('V','OTHER','S');
                    """)
            let route = try #require(try Route.fetchOne(db, key: "R"))
            #expect(try route.trips.fetchAll(db).map(\.identifier).sorted() == ["T", "U"])
            let trip = try #require(try Trip.fetchOne(db, key: "V"))
            #expect(try trip.route.fetchOne(db)?.identifier == "OTHER")
            let joined = try TripInfo.fetchAll(db, Trip.including(required: Trip.route))
            #expect(
                joined.map { "\($0.trip.identifier):\($0.route.identifier)" }.sorted() == ["T:R", "U:R", "V:OTHER"])
        }
    }
}

func modelDatabase() throws -> DatabaseQueue {
    let queue = try DatabaseQueue()
    try queue.write { (db: Database) throws -> Void in
        try Agency.createTable(db: db)
        try GTFSModel.Calendar.createTable(db: db)
        try CalendarDate.createTable(db: db)
        try Direction.createTable(db: db)
        try FareAttribute.createTable(db: db)
        try FareRule.createTable(db: db)
        try Route.createTable(db: db)
        try Shape.createTable(db: db)
        try Stop.createTable(db: db)
        try Trip.createTable(db: db)
        try StopTime.createTable(db: db)
        try db.execute(
            sql: """
                INSERT INTO routes (route_id, route_type) VALUES ('R',3);
                INSERT INTO trips (trip_id, route_id, service_id) VALUES ('T','R','S');
                INSERT INTO stops (stop_id,stop_lat,stop_lon,location_type,wheelchair_boarding) VALUES ('A',0,0,0,0);
                """)
    }
    return queue
}
