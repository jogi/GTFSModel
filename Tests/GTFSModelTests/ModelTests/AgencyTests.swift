//
//  AgencyTests.swift
//  GTFSModelTests
//
//  Tests for Agency model
//

import Foundation
import GRDB
import Testing
@testable import GTFSModel

@Suite("Agency Model Tests")
struct AgencyTests {

    // MARK: - Table Creation Tests

    @Test("Agency creates table with correct schema")
    func testTableCreation() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        // Create table
        try db.write { db in
            try Agency.createTable(db: db)
        }

        // Verify table exists
        try DatabaseTestHelper.assertTableExists("agency", in: db)

        // Verify columns exist
        let columns = try DatabaseTestHelper.columnNames(for: "agency", in: db)
        #expect(columns.contains("agency_id"))
        #expect(columns.contains("agency_name"))
        #expect(columns.contains("agency_url"))
        #expect(columns.contains("agency_timezone"))
        #expect(columns.contains("agency_lang"))
        #expect(columns.contains("agency_phone"))
        #expect(columns.contains("agency_fare_url"))
        #expect(columns.contains("agency_email"))
    }

    @Test("Agency table creation drops existing table")
    func testTableRecreation() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        // Create table first time
        try db.write { db in
            try Agency.createTable(db: db)
        }

        // Insert a record
        let agency1 = TestFixtures.sampleAgency(identifier: "AGENCY1")
        try db.write { db in
            try agency1.insert(db)
        }

        // Verify record exists
        try DatabaseTestHelper.assertRecordCount(1, in: "agency", db: db)

        // Recreate table (should drop and recreate)
        try db.write { db in
            try Agency.createTable(db: db)
        }

        // Verify table is empty after recreation
        try DatabaseTestHelper.assertRecordCount(0, in: "agency", db: db)
    }

    // MARK: - Codable Tests

    @Test("Agency CodingKeys match GTFS spec")
    func testCodingKeys() {
        #expect(Agency.CodingKeys.identifier.rawValue == "agency_id")
        #expect(Agency.CodingKeys.name.rawValue == "agency_name")
        #expect(Agency.CodingKeys.url.rawValue == "agency_url")
        #expect(Agency.CodingKeys.timezone.rawValue == "agency_timezone")
        #expect(Agency.CodingKeys.language.rawValue == "agency_lang")
        #expect(Agency.CodingKeys.phone.rawValue == "agency_phone")
        #expect(Agency.CodingKeys.fareURL.rawValue == "agency_fare_url")
        #expect(Agency.CodingKeys.email.rawValue == "agency_email")
    }

    // MARK: - Database Operations Tests

    @Test("Agency inserts and fetches from database")
    func testInsertAndFetch() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            try Agency.createTable(db: db)
        }

        let agency = TestFixtures.sampleAgency(
            identifier: "VTA",
            name: "Santa Clara Valley Transportation Authority",
            url: URL(string: "https://www.vta.org")!,
            timezone: "America/Los_Angeles",
            language: "en",
            phone: "408-321-2300",
            fareURL: URL(string: "https://www.vta.org/fares"),
            email: "customer.service@vta.org"
        )

        // Insert
        try db.write { db in
            try agency.insert(db)
        }

        // Fetch
        let fetched = try db.read { db in
            try Agency.fetchOne(db, key: "VTA")
        }

        #expect(fetched != nil)
        #expect(fetched?.identifier == "VTA")
        #expect(fetched?.name == "Santa Clara Valley Transportation Authority")
        #expect(fetched?.url.absoluteString == "https://www.vta.org")
        #expect(fetched?.timezone == "America/Los_Angeles")
        #expect(fetched?.language == "en")
        #expect(fetched?.phone == "408-321-2300")
        #expect(fetched?.fareURL?.absoluteString == "https://www.vta.org/fares")
        #expect(fetched?.email == "customer.service@vta.org")
    }

    @Test("Agency handles optional fields correctly")
    func testOptionalFields() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            try Agency.createTable(db: db)
        }

        // Create agency with minimal required fields
        let minimalAgency = Agency(
            identifier: "MINIMAL",
            name: "Minimal Agency",
            url: URL(string: "https://minimal.example.com")!,
            timezone: "America/Los_Angeles",
            language: nil,
            phone: nil,
            fareURL: nil,
            email: nil
        )

        // Insert
        try db.write { db in
            try minimalAgency.insert(db)
        }

        // Fetch
        let fetched = try db.read { db in
            try Agency.fetchOne(db, key: "MINIMAL")
        }

        #expect(fetched != nil)
        #expect(fetched?.identifier == "MINIMAL")
        #expect(fetched?.name == "Minimal Agency")
        #expect(fetched?.language == nil)
        #expect(fetched?.phone == nil)
        #expect(fetched?.fareURL == nil)
        #expect(fetched?.email == nil)
    }

    @Test("Agency supports update operations")
    func testUpdateOperations() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            try Agency.createTable(db: db)
        }

        var agency = TestFixtures.sampleAgency(identifier: "TEST")

        // Insert
        try db.write { db in
            try agency.insert(db)
        }

        // Update
        agency.name = "Updated Agency Name"
        agency.phone = "555-9999"

        try db.write { db in
            try agency.update(db)
        }

        // Fetch and verify
        let fetched = try db.read { db in
            try Agency.fetchOne(db, key: "TEST")
        }

        #expect(fetched?.name == "Updated Agency Name")
        #expect(fetched?.phone == "555-9999")
    }

    @Test("Agency supports delete operations")
    func testDeleteOperations() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            try Agency.createTable(db: db)
        }

        let agency = TestFixtures.sampleAgency(identifier: "DELETE_ME")

        // Insert
        try db.write { db in
            try agency.insert(db)
        }

        try DatabaseTestHelper.assertRecordCount(1, in: "agency", db: db)

        // Delete
        try db.write { db in
            try agency.delete(db)
        }

        try DatabaseTestHelper.assertRecordCount(0, in: "agency", db: db)
    }

    @Test("Agency supports bulk operations")
    func testBulkOperations() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            try Agency.createTable(db: db)
        }

        // Create multiple agencies
        let agencies = [
            TestFixtures.sampleAgency(identifier: "AGENCY1", name: "Agency 1"),
            TestFixtures.sampleAgency(identifier: "AGENCY2", name: "Agency 2"),
            TestFixtures.sampleAgency(identifier: "AGENCY3", name: "Agency 3"),
        ]

        // Bulk insert
        try db.write { db in
            for agency in agencies {
                try agency.insert(db)
            }
        }

        try DatabaseTestHelper.assertRecordCount(3, in: "agency", db: db)

        // Fetch all
        let fetched = try db.read { db in
            try Agency.fetchAll(db)
        }

        #expect(fetched.count == 3)
        #expect(fetched.map { $0.identifier }.sorted() == ["AGENCY1", "AGENCY2", "AGENCY3"])
    }

    // MARK: - Hashable Tests

    @Test("Agency conforms to Hashable")
    func testHashable() {
        let agency1 = TestFixtures.sampleAgency(identifier: "TEST1", name: "Test")
        let agency2 = TestFixtures.sampleAgency(identifier: "TEST1", name: "Test")
        let agency3 = TestFixtures.sampleAgency(identifier: "TEST2", name: "Different")

        // Same agencies should be equal
        #expect(agency1 == agency2)
        #expect(agency1.hashValue == agency2.hashValue)

        // Different agencies should not be equal
        #expect(agency1 != agency3)
    }

    // MARK: - CustomStringConvertible Tests

    @Test("Agency description contains key information")
    func testDescription() {
        let agency = TestFixtures.sampleAgency(
            identifier: "VTA",
            name: "Valley Transportation",
            url: URL(string: "https://vta.org")!
        )

        let description = agency.description
        #expect(description.contains("VTA"))
        #expect(description.contains("Valley Transportation"))
        #expect(description.contains("https://vta.org"))
    }
}
