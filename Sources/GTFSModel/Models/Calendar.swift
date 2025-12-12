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
    public static let databaseDateEncodingStrategy: DatabaseDateEncodingStrategy = .formatted(DateFormatter.yyyyMMddDash)
    public static let databaseDateDecodingStrategy: DatabaseDateDecodingStrategy = .formatted(DateFormatter.yyyyMMddDash)
    
    private enum Columns {
        static let serviceIdentifier = Column(CodingKeys.serviceIdentifier)
        static let startDate = Column(CodingKeys.startDate)
        static let endDate = Column(CodingKeys.endDate)
        static let monday = Column(CodingKeys.monday)
        static let tuesday = Column(CodingKeys.tuesday)
        static let wednesday = Column(CodingKeys.wednesday)
        static let thursday = Column(CodingKeys.thursday)
        static let friday = Column(CodingKeys.friday)
        static let saturday = Column(CodingKeys.saturday)
        static let sunday = Column(CodingKeys.sunday)
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

        // now create new table
        // Match legacy schema from master branch
        try db.create(table: Calendar.databaseTableName) { t in
            t.column(CodingKeys.serviceIdentifier.rawValue, .text)
            t.column(CodingKeys.startDate.rawValue, .date)
            t.column(CodingKeys.endDate.rawValue, .date)
            t.column(CodingKeys.monday.rawValue, Database.ColumnType(rawValue: "tinyint(1)"))
            t.column(CodingKeys.tuesday.rawValue, Database.ColumnType(rawValue: "tinyint(1)"))
            t.column(CodingKeys.wednesday.rawValue, Database.ColumnType(rawValue: "tinyint(1)"))
            t.column(CodingKeys.thursday.rawValue, Database.ColumnType(rawValue: "tinyint(1)"))
            t.column(CodingKeys.friday.rawValue, Database.ColumnType(rawValue: "tinyint(1)"))
            t.column(CodingKeys.saturday.rawValue, Database.ColumnType(rawValue: "tinyint(1)"))
            t.column(CodingKeys.sunday.rawValue, Database.ColumnType(rawValue: "tinyint(1)"))
        }

        // Create index manually to match master schema
        try db.create(index: "service_id_calendar", on: Calendar.databaseTableName, columns: [CodingKeys.serviceIdentifier.rawValue])
    }
}

extension Calendar: CustomStringConvertible {
    public var description: String {
        return "\(serviceIdentifier): \(startDate) - \(endDate)"
    }
}
