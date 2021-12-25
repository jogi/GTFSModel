//
//  Stop.swift
//  
//
//  Created by Vashishtha Jogi on 6/21/20.
//

import Foundation
import GRDB

public struct Stop {
    public enum LocationType: Int, Codable {
        case stop = 0
        case station = 1
        case entranceOrExit = 2
        case genericNode = 3
        case boardingArea = 4
    }
    
    public enum WheelchairBoarding: Int, Codable {
        case noInformation = 0
        case partiallyAccessible = 1
        case notAccessible = 2
    }
    
    public var identifier: String
    public var code: String?
    public var name: String?
    public var stopDescription: String?
    public var latitude: Double = 0
    public var longitude: Double = 0
    public var zoneIdentifier: String?
    public var locationType: LocationType = .stop
    public var parentStation: String?
    public var timezone: String?
    public var wheelchairBording: WheelchairBoarding = .noInformation
    public var levelIdentifier: String?
    public var platformCode: String?
}

// For diffing
extension Stop: Hashable {}

extension Stop: Codable, PersistableRecord {
    public static var databaseTableName = "stops"
    
    private enum Columns {
        static let identifier = Column(CodingKeys.identifier)
        static let code = Column(CodingKeys.code)
        static let name = Column(CodingKeys.name)
        static let stopDescription = Column(CodingKeys.stopDescription)
        static let latitude = Column(CodingKeys.latitude)
        static let longitude = Column(CodingKeys.longitude)
        static let zoneIdentifier = Column(CodingKeys.zoneIdentifier)
        static let locationType = Column(CodingKeys.locationType)
        static let parentStation = Column(CodingKeys.parentStation)
        static let timezone = Column(CodingKeys.timezone)
        static let wheelchairBording = Column(CodingKeys.wheelchairBording)
        static let levelIdentifier = Column(CodingKeys.levelIdentifier)
        static let platformCode = Column(CodingKeys.platformCode)
    }
    
    public enum CodingKeys: String, CodingKey {
        case identifier = "stop_id"
        case code = "stop_code"
        case name = "stop_name"
        case stopDescription = "stop_desc"
        case latitude = "stop_lat"
        case longitude = "stop_lon"
        case zoneIdentifier = "zone_id"
        case locationType = "location_type"
        case parentStation = "parent_station"
        case timezone = "stop_timezone"
        case wheelchairBording = "wheelchair_boarding"
        case levelIdentifier = "level_id"
        case platformCode = "platform_code"
    }
}

extension Stop: CustomStringConvertible {
    public var description: String {
        return "\(identifier): \(name ?? "")"
    }
}
