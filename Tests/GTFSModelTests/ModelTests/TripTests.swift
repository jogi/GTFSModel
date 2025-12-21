//
//  TripTests.swift
//  GTFSModelTests
//

import Foundation
import GRDB
import Testing
@testable import GTFSModel

@Suite("Trip Model Tests")
struct TripTests {

    @Test("Trip creates table with correct schema")
    func testTableCreation() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            // Create dependent tables first (foreign key constraints)
            try Agency.createTable(db: db)
            try Route.createTable(db: db)
            try GTFSModel.Calendar.createTable(db: db)
            try Trip.createTable(db: db)
        }

        try DatabaseTestHelper.assertTableExists("trips", in: db)
    }

    @Test("Trip inserts and fetches from database")
    func testInsertAndFetch() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            // Create dependent tables first
            try Agency.createTable(db: db)
            try Route.createTable(db: db)
            try GTFSModel.Calendar.createTable(db: db)
            try Trip.createTable(db: db)

            // Insert dependent records for foreign key constraints
            let route = TestFixtures.sampleRoute(identifier: "ROUTE1")
            try route.insert(db)

            let calendar = TestFixtures.sampleCalendar(serviceIdentifier: "SERVICE1")
            try calendar.insert(db)
        }

        let trip = TestFixtures.sampleTrip(identifier: "TRIP1", routeIdentifier: "ROUTE1", serviceIdentifier: "SERVICE1")

        try db.write { db in
            try trip.insert(db)
        }

        let fetched = try db.read { db in
            try Trip.fetchOne(db, key: "TRIP1")
        }

        #expect(fetched != nil)
        #expect(fetched?.identifier == "TRIP1")
    }

    @Test("Trip handles WheelchairAccessibility enum")
    func testWheelchairAccessibilityEnum() {
        #expect(Trip.WheelchairAccessibility.noInformation.rawValue == 0)
        #expect(Trip.WheelchairAccessibility.accessible.rawValue == 1)
        #expect(Trip.WheelchairAccessibility.notAccessible.rawValue == 2)
    }

    @Test("Trip handles BikeAllowance enum")
    func testBikeAllowanceEnum() {
        #expect(Trip.BikeAllowance.noInformation.rawValue == 0)
        #expect(Trip.BikeAllowance.allowed.rawValue == 1)
        #expect(Trip.BikeAllowance.notAllowed.rawValue == 2)
    }
}
