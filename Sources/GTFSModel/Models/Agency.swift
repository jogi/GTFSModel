//
//  Agency.swift
//  
//
//  Created by Vashishtha Jogi on 6/14/20.
//

import Foundation
import GRDB
import OSLog

public struct Agency {
    public var identifier: String
    public var name: String
    public var url: URL
    public var timezone: String
    public var language: String?
    public var phone: String?
    public var fareURL: URL?
    public var email: String?
}

// For diffing
extension Agency: Hashable {}

extension Agency: Codable, PersistableRecord, FetchableRecord {
    public enum Columns {
        static let identifier = Column(CodingKeys.identifier)
        static let name = Column(CodingKeys.name)
        static let url = Column(CodingKeys.url)
        static let timezone = Column(CodingKeys.timezone)
        static let language = Column(CodingKeys.language)
        static let phone = Column(CodingKeys.phone)
        static let fareURL = Column(CodingKeys.fareURL)
        static let email = Column(CodingKeys.email)
    }

    public enum CodingKeys: String, CodingKey {
        case identifier = "agency_id"
        case name = "agency_name"
        case url = "agency_url"
        case timezone = "agency_timezone"
        case language = "agency_lang"
        case phone = "agency_phone"
        case fareURL = "agency_fare_url"
        case email = "agency_email"
    }
}

extension Agency: DatabaseCreating {
    public static func createTable(db: Database) throws {
        do {
            try db.drop(table: Agency.databaseTableName)
        } catch {
            Logger.model.log("Table \(Agency.databaseTableName) does not exist.")
        }

        try db.create(table: Agency.databaseTableName) { t in
            t.column(CodingKeys.identifier.rawValue, .text).notNull().primaryKey()
            t.column(CodingKeys.name.rawValue, .text)
            t.column(CodingKeys.url.rawValue, .text)
            t.column(CodingKeys.timezone.rawValue, .text)
            t.column(CodingKeys.language.rawValue, .text)
            t.column(CodingKeys.phone.rawValue, .text)
            t.column(CodingKeys.fareURL.rawValue, .text)
            t.column(CodingKeys.email.rawValue, .text)
        }
    }
}

extension Agency: CustomStringConvertible {
    public var description: String {
        return "\(identifier): \(name), \(url)"
    }
}
