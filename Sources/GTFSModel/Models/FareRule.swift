//
//  FareRule.swift
//  
//
//  Created by Vashishtha Jogi on 6/21/20.
//

import Foundation
import GRDB

public struct FareRule {
    public var fareIdentifier: String
    public var routeIdentifier: String?
    public var originIdentifier: String?
    public var destinationIdentifier: String?
    public var containsIdentifier: String?
}

// For diffing
extension FareRule: Hashable {}

extension FareRule: Codable, PersistableRecord {
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

extension FareRule: CustomStringConvertible {
    public var description: String {
        return "\(fareIdentifier): \(routeIdentifier ?? "")"
    }
}
