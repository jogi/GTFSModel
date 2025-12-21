//
//  CalendarTests.swift
//  GTFSModelTests
//

import Foundation
import GRDB
import Testing
@testable import GTFSModel

@Suite("Calendar Model Tests")
struct CalendarTests {

    @Test("Calendar creates table with correct schema")
    func testTableCreation() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            try Calendar.createTable(db: db)
        }

        try DatabaseTestHelper.assertTableExists("calendar", in: db)

        let columns = try DatabaseTestHelper.columnNames(for: "calendar", in: db)
        #expect(columns.contains("service_id"))
        #expect(columns.contains("monday"))
        #expect(columns.contains("tuesday"))
        #expect(columns.contains("start_date"))
        #expect(columns.contains("end_date"))
    }

    @Test("Calendar inserts and fetches from database")
    func testInsertAndFetch() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            try Calendar.createTable(db: db)
        }

        let calendar = TestFixtures.sampleCalendar(serviceIdentifier: "WEEKDAY")

        try db.write { db in
            try calendar.insert(db)
        }

        let fetched = try db.read { db in
            try Calendar.fetchOne(db, key: "WEEKDAY")
        }

        #expect(fetched != nil)
        #expect(fetched?.serviceIdentifier == "WEEKDAY")
        #expect(fetched?.monday == .available)
        #expect(fetched?.saturday == .unavailable)
    }
}
