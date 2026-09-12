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
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try values.decode(String.self, forKey: .identifier)
        price = try values.decode(Float.self, forKey: .price)
        currencyType = try values.decode(String.self, forKey: .currencyType)
        paymentMethod = try values.decode(PaymentMethod.self, forKey: .paymentMethod)
        transfers = try values.decodeIfPresent(AllowedTransfers.self, forKey: .transfers) ?? .unlimited
        agencyIdentifier = try values.decodeIfPresent(String.self, forKey: .agencyIdentifier)
        transferDuration = try values.decodeIfPresent(UInt.self, forKey: .transferDuration)
    }

    public static let databaseTableName = "fare_attributes"

    public enum Columns {
        public static let identifier = Column(CodingKeys.identifier)
        public static let price = Column(CodingKeys.price)
        public static let currencyType = Column(CodingKeys.currencyType)
        public static let paymentMethod = Column(CodingKeys.paymentMethod)
        public static let transfers = Column(CodingKeys.transfers)
        public static let agencyIdentifier = Column(CodingKeys.agencyIdentifier)
        public static let transferDuration = Column(CodingKeys.transferDuration)
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

        try db.create(table: FareAttribute.databaseTableName) { t in
            t.column(CodingKeys.identifier.rawValue, .text).notNull().primaryKey()
            t.column(CodingKeys.price.rawValue, .double).notNull()
            t.column(CodingKeys.currencyType.rawValue, .text).notNull()
            t.column(CodingKeys.paymentMethod.rawValue, .integer).notNull()
            t.column(CodingKeys.transfers.rawValue, .integer).notNull()
            t.column(CodingKeys.agencyIdentifier.rawValue, .text)
            t.column(CodingKeys.transferDuration.rawValue, .integer)
        }
    }
}

extension FareAttribute: CustomStringConvertible {
    public var description: String {
        return "\(identifier): \(price) - \(currencyType)"
    }
}
