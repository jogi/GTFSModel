//
//  StopTime.swift
//  
//
//  Created by Vashishtha Jogi on 6/21/20.
//

import Foundation
import GRDB
import OSLog

public struct StopTime {
    public enum PickupDropoffMethod: Int, Codable {
        case regularlyScheduled = 0
        case notAvailable = 1
        case phoneAgency = 2
        case coordinateWithDriver = 3
    }
    
    public enum ContinuationType: Int, Codable {
        case continuous = 0
        case notContinuous = 1
        case phoneAgencyToArrange = 2
        case coordinateWithDriver = 3
    }
    
    public enum TimepointType: Int, Codable {
        case approximate = 0
        case exact = 1
    }
    
    public var tripIdentifier: String
    public var arrivalTime: Date
    public var departureTime: Date
    public var stopIdentifier: String
    public var stopSequence: UInt
    public var stopHeadsign: String?
    public var pickupType: PickupDropoffMethod?
    public var dropoffType: PickupDropoffMethod?
    public var continuousPickup: ContinuationType?
    public var continuousDropoff: ContinuationType?
    public var shapeDistanceTraveled: Double?
    public var timepoint: TimepointType?
    public var isLastStop: Bool?
}

// For diffing
extension StopTime: Hashable {}

extension StopTime: Codable, PersistableRecord, FetchableRecord {
    public static var databaseTableName = "stop_times"
    public static var databaseDateEncodingStrategy = DatabaseDateEncodingStrategy.formatted(DateFormatter.hhmmss)
    public static var databaseDateDecodingStrategy = DatabaseDateDecodingStrategy.formatted(DateFormatter.hhmmss)
    
    private enum Columns {
        static let tripIdentifier = Column(CodingKeys.tripIdentifier)
        static let arrivalTime = Column(CodingKeys.arrivalTime)
        static let departureTime = Column(CodingKeys.departureTime)
        static let stopIdentifier = Column(CodingKeys.stopIdentifier)
        static let stopSequence = Column(CodingKeys.stopSequence)
        static let stopHeadsign = Column(CodingKeys.stopHeadsign)
        static let pickupType = Column(CodingKeys.pickupType)
        static let dropoffType = Column(CodingKeys.dropoffType)
        static let continuousPickup = Column(CodingKeys.continuousPickup)
        static let continuousDropoff = Column(CodingKeys.continuousDropoff)
        static let shapeDistanceTraveled = Column(CodingKeys.shapeDistanceTraveled)
        static let timepoint = Column(CodingKeys.timepoint)
        static let isLastStop = Column(CodingKeys.isLastStop)
    }
    
    public enum CodingKeys: String, CodingKey {
        case tripIdentifier = "trip_id"
        case arrivalTime = "arrival_time"
        case departureTime = "departure_time"
        case stopIdentifier = "stop_id"
        case stopSequence = "stop_sequence"
        case stopHeadsign = "stop_headsign"
        case pickupType = "pickup_type"
        case dropoffType = "drop_off_type"
        case continuousPickup = "continuous_pickup"
        case continuousDropoff = "continuous_drop_off"
        case shapeDistanceTraveled = "shape_dist_traveled"
        case timepoint = "timepoint"
        case isLastStop = "is_laststop"
    }
}

extension StopTime: DatabaseCreating {
    public static func createTable(db: Database) throws {
        do {
            try db.drop(table: StopTime.databaseTableName)
        } catch {
            Logger.model.log("Table \(StopTime.databaseTableName) does not exist.")
        }

        // now create new table
        // Match legacy schema from master branch
        try db.create(table: StopTime.databaseTableName) { t in
            t.column(CodingKeys.tripIdentifier.rawValue, .text)
            t.column(CodingKeys.arrivalTime.rawValue, Database.ColumnType(rawValue: "time"))
            t.column(CodingKeys.departureTime.rawValue, Database.ColumnType(rawValue: "time"))
            t.column(CodingKeys.stopIdentifier.rawValue, .text)
            t.column(CodingKeys.stopSequence.rawValue, Database.ColumnType(rawValue: "int(11)"))
            t.column(CodingKeys.timepoint.rawValue, Database.ColumnType(rawValue: "tinyint(1)"))
            t.column(CodingKeys.isLastStop.rawValue, Database.ColumnType(rawValue: "tinyint(1)"))
        }

        // Create indexes manually to match master schema
        try db.create(index: "stop_id_stop_times", on: StopTime.databaseTableName, columns: [CodingKeys.stopIdentifier.rawValue])
        try db.create(index: "trip_id_stop_times", on: StopTime.databaseTableName, columns: [CodingKeys.tripIdentifier.rawValue])
    }
}

extension StopTime: CustomStringConvertible {
    public var description: String {
        return "\(tripIdentifier): \(stopSequence), \(arrivalTime) - \(departureTime)"
    }
}
