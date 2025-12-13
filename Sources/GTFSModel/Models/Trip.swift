//
//  Trip.swift
//  
//
//  Created by Vashishtha Jogi on 6/21/20.
//

import Foundation
import GRDB
import OSLog

public struct Trip {
    public enum WheelchairAccessibility: Int, Codable {
        case noInformation = 0
        case accessible = 1
        case notAccessible = 2
    }
    
    public enum BikeAllowance: Int, Codable {
        case noInformation = 0
        case allowed = 1
        case notAllowed = 2
    }
    
    public var identifier: String
    public var routeIdentifier: String
    public var serviceIdentifier: String
    public var headSign: String?
    public var shortName: String?
    public var directionIdentifier: Int?
    public var blockIdentifier: String?
    public var shapeIdentifier: String?
    public var wheelchairAccessible: WheelchairAccessibility?
    public var bikesAllowed: BikeAllowance?
}

// For diffing
extension Trip: Hashable {}

extension Trip: Codable, PersistableRecord, FetchableRecord {
    public static var databaseTableName = "trips"
    
    private enum Columns {
        static let identifier = Column(CodingKeys.identifier)
        static let routeIdentifier = Column(CodingKeys.routeIdentifier)
        static let serviceIdentifier = Column(CodingKeys.serviceIdentifier)
        static let headSign = Column(CodingKeys.headSign)
        static let shortName = Column(CodingKeys.shortName)
        static let directionIdentifier = Column(CodingKeys.directionIdentifier)
        static let blockIdentifier = Column(CodingKeys.blockIdentifier)
        static let shapeIdentifier = Column(CodingKeys.shapeIdentifier)
        static let wheelchairAccessible = Column(CodingKeys.wheelchairAccessible)
        static let bikesAllowed = Column(CodingKeys.bikesAllowed)
    }
    
    public enum CodingKeys: String, CodingKey {
        case identifier = "trip_id"
        case routeIdentifier = "route_id"
        case serviceIdentifier = "service_id"
        case headSign = "trip_headsign"
        case shortName = "trip_short_name"
        case directionIdentifier = "direction_id"
        case blockIdentifier = "block_id"
        case shapeIdentifier = "shape_id"
        case wheelchairAccessible = "wheelchair_accessible"
        case bikesAllowed = "bikes_allowed"
    }
}

extension Trip: DatabaseCreating {
    public static func createTable(db: Database) throws {
        do {
            try db.drop(table: Trip.databaseTableName)
        } catch {
            Logger.model.log("Table \(Trip.databaseTableName) does not exist.")
        }

        // Match legacy column order from master branch, but include all columns
        try db.create(table: Trip.databaseTableName) { t in
            t.column(CodingKeys.identifier.rawValue, .text)
                .notNull()
                .primaryKey()
            t.column(CodingKeys.routeIdentifier.rawValue, .text)
                .notNull()
                .indexed()
                .references(Route.databaseTableName)
            t.column(CodingKeys.serviceIdentifier.rawValue, .text)
                .notNull()
                .indexed()
            t.column(CodingKeys.headSign.rawValue, .text)
            t.column(CodingKeys.shortName.rawValue, .text)
            t.column(CodingKeys.directionIdentifier.rawValue, .integer)
            t.column(CodingKeys.blockIdentifier.rawValue, .text)
            t.column(CodingKeys.shapeIdentifier.rawValue, .text)
            t.column(CodingKeys.wheelchairAccessible.rawValue, .integer)
                .notNull()
            t.column(CodingKeys.bikesAllowed.rawValue, .integer)
                .notNull()
        }
    }
}

extension Route {
    public static let trips = hasMany(Trip.self)
    public var trips: QueryInterfaceRequest<Trip> { request(for: Route.trips) }
}

extension Trip {
    public static let route = belongsTo(Route.self)
    public var route: QueryInterfaceRequest<Route> { request(for: Trip.route) }
}

public struct TripInfo: Decodable, FetchableRecord {
    public var route: Route
    public var trip: Trip
}

extension Trip: CustomStringConvertible {
    public var description: String {
        return "\(identifier)"
    }
}
