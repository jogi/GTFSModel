//
//  DateFormatterTests.swift
//  GTFSModelTests
//
//  Tests for GTFS date and time formatters
//

import Foundation
import Testing
@testable import GTFSModel

@Suite("DateFormatter Tests")
struct DateFormatterTests {

    // MARK: - yyyyMMdd Formatter Tests

    @Test("yyyyMMdd formatter parses valid dates", arguments: [
        ("20240101", 2024, 1, 1),
        ("20231215", 2023, 12, 15),
        ("20250630", 2025, 6, 30),
        ("20200229", 2020, 2, 29), // Leap year
    ])
    func testyyyyMMddValidDates(dateString: String, expectedYear: Int, expectedMonth: Int, expectedDay: Int) {
        let date = DateFormatter.yyyyMMdd.date(from: dateString)
        #expect(date != nil, "Should parse valid date string: \(dateString)")

        if let date = date {
            let calendar = Foundation.Calendar(identifier: .iso8601)
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            #expect(components.year == expectedYear, "Year should be \(expectedYear)")
            #expect(components.month == expectedMonth, "Month should be \(expectedMonth)")
            #expect(components.day == expectedDay, "Day should be \(expectedDay)")
        }
    }

    @Test("yyyyMMdd formatter rejects invalid dates", arguments: [
        "2024-01-01",  // Wrong format (has dashes)
        "20241301",    // Invalid month
        "20240132",    // Invalid day
        "invalid",     // Not a date
    ])
    func testyyyyMMddInvalidDates(invalidDateString: String) {
        let date = DateFormatter.yyyyMMdd.date(from: invalidDateString)
        #expect(date == nil, "Should not parse invalid date string: \(invalidDateString)")
    }

    @Test("yyyyMMdd formatter uses correct timezone")
    func testyyyyMMddTimezone() {
        #expect(DateFormatter.yyyyMMdd.timeZone?.identifier == "America/Los_Angeles")
    }

    @Test("yyyyMMdd formatter uses correct locale")
    func testyyyyMMddLocale() {
        #expect(DateFormatter.yyyyMMdd.locale?.identifier == "en_US_POSIX")
    }

    // MARK: - yyyyMMddDash Formatter Tests

    @Test("yyyyMMddDash formatter parses valid dates", arguments: [
        ("2024-01-01", 2024, 1, 1),
        ("2023-12-15", 2023, 12, 15),
        ("2025-06-30", 2025, 6, 30),
        ("2020-02-29", 2020, 2, 29), // Leap year
    ])
    func testyyyyMMddDashValidDates(dateString: String, expectedYear: Int, expectedMonth: Int, expectedDay: Int) {
        let date = DateFormatter.yyyyMMddDash.date(from: dateString)
        #expect(date != nil, "Should parse valid date string: \(dateString)")

        if let date = date {
            let calendar = Foundation.Calendar(identifier: .iso8601)
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            #expect(components.year == expectedYear, "Year should be \(expectedYear)")
            #expect(components.month == expectedMonth, "Month should be \(expectedMonth)")
            #expect(components.day == expectedDay, "Day should be \(expectedDay)")
        }
    }

    @Test("yyyyMMddDash formatter rejects invalid dates", arguments: [
        "20240101",    // Wrong format (no dashes)
        "2024-13-01",  // Invalid month
        "2024-01-32",  // Invalid day
        "invalid",     // Not a date
    ])
    func testyyyyMMddDashInvalidDates(invalidDateString: String) {
        let date = DateFormatter.yyyyMMddDash.date(from: invalidDateString)
        #expect(date == nil, "Should not parse invalid date string: \(invalidDateString)")
    }

    @Test("yyyyMMddDash formatter uses correct timezone")
    func testyyyyMMddDashTimezone() {
        #expect(DateFormatter.yyyyMMddDash.timeZone?.identifier == "America/Los_Angeles")
    }

    @Test("yyyyMMddDash formatter uses correct locale")
    func testyyyyMMddDashLocale() {
        #expect(DateFormatter.yyyyMMddDash.locale?.identifier == "en_US_POSIX")
    }

    // MARK: - hhmmss Formatter Tests

    @Test("hhmmss formatter parses valid times", arguments: [
        ("00:00:00", 0, 0, 0),
        ("12:30:45", 12, 30, 45),
        ("23:59:59", 23, 59, 59),
        ("08:15:00", 8, 15, 0),
    ])
    func testHhmmssValidTimes(timeString: String, expectedHour: Int, expectedMinute: Int, expectedSecond: Int) {
        let date = DateFormatter.hhmmss.date(from: timeString)
        #expect(date != nil, "Should parse valid time string: \(timeString)")

        if let date = date {
            var calendar = Foundation.Calendar(identifier: .iso8601)
            calendar.timeZone = TimeZone(identifier: "America/Los_Angeles")!
            let components = calendar.dateComponents([.hour, .minute, .second], from: date)
            #expect(components.hour == expectedHour, "Hour should be \(expectedHour)")
            #expect(components.minute == expectedMinute, "Minute should be \(expectedMinute)")
            #expect(components.second == expectedSecond, "Second should be \(expectedSecond)")
        }
    }

    @Test("hhmmss formatter rejects invalid times", arguments: [
        "12:60:00",    // Invalid minutes
        "12:30:60",    // Invalid seconds
        "invalid",     // Not a time
        "12:30",       // Missing seconds
    ])
    func testHhmmssInvalidTimes(invalidTimeString: String) {
        let date = DateFormatter.hhmmss.date(from: invalidTimeString)
        #expect(date == nil, "Should not parse invalid time string: \(invalidTimeString)")
    }

    @Test("hhmmss formatter uses correct timezone")
    func testHhmmssTimezone() {
        #expect(DateFormatter.hhmmss.timeZone?.identifier == "America/Los_Angeles")
    }

    @Test("hhmmss formatter uses correct locale")
    func testHhmmssLocale() {
        #expect(DateFormatter.hhmmss.locale?.identifier == "en_US_POSIX")
    }

    // MARK: - Formatter Consistency Tests

    @Test("All formatters use ISO8601 calendar")
    func testAllFormattersUseISO8601Calendar() {
        #expect(DateFormatter.yyyyMMdd.calendar?.identifier == .iso8601)
        #expect(DateFormatter.yyyyMMddDash.calendar?.identifier == .iso8601)
        #expect(DateFormatter.hhmmss.calendar?.identifier == .iso8601)
    }

    @Test("All formatters use America/Los_Angeles timezone")
    func testAllFormattersUseConsistentTimezone() {
        #expect(DateFormatter.yyyyMMdd.timeZone?.identifier == "America/Los_Angeles")
        #expect(DateFormatter.yyyyMMddDash.timeZone?.identifier == "America/Los_Angeles")
        #expect(DateFormatter.hhmmss.timeZone?.identifier == "America/Los_Angeles")
    }

    @Test("All formatters use en_US_POSIX locale")
    func testAllFormattersUseConsistentLocale() {
        #expect(DateFormatter.yyyyMMdd.locale?.identifier == "en_US_POSIX")
        #expect(DateFormatter.yyyyMMddDash.locale?.identifier == "en_US_POSIX")
        #expect(DateFormatter.hhmmss.locale?.identifier == "en_US_POSIX")
    }
}
