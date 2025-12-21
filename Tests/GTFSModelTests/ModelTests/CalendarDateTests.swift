//
//  CalendarDateTests.swift
//  GTFSModelTests
//

import Foundation
import GRDB
import Testing
@testable import GTFSModel

@Suite("CalendarDate Model Tests")
struct CalendarDateTests {

    @Test("CalendarDate creates table with correct schema")
    func testTableCreation() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            try CalendarDate.createTable(db: db)
        }

        try DatabaseTestHelper.assertTableExists("calendar_dates", in: db)
    }

    @Test("CalendarDate inserts and fetches from database")
    func testInsertAndFetch() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            try CalendarDate.createTable(db: db)
        }

        let calendarDate = TestFixtures.sampleCalendarDate(serviceIdentifier: "WEEKDAY")

        try db.write { db in
            try calendarDate.insert(db)
        }

        let fetched = try db.read { db in
            try CalendarDate.fetchAll(db)
        }

        #expect(fetched.count == 1)
        #expect(fetched.first?.serviceIdentifier == "WEEKDAY")
    }

    @Test("CalendarDate handles ExceptionType enum")
    func testExceptionTypeEnum() {
        #expect(CalendarDate.ExceptionType.added.rawValue == 1)
        #expect(CalendarDate.ExceptionType.removed.rawValue == 2)
    }
}
