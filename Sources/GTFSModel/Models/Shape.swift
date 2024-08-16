//
//  Shape.swift
//  
//
//  Created by Vashishtha Jogi on 6/21/20.
//

import Foundation
import GRDB
import OSLog

public struct Shape {
    public var identifier: String
    public var latitude: Double
    public var longitude: Double
    public var sequence: UInt
    public var distanceTraveled: Double?
}

// For diffing
extension Shape: Hashable {}

extension Shape: Codable, PersistableRecord {
    public static var databaseTableName = "shapes"
    
    private enum Columns {
        static let identifier = Column(CodingKeys.identifier)
        static let latitude = Column(CodingKeys.latitude)
        static let longitude = Column(CodingKeys.longitude)
        static let sequence = Column(CodingKeys.sequence)
        static let distanceTraveled = Column(CodingKeys.distanceTraveled)
    }
    
    public enum CodingKeys: String, CodingKey {
        case identifier = "shape_id"
        case latitude = "shape_pt_lat"
        case longitude = "shape_pt_lon"
        case sequence = "shape_pt_sequence"
        case distanceTraveled = "shape_dist_traveled"
    }
}

extension Shape: DatabaseCreating {
    public static func createTable(db: Database) throws {
        do {
            try db.drop(table: Shape.databaseTableName)
        } catch {
            Logger.model.log("Table \(Shape.databaseTableName) does not exist.")
        }
        
        // now create new table
        try db.create(table: Shape.databaseTableName) { t in
            t.column(CodingKeys.identifier.rawValue, .text).notNull().indexed()
            t.column(CodingKeys.latitude.rawValue, .double).notNull()
            t.column(CodingKeys.longitude.rawValue, .double).notNull()
            t.column(CodingKeys.sequence.rawValue, .integer).notNull()
            t.column(CodingKeys.distanceTraveled.rawValue, .double)
        }
    }
}

extension Shape: CustomStringConvertible {
    public var description: String {
        return "\(identifier): \(sequence) - \(latitude), \(longitude)"
    }
}
