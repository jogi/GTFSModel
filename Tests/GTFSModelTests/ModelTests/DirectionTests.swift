//
//  DirectionTests.swift
//  GTFSModelTests
//

import Foundation
import GRDB
import Testing
@testable import GTFSModel

@Suite("Direction Model Tests")
struct DirectionTests {

    @Test("Direction creates table with correct schema")
    func testTableCreation() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            try Direction.createTable(db: db)
        }

        try DatabaseTestHelper.assertTableExists("directions", in: db)
    }

    @Test("Direction inserts and fetches from database")
    func testInsertAndFetch() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            try Direction.createTable(db: db)
        }

        let direction = TestFixtures.sampleDirection(
            identifier: 0,
            routeIdentifier: "ROUTE1",
            direction: .north,
            name: "Northbound"
        )

        try db.write { db in
            try direction.insert(db)
        }

        let fetched = try db.read { db in
            try Direction.fetchAll(db)
        }

        #expect(fetched.count == 1)
        #expect(fetched.first?.direction == .north)
    }
}
