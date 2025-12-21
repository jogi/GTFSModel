//
//  FareAttributeTests.swift
//  GTFSModelTests
//

import Foundation
import GRDB
import Testing
@testable import GTFSModel

@Suite("FareAttribute Model Tests")
struct FareAttributeTests {

    @Test("FareAttribute creates table with correct schema")
    func testTableCreation() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            try FareAttribute.createTable(db: db)
        }

        try DatabaseTestHelper.assertTableExists("fare_attributes", in: db)
    }

    @Test("FareAttribute inserts and fetches from database")
    func testInsertAndFetch() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            try FareAttribute.createTable(db: db)
        }

        let fare = TestFixtures.sampleFareAttribute(identifier: "FARE1", price: 2.50)

        try db.write { db in
            try fare.insert(db)
        }

        let fetched = try db.read { db in
            try FareAttribute.fetchOne(db, key: "FARE1")
        }

        #expect(fetched != nil)
        #expect(fetched?.identifier == "FARE1")
        #expect(fetched?.price == 2.50)
    }
}
