//
//  FareRuleTests.swift
//  GTFSModelTests
//

import Foundation
import GRDB
import Testing
@testable import GTFSModel

@Suite("FareRule Model Tests")
struct FareRuleTests {

    @Test("FareRule creates table with correct schema")
    func testTableCreation() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            try FareRule.createTable(db: db)
        }

        try DatabaseTestHelper.assertTableExists("fare_rules", in: db)
    }

    @Test("FareRule inserts and fetches from database")
    func testInsertAndFetch() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            try FareRule.createTable(db: db)
        }

        let rule = TestFixtures.sampleFareRule(fareIdentifier: "FARE1", routeIdentifier: "ROUTE1")

        try db.write { db in
            try rule.insert(db)
        }

        let fetched = try db.read { db in
            try FareRule.fetchAll(db)
        }

        #expect(fetched.count == 1)
        #expect(fetched.first?.fareIdentifier == "FARE1")
    }
}
