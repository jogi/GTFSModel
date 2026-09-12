import Foundation

/// Converts GTFS service-day times without discarding hours beyond midnight.
///
/// Dates use the same reference midnight as `DateFormatter.hhmmss`: January 1,
/// 2000 in Los Angeles. They represent an offset, not an actual service date.
/// Thus 24:10:00 is the following reference day, and round-trips as 24:10:00.
/// Use these conversions when persisting stop times; a clock formatter loses days.
public enum ServiceDayTime {
    public static let referenceDate = Date(timeIntervalSince1970: 946_713_600)

    public static func date(from string: String) -> Date? {
        let parts = string.split(separator: ":", omittingEmptySubsequences: false)
        guard parts.count == 3,
            parts.allSatisfy({ !$0.isEmpty && $0.allSatisfy { $0.isASCII && $0.isNumber } }),
            let hours = Int(parts[0]), let minutes = Int(parts[1]), let seconds = Int(parts[2]),
            (0..<60).contains(minutes), (0..<60).contains(seconds),
            // Bound arithmetic and retain exact second precision in Foundation Date.
            hours <= 999_999
        else { return nil }
        return referenceDate.addingTimeInterval(Double(hours * 3600 + minutes * 60 + seconds))
    }

    public static func string(from date: Date) -> String? {
        let interval = date.timeIntervalSince(referenceDate)
        guard interval.isFinite, interval >= 0, interval < 1_000_000 * 3600 else { return nil }
        let seconds = Int(interval.rounded(.down))
        return String(format: "%02d:%02d:%02d", seconds / 3600, (seconds / 60) % 60, seconds % 60)
    }
}
