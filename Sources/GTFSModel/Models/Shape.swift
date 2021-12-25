//
//  Shape.swift
//  
//
//  Created by Vashishtha Jogi on 6/21/20.
//

import Foundation
import GRDB

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
    
    enum CodingKeys: String, CodingKey {
        case identifier = "shape_id"
        case latitude = "shape_pt_lat"
        case longitude = "shape_pt_lon"
        case sequence = "shape_pt_sequence"
        case distanceTraveled = "shape_dist_traveled"
    }
}

extension Shape: CustomStringConvertible {
    public var description: String {
        return "\(identifier): \(sequence) - \(latitude), \(longitude)"
    }
}
