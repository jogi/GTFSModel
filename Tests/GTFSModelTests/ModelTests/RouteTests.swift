//
//  RouteTests.swift
//  GTFSModelTests
//
//  Tests for Route model
//

import Foundation
import GRDB
import Testing
@testable import GTFSModel

@Suite("Route Model Tests")
struct RouteTests {

    @Test("Route creates table with correct schema")
    func testTableCreation() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            try Route.createTable(db: db)
        }

        try DatabaseTestHelper.assertTableExists("routes", in: db)

        let columns = try DatabaseTestHelper.columnNames(for: "routes", in: db)
        #expect(columns.contains("route_id"))
        #expect(columns.contains("route_type"))
        #expect(columns.contains("route_short_name"))
        #expect(columns.contains("route_long_name"))
        #expect(columns.contains("route_color"))
        #expect(columns.contains("route_text_color"))
    }

    @Test("Route inserts and fetches from database")
    func testInsertAndFetch() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            try Route.createTable(db: db)
        }

        let route = TestFixtures.sampleRoute(
            identifier: "ROUTE1",
            type: .bus,
            shortName: "22",
            longName: "Palo Alto - San Jose",
            color: "FF0000",
            textColor: "FFFFFF"
        )

        try db.write { db in
            try route.insert(db)
        }

        let fetched = try db.read { db in
            try Route.fetchOne(db, key: "ROUTE1")
        }

        #expect(fetched != nil)
        #expect(fetched?.identifier == "ROUTE1")
        #expect(fetched?.type == .bus)
        #expect(fetched?.shortName == "22")
        #expect(fetched?.longName == "Palo Alto - San Jose")
        #expect(fetched?.color == "FF0000")
        #expect(fetched?.textColor == "FFFFFF")
    }

    @Test("Route handles RouteType enum")
    func testRouteTypeEnum() {
        #expect(Route.RouteType.tram.rawValue == 0)
        #expect(Route.RouteType.subway.rawValue == 1)
        #expect(Route.RouteType.rail.rawValue == 2)
        #expect(Route.RouteType.bus.rawValue == 3)
        #expect(Route.RouteType.ferry.rawValue == 4)
        #expect(Route.RouteType.cableTram.rawValue == 5)
        #expect(Route.RouteType.aerialLift.rawValue == 6)
        #expect(Route.RouteType.funicular.rawValue == 7)
        #expect(Route.RouteType.trolleyBus.rawValue == 11)
        #expect(Route.RouteType.monorail.rawValue == 12)
    }

    @Test("Route handles ContinuationType enum")
    func testContinuationTypeEnum() {
        #expect(Route.ContinuationType.continuous.rawValue == 0)
        #expect(Route.ContinuationType.notContinuous.rawValue == 1)
        #expect(Route.ContinuationType.phoneAgencyToArrange.rawValue == 2)
        #expect(Route.ContinuationType.coordinateWithDriver.rawValue == 3)
    }

    @Test("Route handles optional fields correctly")
    func testOptionalFields() throws {
        let db = try DatabaseTestHelper.createTemporaryDatabase()
        defer { try? DatabaseTestHelper.cleanup(database: db) }

        try db.write { db in
            try Route.createTable(db: db)
        }

        let minimalRoute = Route(
            identifier: "MINIMAL",
            type: .bus,
            agencyIdentifier: nil,
            shortName: nil,
            longName: nil,
            routeDescription: nil,
            url: nil,
            color: nil,
            textColor: nil,
            sortOrder: nil,
            continuousPickup: nil,
            continuousDropoff: nil
        )

        try db.write { db in
            try minimalRoute.insert(db)
        }

        let fetched = try db.read { db in
            try Route.fetchOne(db, key: "MINIMAL")
        }

        #expect(fetched != nil)
        #expect(fetched?.shortName == nil)
        #expect(fetched?.color == nil)
        #expect(fetched?.textColor == nil)
    }
}
