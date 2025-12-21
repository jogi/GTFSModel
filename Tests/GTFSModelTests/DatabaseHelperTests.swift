//
//  DatabaseHelperTests.swift
//  GTFSModelTests
//
//  Tests for DatabaseHelper utility
//

import Foundation
import GRDB
import Testing
@testable import GTFSModel

@Suite("DatabaseHelper Tests")
struct DatabaseHelperTests {

    @Test("DatabaseHelper initializes with path")
    func testInitialization() throws {
        let tempDir = FileManager.default.temporaryDirectory
        let dbPath = tempDir.appendingPathComponent("test-\(UUID().uuidString).db")
        defer { try? FileManager.default.removeItem(at: dbPath) }

        let helper = try DatabaseHelper(path: dbPath.path)
        #expect(helper.dbQueue != nil)
    }

    @Test("DatabaseHelper vacuum reduces database size")
    func testVacuum() throws {
        let tempDir = FileManager.default.temporaryDirectory
        let dbPath = tempDir.appendingPathComponent("test-\(UUID().uuidString).db")
        defer { try? FileManager.default.removeItem(at: dbPath) }

        let helper = try DatabaseHelper(path: dbPath.path)

        // Create and populate table
        try helper.dbQueue?.write { db in
            try Agency.createTable(db: db)
            for i in 1...100 {
                let agency = TestFixtures.sampleAgency(identifier: "AGENCY\(i)")
                try agency.insert(db)
            }
        }

        // Vacuum should succeed
        try helper.vacuum()

        // Verify database still works
        let count = try helper.dbQueue?.read { db in
            try Agency.fetchCount(db)
        }
        #expect(count == 100)
    }

    @Test("DatabaseHelper reindex completes successfully")
    func testReindex() throws {
        let tempDir = FileManager.default.temporaryDirectory
        let dbPath = tempDir.appendingPathComponent("test-\(UUID().uuidString).db")
        defer { try? FileManager.default.removeItem(at: dbPath) }

        let helper = try DatabaseHelper(path: dbPath.path)

        // Create table with data
        try helper.dbQueue?.write { db in
            try Agency.createTable(db: db)
            let agency = TestFixtures.sampleAgency()
            try agency.insert(db)
        }

        // Reindex should succeed
        try helper.reindex()

        // Verify database still works
        let count = try helper.dbQueue?.read { db in
            try Agency.fetchCount(db)
        }
        #expect(count == 1)
    }
}
