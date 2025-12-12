//
//  FareAttribute.swift
//  
//
//  Created by Vashishtha Jogi on 6/20/20.
//

import Foundation
import GRDB
import OSLog

public struct FareAttribute {
    public enum PaymentMethod: Int, Codable {
        case paidOnBoard = 0
        case paidBeforeBoarding = 1
    }
    public enum AllowedTransfers: Int, Codable {
        case no = 0
        case once = 1
        case twice = 2
        case unlimited = -1
    }

    public var identifier: String
    public var price: Float
    public var currencyType: String
    public var paymentMethod: PaymentMethod
    public var transfers: AllowedTransfers = .unlimited
    public var agencyIdentifier: String?
    public var transferDuration: UInt?
}

// For diffing
extension FareAttribute: Hashable {}

extension FareAttribute: Codable, PersistableRecord, FetchableRecord {
    public static var databaseTableName = "fare_attributes"
    
    private enum Columns {
        static let identifier = Column(CodingKeys.identifier)
        static let price = Column(CodingKeys.price)
        static let currencyType = Column(CodingKeys.currencyType)
        static let paymentMethod = Column(CodingKeys.paymentMethod)
        static let transfers = Column(CodingKeys.transfers)
        static let agencyIdentifier = Column(CodingKeys.agencyIdentifier)
        static let transferDuration = Column(CodingKeys.transferDuration)
    }
    
    public enum CodingKeys: String, CodingKey {
        case identifier = "fare_id"
        case price
        case currencyType = "currency_type"
        case paymentMethod = "payment_method"
        case transfers
        case agencyIdentifier = "agency_id"
        case transferDuration = "transfer_duration"
    }
}

extension FareAttribute: DatabaseCreating {
    public static func createTable(db: Database) throws {
        do {
            try db.drop(table: FareAttribute.databaseTableName)
        } catch {
            Logger.model.log("Table \(FareAttribute.databaseTableName) does not exist.")
        }

        // now create new table
        // Match legacy schema from master branch
        try db.create(table: FareAttribute.databaseTableName) { t in
            t.column(CodingKeys.identifier.rawValue, .text).notNull().primaryKey()
            t.column(CodingKeys.price.rawValue, Database.ColumnType(rawValue: "FLOAT")).defaults(to: 0.0)
            t.column(CodingKeys.currencyType.rawValue, .text)
            t.column(CodingKeys.paymentMethod.rawValue, Database.ColumnType(rawValue: "INT(2)"))
            t.column(CodingKeys.transfers.rawValue, Database.ColumnType(rawValue: "INT(11)"))
            t.column(CodingKeys.transferDuration.rawValue, Database.ColumnType(rawValue: "INT(11)"))
        }
    }
}

extension FareAttribute: CustomStringConvertible {
    public var description: String {
        return "\(identifier): \(price) - \(currencyType)"
    }
}
