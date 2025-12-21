//
//  StopTests.swift
//  GTFSModelTests
//
//  Tests for Stop model
//

import Foundation
import GRDB
import Testing
@testable import GTFSModel

@Suite("Stop Model Tests")
struct StopTests {

    @Test("Stop creates table with correct schema")
    func testTableCreation() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            try Stop.createTable(db: db)
        }

        try DatabaseTestHelper.assertTableExists("stops", in: db)

        let columns = try DatabaseTestHelper.columnNames(for: "stops", in: db)
        #expect(columns.contains("stop_id"))
        #expect(columns.contains("stop_code"))
        #expect(columns.contains("stop_name"))
        #expect(columns.contains("stop_desc"))
        #expect(columns.contains("stop_lat"))
        #expect(columns.contains("stop_lon"))
    }

    @Test("Stop inserts and fetches from database")
    func testInsertAndFetch() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            try Stop.createTable(db: db)
        }

        let stop = TestFixtures.sampleStop(
            identifier: "STOP123",
            code: "123",
            name: "Main Street Station",
            latitude: 37.7749,
            longitude: -122.4194
        )

        try db.write { db in
            try stop.insert(db)
        }

        let fetched = try db.read { db in
            try Stop.fetchOne(db, key: "STOP123")
        }

        #expect(fetched != nil)
        #expect(fetched?.identifier == "STOP123")
        #expect(fetched?.code == "123")
        #expect(fetched?.name == "Main Street Station")
        #expect(fetched?.latitude == 37.7749)
        #expect(fetched?.longitude == -122.4194)
    }

    @Test("Stop handles LocationType enum")
    func testLocationTypeEnum() {
        #expect(Stop.LocationType.stop.rawValue == 0)
        #expect(Stop.LocationType.station.rawValue == 1)
        #expect(Stop.LocationType.entranceOrExit.rawValue == 2)
        #expect(Stop.LocationType.genericNode.rawValue == 3)
        #expect(Stop.LocationType.boardingArea.rawValue == 4)
    }

    @Test("Stop handles WheelchairBoarding enum")
    func testWheelchairBoardingEnum() {
        #expect(Stop.WheelchairBoarding.noInformation.rawValue == 0)
        #expect(Stop.WheelchairBoarding.partiallyAccessible.rawValue == 1)
        #expect(Stop.WheelchairBoarding.notAccessible.rawValue == 2)
    }

    @Test("Stop handles optional fields correctly")
    func testOptionalFields() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            try Stop.createTable(db: db)
        }

        let minimalStop = Stop(
            identifier: "MINIMAL",
            code: nil,
            name: nil,
            stopDescription: nil,
            latitude: 0,
            longitude: 0,
            zoneIdentifier: nil,
            locationType: .stop,
            parentStation: nil,
            timezone: nil,
            wheelchairBording: .noInformation,
            levelIdentifier: nil,
            platformCode: nil,
            routes: nil
        )

        try db.write { db in
            try minimalStop.insert(db)
        }

        let fetched = try db.read { db in
            try Stop.fetchOne(db, key: "MINIMAL")
        }

        #expect(fetched != nil)
        #expect(fetched?.code == nil)
        #expect(fetched?.name == nil)
        #expect(fetched?.routes == nil)
    }
}
