//
//  Direction.swift
//  
//
//  Created by Vashishtha Jogi on 6/21/20.
//

import Foundation
import GRDB

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

extension Direction: Codable, PersistableRecord {
    public static var databaseTableName = "directions"
    
    private enum Columns {
        static let identifier = Column(CodingKeys.identifier)
        static let routeIdentifier = Column(CodingKeys.routeIdentifier)
        static let direction = Column(CodingKeys.direction)
        static let name = Column(CodingKeys.name)
    }
    
    enum CodingKeys: String, CodingKey {
        case identifier = "direction_id"
        case routeIdentifier = "route_id"
        case direction
        case name = "direction_name"
    }
}

extension Direction: CustomStringConvertible {
    public var description: String {
        return "\(routeIdentifier) : \(identifier) - \(name ?? "")"
    }
}
