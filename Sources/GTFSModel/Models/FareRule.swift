//
//  FareRule.swift
//  
//
//  Created by Vashishtha Jogi on 6/21/20.
//

import Foundation
import GRDB
import OSLog

public struct FareRule {
    public var fareIdentifier: String
    public var routeIdentifier: String?
    public var originIdentifier: String?
    public var destinationIdentifier: String?
    public var containsIdentifier: String?
}

// For diffing
extension FareRule: Hashable {}

extension FareRule: Codable, PersistableRecord, FetchableRecord {
    public static var databaseTableName = "fare_rules"
    
    private enum Columns {
        static let fareIdentifier = Column(CodingKeys.fareIdentifier)
        static let routeIdentifier = Column(CodingKeys.routeIdentifier)
        static let originIdentifier = Column(CodingKeys.originIdentifier)
        static let destinationIdentifier = Column(CodingKeys.destinationIdentifier)
        static let containsIdentifier = Column(CodingKeys.containsIdentifier)
    }
    
    public enum CodingKeys: String, CodingKey {
        case fareIdentifier = "fare_id"
        case routeIdentifier = "route_id"
        case originIdentifier = "origin_id"
        case destinationIdentifier = "destination_id"
        case containsIdentifier = "contains_id"
    }
}

extension FareRule: DatabaseCreating {
    public static func createTable(db: Database) throws {
        do {
            try db.drop(table: FareRule.databaseTableName)
        } catch {
            Logger.model.log("Table \(FareRule.databaseTableName) does not exist.")
        }
        
        // now create new table
        try db.create(table: FareRule.databaseTableName) { t in
            t.column(CodingKeys.fareIdentifier.rawValue, .text).notNull()
            t.column(CodingKeys.routeIdentifier.rawValue, .text)
            t.column(CodingKeys.originIdentifier.rawValue, .text)
            t.column(CodingKeys.destinationIdentifier.rawValue, .text)
            t.column(CodingKeys.containsIdentifier.rawValue, .text)
        }
    }
}

extension FareRule: CustomStringConvertible {
    public var description: String {
        return "\(fareIdentifier): \(routeIdentifier ?? "")"
    }
}
