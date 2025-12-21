//
//  DatabaseIntegrationTests.swift
//  GTFSModelTests
//
//  Integration tests for multi-table database operations
//

import Foundation
import GRDB
import Testing
@testable import GTFSModel

@Suite("Database Integration Tests")
struct DatabaseIntegrationTests {

    @Test("Multiple tables can be created in same database")
    func testMultipleTableCreation() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            try Agency.createTable(db: db)
            try Stop.createTable(db: db)
            try Route.createTable(db: db)
            try Trip.createTable(db: db)
        }

        try DatabaseTestHelper.assertTableExists("agency", in: db)
        try DatabaseTestHelper.assertTableExists("stops", in: db)
        try DatabaseTestHelper.assertTableExists("routes", in: db)
        try DatabaseTestHelper.assertTableExists("trips", in: db)
    }

    @Test("Related entities can be stored and queried")
    func testRelatedEntities() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            try Agency.createTable(db: db)
            try Route.createTable(db: db)
        }

        // Insert agency
        let agency = TestFixtures.sampleAgency(identifier: "VTA")
        try db.write { db in
            try agency.insert(db)
        }

        // Insert routes for that agency
        let route1 = TestFixtures.sampleRoute(identifier: "R1", agencyIdentifier: "VTA", shortName: "22")
        let route2 = TestFixtures.sampleRoute(identifier: "R2", agencyIdentifier: "VTA", shortName: "23")

        try db.write { db in
            try route1.insert(db)
            try route2.insert(db)
        }

        // Query routes for agency
        let routes = try db.read { db in
            try Route.filter(Column("agency_id") == "VTA").fetchAll(db)
        }

        #expect(routes.count == 2)
        #expect(routes.map { $0.shortName }.contains("22"))
        #expect(routes.map { $0.shortName }.contains("23"))
    }

    @Test("Transaction rollback works correctly")
    func testTransactionRollback() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            try Agency.createTable(db: db)
        }

        // Insert an agency in a transaction that we'll rollback
        do {
            try db.inTransaction { db in
                let agency = TestFixtures.sampleAgency(identifier: "ROLLBACK")
                try agency.insert(db)
                throw DatabaseError(message: "Intentional rollback")
            }
        } catch {
            // Expected to throw
        }

        // Verify agency was not inserted
        let count = try db.read { db in
            try Agency.fetchCount(db)
        }
        #expect(count == 0)
    }
}

// Helper error for testing
struct DatabaseError: Error {
    let message: String
}
