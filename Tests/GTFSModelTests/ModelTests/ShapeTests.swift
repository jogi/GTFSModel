//
//  ShapeTests.swift
//  GTFSModelTests
//

import Foundation
import GRDB
import Testing
@testable import GTFSModel

@Suite("Shape Model Tests")
struct ShapeTests {

    @Test("Shape creates table with correct schema")
    func testTableCreation() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            try Shape.createTable(db: db)
        }

        try DatabaseTestHelper.assertTableExists("shapes", in: db)
    }

    @Test("Shape inserts and fetches from database")
    func testInsertAndFetch() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            try Shape.createTable(db: db)
        }

        let shape = TestFixtures.sampleShape(identifier: "SHAPE1", sequence: 1)

        try db.write { db in
            try shape.insert(db)
        }

        let fetched = try db.read { db in
            try Shape.filter(Column("shape_id") == "SHAPE1" && Column("shape_pt_sequence") == 1).fetchOne(db)
        }

        #expect(fetched != nil)
        #expect(fetched?.identifier == "SHAPE1")
        #expect(fetched?.sequence == 1)
    }
}
