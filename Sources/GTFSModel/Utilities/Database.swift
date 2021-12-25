//
//  Database.swift
//  
//
//  Created by Vashishtha Jogi on 6/14/20.
//

import Foundation
import GRDB

public protocol DatabaseCreating {
    static func createTable() throws
}

public struct DatabaseHelper {
    public var dbQueue: DatabaseQueue?
    
    public init() throws {
        dbQueue = try DatabaseQueue(path: "./gtfs.sqlite")
    }
    
    public func vacuum() throws {
        try dbQueue?.vacuum()
    }
    
    public func reindex() throws {
        try dbQueue?.writeWithoutTransaction { try $0.execute(sql: "REINDEX") }
    }
}
