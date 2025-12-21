//
//  File.swift
//  
//
//  Created by Vashishtha Jogi on 8/16/24.
//

import Foundation
import OSLog

extension Logger {
    private static let subsystem = "com.jogi.gtfs-model"

    static let model = Logger(subsystem: subsystem, category: "model")
}

