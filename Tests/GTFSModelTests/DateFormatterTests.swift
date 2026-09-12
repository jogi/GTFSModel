import Foundation
import Testing

@testable import GTFSModel

struct DateFormatterTests {
    @Test("GTFS formatter configuration", arguments: ["compact", "dashed", "time"])
    func configuration(kind: String) {
        let formatter = formatter(kind)
        #expect(formatter.calendar.identifier == .iso8601)
        #expect(formatter.timeZone.identifier == "America/Los_Angeles")
        #expect(formatter.locale.identifier == "en_US_POSIX")
    }

    @Test(
        "Configured formats parse and format independently specified instants",
        arguments: [
            ("compact", "20240101", 1704096000.0),
            ("compact", "20240229", 1709193600.0),
            ("dashed", "2024-01-01", 1704096000.0),
            ("dashed", "2024-02-29", 1709193600.0),
        ])
    func dates(kind: String, text: String, timestamp: Double) throws {
        let formatter = formatter(kind)
        let expected = Date(timeIntervalSince1970: timestamp)
        #expect(try #require(formatter.date(from: text)) == expected)
        #expect(formatter.string(from: expected) == text)
    }

    @Test(
        "Time formatter preserves clock components",
        arguments: [("00:00:00", 0, 0, 0), ("08:15:30", 8, 15, 30), ("23:59:59", 23, 59, 59)])
    func times(text: String, hour: Int, minute: Int, second: Int) throws {
        let date = try #require(DateFormatter.hhmmss.date(from: text))
        var calendar = Foundation.Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "America/Los_Angeles"))
        let components = calendar.dateComponents([.hour, .minute, .second], from: date)
        #expect(components.hour == hour)
        #expect(components.minute == minute)
        #expect(components.second == second)
        #expect(DateFormatter.hhmmss.string(from: date) == text)
    }

    private func formatter(_ kind: String) -> DateFormatter {
        switch kind {
        case "compact": DateFormatter.yyyyMMdd
        case "dashed": DateFormatter.yyyyMMddDash
        default: DateFormatter.hhmmss
        }
    }
}
