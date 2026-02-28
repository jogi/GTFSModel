//
//  Calendar.swift
//  
//
//  Created by Vashishtha Jogi on 6/14/20.
//

import Foundation
import GRDB
import OSLog

public struct Calendar {
    public enum Availability: Int, Codable {
        case unavailable = 0
        case available = 1
    }
    
    public var serviceIdentifier: String
    public var startDate: Date
    public var endDate: Date
    public var monday: Availability
    public var tuesday: Availability
    public var wednesday: Availability
    public var thursday: Availability
    public var friday: Availability
    public var saturday: Availability
    public var sunday: Availability
}

// For diffing
extension Calendar: Hashable {}

extension Calendar: Codable, PersistableRecord, FetchableRecord {
    public static func databaseDateEncodingStrategy(for column: String) -> DatabaseDateEncodingStrategy {
        .formatted(DateFormatter.yyyyMMddDash)
    }
    public static func databaseDateDecodingStrategy(for column: String) -> DatabaseDateDecodingStrategy {
        .formatted(DateFormatter.yyyyMMddDash)
    }
    
    public enum Columns {
        public static let serviceIdentifier = Column(CodingKeys.serviceIdentifier)
        public static let startDate = Column(CodingKeys.startDate)
        public static let endDate = Column(CodingKeys.endDate)
        public static let monday = Column(CodingKeys.monday)
        public static let tuesday = Column(CodingKeys.tuesday)
        public static let wednesday = Column(CodingKeys.wednesday)
        public static let thursday = Column(CodingKeys.thursday)
        public static let friday = Column(CodingKeys.friday)
        public static let saturday = Column(CodingKeys.saturday)
        public static let sunday = Column(CodingKeys.sunday)
    }
    
    public enum CodingKeys: String, CodingKey {
        case serviceIdentifier = "service_id"
        case startDate = "start_date"
        case endDate = "end_date"
        case monday
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday
        case sunday
    }
}

extension Calendar: DatabaseCreating {
    public static func createTable(db: Database) throws {
        do {
            try db.drop(table: Calendar.databaseTableName)
        } catch {
            Logger.model.log("Table \(Calendar.databaseTableName) does not exist.")
        }

        try db.create(table: Calendar.databaseTableName) { t in
            t.column(CodingKeys.serviceIdentifier.rawValue, .text).notNull().primaryKey()
            t.column(CodingKeys.startDate.rawValue, .date).notNull()
            t.column(CodingKeys.endDate.rawValue, .date).notNull()
            t.column(CodingKeys.monday.rawValue, .integer).notNull()
            t.column(CodingKeys.tuesday.rawValue, .integer).notNull()
            t.column(CodingKeys.wednesday.rawValue, .integer).notNull()
            t.column(CodingKeys.thursday.rawValue, .integer).notNull()
            t.column(CodingKeys.friday.rawValue, .integer).notNull()
            t.column(CodingKeys.saturday.rawValue, .integer).notNull()
            t.column(CodingKeys.sunday.rawValue, .integer).notNull()
        }
    }
}

extension Calendar: CustomStringConvertible {
    public var description: String {
        return "\(serviceIdentifier): \(startDate) - \(endDate)"
    }
}
