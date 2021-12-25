//
//  CalendarDate.swift
//  
//
//  Created by Vashishtha Jogi on 6/20/20.
//

import Foundation
import GRDB

public struct CalendarDate {
    public enum ExceptionType: Int, Codable {
        case added = 1
        case removed = 2
    }
    public var serviceIdentifier: String
    public var date: Date
    public var exceptionType: ExceptionType
}

// For diffing
extension CalendarDate: Hashable {}

extension CalendarDate: Codable, PersistableRecord {
    public static let databaseDateEncodingStrategy: DatabaseDateEncodingStrategy = .formatted(DateFormatter.yyyyMMddDash)
    public static var databaseTableName = "calendar_dates"
    
    private enum Columns {
        static let serviceIdentifier = Column(CodingKeys.serviceIdentifier)
        static let date = Column(CodingKeys.date)
        static let exceptionType = Column(CodingKeys.exceptionType)
    }
    
    public enum CodingKeys: String, CodingKey {
        case serviceIdentifier = "service_id"
        case date = "date"
        case exceptionType = "exception_type"
    }
}

extension CalendarDate: CustomStringConvertible {
    public var description: String {
        return "\(serviceIdentifier): \(date) - \(exceptionType)"
    }
}
