//
//  StopTimeTests.swift
//  GTFSModelTests
//

import Foundation
import GRDB
import Testing
@testable import GTFSModel

@Suite("StopTime Model Tests")
struct StopTimeTests {

    @Test("StopTime creates table with correct schema")
    func testTableCreation() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            // Create dependent tables first (foreign key constraints)
            try Agency.createTable(db: db)
            try Route.createTable(db: db)
            try GTFSModel.Calendar.createTable(db: db)
            try Trip.createTable(db: db)
            try Stop.createTable(db: db)
            try StopTime.createTable(db: db)
        }

        try DatabaseTestHelper.assertTableExists("stop_times", in: db)

        let columns = try DatabaseTestHelper.columnNames(for: "stop_times", in: db)
        #expect(columns.contains("trip_id"))
        #expect(columns.contains("arrival_time"))
        #expect(columns.contains("departure_time"))
        #expect(columns.contains("stop_id"))
        #expect(columns.contains("stop_sequence"))
    }

    @Test("StopTime inserts and fetches from database")
    func testInsertAndFetch() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            // Create dependent tables first
            try Agency.createTable(db: db)
            try Route.createTable(db: db)
            try GTFSModel.Calendar.createTable(db: db)
            try Trip.createTable(db: db)
            try Stop.createTable(db: db)
            try StopTime.createTable(db: db)

            // Insert dependent records for foreign key constraints
            let route = TestFixtures.sampleRoute(identifier: "ROUTE1")
            try route.insert(db)

            let calendar = TestFixtures.sampleCalendar(serviceIdentifier: "SERVICE1")
            try calendar.insert(db)

            let trip = TestFixtures.sampleTrip(identifier: "TRIP1", routeIdentifier: "ROUTE1", serviceIdentifier: "SERVICE1")
            try trip.insert(db)

            let stop = TestFixtures.sampleStop(identifier: "STOP1")
            try stop.insert(db)
        }

        let stopTime = TestFixtures.sampleStopTime(
            tripIdentifier: "TRIP1",
            stopIdentifier: "STOP1",
            stopSequence: 1
        )

        try db.write { db in
            try stopTime.insert(db)
        }

        let fetched = try db.read { db in
            try StopTime.filter(Column("trip_id") == "TRIP1" && Column("stop_sequence") == 1).fetchOne(db)
        }

        #expect(fetched != nil)
        #expect(fetched?.tripIdentifier == "TRIP1")
        #expect(fetched?.stopIdentifier == "STOP1")
        #expect(fetched?.stopSequence == 1)
    }

    @Test("StopTime handles PickupDropoffMethod enum")
    func testPickupDropoffMethodEnum() {
        #expect(StopTime.PickupDropoffMethod.regularlyScheduled.rawValue == 0)
        #expect(StopTime.PickupDropoffMethod.notAvailable.rawValue == 1)
        #expect(StopTime.PickupDropoffMethod.phoneAgency.rawValue == 2)
        #expect(StopTime.PickupDropoffMethod.coordinateWithDriver.rawValue == 3)
    }
}
