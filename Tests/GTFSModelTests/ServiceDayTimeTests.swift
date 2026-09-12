import Foundation
import GRDB
import Testing

@testable import GTFSModel

struct ServiceDayTimeTests {
    @Test("Service-day times preserve extended hours", arguments: [
        ("0:00:00", "00:00:00", 0),
        ("23:59:59", "23:59:59", 86399),
        ("24:03:14", "24:03:14", 86594),
        ("25:30:00", "25:30:00", 91800),
        ("49:00:00", "49:00:00", 176400),
        ("99:59:59", "99:59:59", 359999),
    ])
    func roundTrip(input: String, canonical: String, seconds: Int) throws {
        let date = try #require(ServiceDayTime.date(from: input))
        #expect(date.timeIntervalSince(ServiceDayTime.referenceDate) == Double(seconds))
        #expect(ServiceDayTime.string(from: date) == canonical)
    }

    @Test("Malformed times do not trap", arguments: ["", "-1:00:00", "24:60:00", "24:00:60", "12:00", "a:00:00", "9223372036854775807:00:00"])
    func invalid(input: String) {
        #expect(ServiceDayTime.date(from: input) == nil)
    }

    @Test("Existing clock dates retain their original representation")
    func clockCompatibility() throws {
        let date = try #require(DateFormatter.hhmmss.date(from: "08:15:30"))
        #expect(ServiceDayTime.string(from: date) == "08:15:30")
        #expect(ServiceDayTime.date(from: "08:15:30") == date)
    }

    @Test("Reading and updating a StopTime does not wrap overnight times")
    func persistence() throws {
        let queue = try DatabaseQueue()
        defer { try? queue.close() }
        try queue.write { db in
            try Route.createTable(db: db)
            try Trip.createTable(db: db)
            try Stop.createTable(db: db)
            try StopTime.createTable(db: db)
            try db.execute(sql: """
                INSERT INTO routes(route_id,route_type) VALUES ('R',3);
                INSERT INTO trips(trip_id,route_id,service_id) VALUES ('T','R','S');
                INSERT INTO stops(stop_id,stop_lat,stop_lon,location_type,wheelchair_boarding) VALUES ('A',0,0,0,0);
                INSERT INTO stop_times(trip_id,stop_id,stop_sequence,arrival_time,departure_time)
                VALUES ('T','A',1,'24:03:14','49:00:00');
                """)
            let record = try #require(try StopTime.fetchOne(db))
            #expect(record.arrivalTime.timeIntervalSince(ServiceDayTime.referenceDate) == 86594)
            #expect(record.departureTime.timeIntervalSince(ServiceDayTime.referenceDate) == 176400)
            try db.execute(sql: "DELETE FROM stop_times")
            try record.insert(db)
            #expect(try String.fetchOne(db, sql: "SELECT arrival_time FROM stop_times") == "24:03:14")
            #expect(try String.fetchOne(db, sql: "SELECT departure_time FROM stop_times") == "49:00:00")
        }
    }
}
