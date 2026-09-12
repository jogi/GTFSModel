import Foundation
import GRDB
import Testing

@testable import GTFSModel

struct PersistenceContractTests {
    @Test("Agency maps model properties to GTFS storage", arguments: [false, true])
    func agency(populated: Bool) throws {
        let record = Agency(
            identifier: "A",
            name: "Transit",
            url: URL(string: "https://example.com")!,
            timezone: "America/Los_Angeles",
            language: populated ? "en" : nil,
            phone: populated ? "123" : nil,
            fareURL: populated ? URL(string: "https://example.com/fares")! : nil,
            email: populated ? "hello@example.com" : nil
        )
        try verify(
            record, table: "agency",
            expected: [
                "agency_id": "A",
                "agency_name": "Transit",
                "agency_url": "https://example.com",
                "agency_timezone": "America/Los_Angeles",
                "agency_lang": populated ? "en" : nil,
                "agency_phone": populated ? "123" : nil,
                "agency_fare_url": populated ? "https://example.com/fares" : nil,
                "agency_email": populated ? "hello@example.com" : nil,
            ])
    }

    @Test("Route maps model properties to GTFS storage", arguments: [false, true])
    func route(populated: Bool) throws {
        let record = Route(
            identifier: "X",
            type: .bus,
            agencyIdentifier: populated ? "A" : nil,
            shortName: populated ? "Red" : nil,
            longName: populated ? "Downtown" : nil,
            routeDescription: populated ? "Express" : nil,
            url: populated ? URL(string: "https://example.com/route")! : nil,
            color: populated ? "123456" : nil,
            textColor: populated ? "ABCDEF" : nil,
            sortOrder: populated ? 7 : nil,
            continuousPickup: populated ? .phoneAgencyToArrange : nil,
            continuousDropoff: populated ? .coordinateWithDriver : nil
        )
        try verify(
            record, table: "routes",
            expected: [
                "route_id": "X",
                "route_type": 3,
                "agency_id": populated ? "A" : nil,
                "route_short_name": populated ? "Red" : nil,
                "route_long_name": populated ? "Downtown" : nil,
                "route_desc": populated ? "Express" : nil,
                "route_url": populated ? "https://example.com/route" : nil,
                "route_color": populated ? "123456" : nil,
                "route_text_color": populated ? "ABCDEF" : nil,
                "route_sort_order": populated ? 7 : nil,
                "continuous_pickup": populated ? 2 : nil,
                "continuous_drop_off": populated ? 3 : nil,
            ])
    }

    @Test("Trip maps model properties to GTFS storage", arguments: [false, true])
    func trip(populated: Bool) throws {
        let record = Trip(
            identifier: "X",
            routeIdentifier: "R",
            serviceIdentifier: "S",
            headSign: populated ? "Downtown" : nil,
            shortName: populated ? "Express" : nil,
            directionIdentifier: populated ? 1 : nil,
            blockIdentifier: populated ? "BLOCK" : nil,
            shapeIdentifier: populated ? "SHAPE" : nil,
            wheelchairAccessible: populated ? .accessible : nil,
            bikesAllowed: populated ? .notAllowed : nil
        )
        try verify(
            record, table: "trips",
            expected: [
                "trip_id": "X",
                "route_id": "R",
                "service_id": "S",
                "trip_headsign": populated ? "Downtown" : nil,
                "trip_short_name": populated ? "Express" : nil,
                "direction_id": populated ? 1 : nil,
                "block_id": populated ? "BLOCK" : nil,
                "shape_id": populated ? "SHAPE" : nil,
                "wheelchair_accessible": populated ? 1 : nil,
                "bikes_allowed": populated ? 2 : nil,
            ])
    }

    @Test("Stop maps model properties to GTFS storage", arguments: [false, true])
    func stop(populated: Bool) throws {
        let record = Stop(
            identifier: "X",
            code: populated ? "42" : nil,
            name: populated ? "Central" : nil,
            stopDescription: populated ? "North platform" : nil,
            latitude: 37.25,
            longitude: -121.5,
            zoneIdentifier: populated ? "Z" : nil,
            locationType: .station,
            parentStation: populated ? "P" : nil,
            timezone: populated ? "America/Los_Angeles" : nil,
            wheelchairBording: .partiallyAccessible,
            levelIdentifier: populated ? "L" : nil,
            platformCode: populated ? "PL" : nil,
            routes: populated ? "Red, Green" : nil
        )
        try verify(
            record, table: "stops",
            expected: [
                "stop_id": "X",
                "stop_code": populated ? "42" : nil,
                "stop_name": populated ? "Central" : nil,
                "stop_desc": populated ? "North platform" : nil,
                "stop_lat": 37.25,
                "stop_lon": -121.5,
                "zone_id": populated ? "Z" : nil,
                "location_type": 1,
                "parent_station": populated ? "P" : nil,
                "stop_timezone": populated ? "America/Los_Angeles" : nil,
                "wheelchair_boarding": 1,
                "level_id": populated ? "L" : nil,
                "platform_code": populated ? "PL" : nil,
                "routes": populated ? "Red, Green" : nil,
            ])
    }

    @Test("Shape maps model properties to GTFS storage", arguments: [false, true])
    func shape(populated: Bool) throws {
        let record = Shape(
            identifier: "SHAPE",
            latitude: 37.25,
            longitude: -121.5,
            sequence: 7,
            distanceTraveled: populated ? 12.5 : nil
        )
        try verify(
            record, table: "shapes",
            expected: [
                "shape_id": "SHAPE",
                "shape_pt_lat": 37.25,
                "shape_pt_lon": -121.5,
                "shape_pt_sequence": 7,
                "shape_dist_traveled": populated ? 12.5 : nil,
            ])
    }

    @Test("Direction maps model properties to GTFS storage", arguments: [false, true])
    func direction(populated: Bool) throws {
        let record = Direction(
            identifier: 1,
            routeIdentifier: "R",
            direction: .northEast,
            name: populated ? "Airport" : nil
        )
        try verify(
            record, table: "directions",
            expected: [
                "direction_id": 1,
                "route_id": "R",
                "direction": "Northeast",
                "direction_name": populated ? "Airport" : nil,
            ])
    }

    @Test("FareAttribute maps model properties to GTFS storage", arguments: [false, true])
    func fareAttribute(populated: Bool) throws {
        let record = FareAttribute(
            identifier: "FARE",
            price: 2.5,
            currencyType: "USD",
            paymentMethod: .paidBeforeBoarding,
            transfers: .unlimited,
            agencyIdentifier: populated ? "A" : nil,
            transferDuration: populated ? 3600 : nil
        )
        try verify(
            record, table: "fare_attributes",
            expected: [
                "fare_id": "FARE",
                "price": 2.5,
                "currency_type": "USD",
                "payment_method": 1,
                "transfers": -1,
                "agency_id": populated ? "A" : nil,
                "transfer_duration": populated ? 3600 : nil,
            ])
    }

    @Test("FareRule maps model properties to GTFS storage", arguments: [false, true])
    func fareRule(populated: Bool) throws {
        let record = FareRule(
            fareIdentifier: "FARE",
            routeIdentifier: populated ? "R" : nil,
            originIdentifier: populated ? "O" : nil,
            destinationIdentifier: populated ? "D" : nil,
            containsIdentifier: populated ? "C" : nil
        )
        try verify(
            record, table: "fare_rules",
            expected: [
                "fare_id": "FARE",
                "route_id": populated ? "R" : nil,
                "origin_id": populated ? "O" : nil,
                "destination_id": populated ? "D" : nil,
                "contains_id": populated ? "C" : nil,
            ])
    }

    @Test("GTFSModel.Calendar maps model properties to GTFS storage")
    func calendar() throws {
        let record = GTFSModel.Calendar(
            serviceIdentifier: "S",
            startDate: Date(timeIntervalSince1970: 1_704_096_000),
            endDate: Date(timeIntervalSince1970: 1_704_182_400),
            monday: .available,
            tuesday: .unavailable,
            wednesday: .available,
            thursday: .unavailable,
            friday: .available,
            saturday: .unavailable,
            sunday: .available
        )
        try verify(
            record, table: "calendar",
            expected: [
                "service_id": "S",
                "start_date": "2024-01-01",
                "end_date": "2024-01-02",
                "monday": 1,
                "tuesday": 0,
                "wednesday": 1,
                "thursday": 0,
                "friday": 1,
                "saturday": 0,
                "sunday": 1,
            ])
    }

    @Test("CalendarDate maps model properties to GTFS storage")
    func calendarDate() throws {
        let record = CalendarDate(
            serviceIdentifier: "S",
            date: Date(timeIntervalSince1970: 1_704_096_000),
            exceptionType: .removed
        )
        try verify(
            record, table: "calendar_dates",
            expected: [
                "service_id": "S",
                "date": "2024-01-01",
                "exception_type": 2,
            ])
    }

    @Test("StopTime maps model properties to GTFS storage", arguments: [false, true])
    func stopTime(populated: Bool) throws {
        let record = StopTime(
            tripIdentifier: "T",
            arrivalTime: clockDate(hour: 8, minute: 15),
            departureTime: clockDate(hour: 8, minute: 16),
            stopIdentifier: "A",
            stopSequence: 7,
            stopHeadsign: populated ? "Central" : nil,
            pickupType: populated ? .phoneAgency : nil,
            dropoffType: populated ? .coordinateWithDriver : nil,
            continuousPickup: populated ? .continuous : nil,
            continuousDropoff: populated ? .phoneAgencyToArrange : nil,
            shapeDistanceTraveled: populated ? 12.5 : nil,
            timepoint: populated ? .approximate : nil,
            isLastStop: populated ? true : nil
        )
        try verify(
            record, table: "stop_times",
            expected: [
                "trip_id": "T",
                "arrival_time": "08:15:00",
                "departure_time": "08:16:00",
                "stop_id": "A",
                "stop_sequence": 7,
                "stop_headsign": populated ? "Central" : nil,
                "pickup_type": populated ? 2 : nil,
                "drop_off_type": populated ? 3 : nil,
                "continuous_pickup": populated ? 0 : nil,
                "continuous_drop_off": populated ? 2 : nil,
                "shape_dist_traveled": populated ? 12.5 : nil,
                "timepoint": populated ? 0 : nil,
                "is_laststop": populated ? 1 : nil,
            ])
    }

    private func verify<T: DatabaseCreating & PersistableRecord & FetchableRecord & Equatable>(
        _ record: T, table: String, expected: [String: (any DatabaseValueConvertible)?]
    ) throws {
        let queue = try DatabaseQueue()
        defer { try? queue.close() }
        try queue.write { (db: Database) throws -> Void in
            if table == "trips" || table == "stop_times" {
                try Route.createTable(db: db)
                try db.execute(sql: "INSERT INTO routes (route_id,route_type) VALUES ('R',3)")
            }
            if table == "stop_times" {
                try Trip.createTable(db: db)
                try Stop.createTable(db: db)
                try db.execute(
                    sql: """
                        INSERT INTO trips (trip_id,route_id,service_id) VALUES ('T','R','S');
                        INSERT INTO stops (stop_id,stop_lat,stop_lon,location_type,wheelchair_boarding) VALUES ('A',0,0,0,0);
                        """)
            }
            try T.createTable(db: db)
            try record.insert(db)
            let row = try #require(
                try Row.fetchOne(db, sql: "SELECT * FROM \(table) WHERE rowid = ?", arguments: [db.lastInsertedRowID]))
            for (column, value) in expected {
                let actual: DatabaseValue = row[column]
                #expect(actual == (value?.databaseValue ?? .null), "Column: \(column)")
            }
            // Compare model values as well as raw storage so symmetric key mistakes cannot hide.
            let decoded = try T(row: row)
            #expect(decoded == record)
        }
    }

    private func clockDate(hour: Int, minute: Int) -> Date {
        var calendar = Foundation.Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles")!
        return calendar.date(from: DateComponents(year: 2000, month: 1, day: 1, hour: hour, minute: minute))!
    }
}
