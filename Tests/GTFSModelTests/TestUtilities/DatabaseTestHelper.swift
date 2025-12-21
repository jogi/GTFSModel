//
//  DatabaseTestHelper.swift
//  GTFSModelTests
//
//  Test utilities for database operations
//

import Foundation
import GRDB
import Testing

enum DatabaseTestHelper {
    /// Creates a unique temporary SQLite database for testing
    static func createTemporaryDatabase() throws -> DatabaseQueue {
        let tempDir = FileManager.default.temporaryDirectory
        let dbPath = tempDir.appendingPathComponent("test-\(UUID().uuidString).db")
        return try DatabaseQueue(path: dbPath.path)
    }

    /// Closes database connection and deletes the database file
    static func cleanup(database: DatabaseQueue) throws {
        let path = database.path
        // Close the database first
        try database.close()
        // Delete the file
        try? FileManager.default.removeItem(atPath: path)
    }

    /// Verifies that a table exists in the database
    static func assertTableExists(_ tableName: String, in db: DatabaseQueue) throws {
        let exists = try db.read { db in
            try db.tableExists(tableName)
        }
        #expect(exists, "Table '\(tableName)' should exist in database")
    }

    /// Returns the number of records in a table
    static func recordCount(in table: String, db: DatabaseQueue) throws -> Int {
        try db.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM \(table)") ?? 0
        }
    }

    /// Verifies the expected record count in a table
    static func assertRecordCount(_ expected: Int, in table: String, db: DatabaseQueue) throws {
        let actual = try recordCount(in: table, db: db)
        #expect(actual == expected, "Expected \(expected) records in '\(table)', but found \(actual)")
    }

    /// Gets column names for a table
    static func columnNames(for table: String, in db: DatabaseQueue) throws -> [String] {
        try db.read { db in
            try db.columns(in: table).map { $0.name }
        }
    }

    /// Checks if a specific column exists in a table
    static func hasColumn(_ columnName: String, in table: String, db: DatabaseQueue) throws -> Bool {
        let columns = try columnNames(for: table, in: db)
        return columns.contains(columnName)
    }
}
