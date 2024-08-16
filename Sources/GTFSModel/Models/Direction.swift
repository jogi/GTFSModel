//
//  Direction.swift
//  
//
//  Created by Vashishtha Jogi on 6/21/20.
//

import Foundation
import GRDB
import OSLog

public struct Direction {
    public enum DirectionType: String, Codable {
        case north = "North"
        case south = "South"
        case east = "East"
        case west = "West"
        case northEast = "Northeast"
        case northWest = "Northwest"
        case southEast = "Southeast"
        case southWest = "Southwest"
        case clockwise = "Clockwise"
        case counterClockwise = "Counterclockwise"
        case inbound = "Inbound"
        case outbound = "Outbount"
        case loop = "Loop"
        case aLoop = "A Loop"
        case bLoop = "B Loop"
    }
    
    public var identifier: Int
    public var routeIdentifier: String
    public var direction: DirectionType
    public var name: String?
}

// For diffing
extension Direction: Hashable {}

extension Direction: Codable, PersistableRecord, FetchableRecord {
    public static var databaseTableName = "directions"
    
    private enum Columns {
        static let identifier = Column(CodingKeys.identifier)
        static let routeIdentifier = Column(CodingKeys.routeIdentifier)
        static let direction = Column(CodingKeys.direction)
        static let name = Column(CodingKeys.name)
    }
    
    public enum CodingKeys: String, CodingKey {
        case identifier = "direction_id"
        case routeIdentifier = "route_id"
        case direction
        case name = "direction_name"
    }
}

extension Direction: DatabaseCreating {
    public static func createTable(db: Database) throws {
        do {
            try db.drop(table: Direction.databaseTableName)
        } catch {
            Logger.model.log("Table \(Direction.databaseTableName) does not exist.")
        }
        
        // now create new table
        try db.create(table: Direction.databaseTableName) { t in
            t.column(CodingKeys.identifier.rawValue, .integer).notNull()
            t.column(CodingKeys.routeIdentifier.rawValue, .text).notNull()
            t.column(CodingKeys.direction.rawValue, .text).notNull()
            t.column(CodingKeys.name.rawValue, .text)
            t.primaryKey([CodingKeys.identifier.rawValue, CodingKeys.routeIdentifier.rawValue])
        }
    }
}

extension Direction: CustomStringConvertible {
    public var description: String {
        return "\(routeIdentifier) : \(identifier) - \(name ?? "")"
    }
}
