//
//  TestFixtures.swift
//  GTFSModelTests
//
//  Factory methods for creating sample GTFS entities for testing
//

import Foundation
@testable import GTFSModel

enum TestFixtures {
    // MARK: - Agency

    static func sampleAgency(
        identifier: String = "TEST_AGENCY",
        name: String = "Test Transit Agency",
        url: URL = URL(string: "https://test.example.com")!,
        timezone: String = "America/Los_Angeles",
        language: String? = "en",
        phone: String? = "555-1234",
        fareURL: URL? = URL(string: "https://test.example.com/fares"),
        email: String? = "test@example.com"
    ) -> Agency {
        Agency(
            identifier: identifier,
            name: name,
            url: url,
            timezone: timezone,
            language: language,
            phone: phone,
            fareURL: fareURL,
            email: email
        )
    }

    // MARK: - Stop

    static func sampleStop(
        identifier: String = "STOP1",
        code: String? = "S1",
        name: String? = "Test Stop",
        stopDescription: String? = "A test stop",
        latitude: Double = 37.7749,
        longitude: Double = -122.4194,
        zoneIdentifier: String? = "1",
        locationType: Stop.LocationType = .stop,
        parentStation: String? = nil,
        timezone: String? = nil,
        wheelchairBording: Stop.WheelchairBoarding = .noInformation,
        levelIdentifier: String? = nil,
        platformCode: String? = nil,
        routes: String? = nil
    ) -> Stop {
        Stop(
            identifier: identifier,
            code: code,
            name: name,
            stopDescription: stopDescription,
            latitude: latitude,
            longitude: longitude,
            zoneIdentifier: zoneIdentifier,
            locationType: locationType,
            parentStation: parentStation,
            timezone: timezone,
            wheelchairBording: wheelchairBording,
            levelIdentifier: levelIdentifier,
            platformCode: platformCode,
            routes: routes
        )
    }

    // MARK: - Route

    static func sampleRoute(
        identifier: String = "ROUTE1",
        type: Route.RouteType = .bus,
        agencyIdentifier: String? = "TEST_AGENCY",
        shortName: String? = "1",
        longName: String? = "Test Route",
        routeDescription: String? = "A test bus route",
        url: URL? = nil,
        color: String? = "FF0000",
        textColor: String? = "FFFFFF",
        sortOrder: Int? = 1,
        continuousPickup: Route.ContinuationType? = .notContinuous,
        continuousDropoff: Route.ContinuationType? = .notContinuous
    ) -> Route {
        Route(
            identifier: identifier,
            type: type,
            agencyIdentifier: agencyIdentifier,
            shortName: shortName,
            longName: longName,
            routeDescription: routeDescription,
            url: url,
            color: color,
            textColor: textColor,
            sortOrder: sortOrder,
            continuousPickup: continuousPickup,
            continuousDropoff: continuousDropoff
        )
    }

    // MARK: - Calendar

    static func sampleCalendar(
        serviceIdentifier: String = "WEEKDAY",
        startDate: Date = Date(),
        endDate: Date = Date().addingTimeInterval(86400 * 365), // 1 year from now
        monday: GTFSModel.Calendar.Availability = .available,
        tuesday: GTFSModel.Calendar.Availability = .available,
        wednesday: GTFSModel.Calendar.Availability = .available,
        thursday: GTFSModel.Calendar.Availability = .available,
        friday: GTFSModel.Calendar.Availability = .available,
        saturday: GTFSModel.Calendar.Availability = .unavailable,
        sunday: GTFSModel.Calendar.Availability = .unavailable
    ) -> GTFSModel.Calendar {
        GTFSModel.Calendar(
            serviceIdentifier: serviceIdentifier,
            startDate: startDate,
            endDate: endDate,
            monday: monday,
            tuesday: tuesday,
            wednesday: wednesday,
            thursday: thursday,
            friday: friday,
            saturday: saturday,
            sunday: sunday
        )
    }

    // MARK: - Trip

    static func sampleTrip(
        identifier: String = "TRIP1",
        routeIdentifier: String = "ROUTE1",
        serviceIdentifier: String = "WEEKDAY",
        headsign: String? = "Downtown",
        shortName: String? = nil,
        directionIdentifier: Int? = nil,
        blockIdentifier: String? = nil,
        shapeIdentifier: String? = nil,
        wheelchairAccessible: Trip.WheelchairAccessibility? = .noInformation,
        bikesAllowed: Trip.BikeAllowance? = .noInformation
    ) -> Trip {
        Trip(
            identifier: identifier,
            routeIdentifier: routeIdentifier,
            serviceIdentifier: serviceIdentifier,
            headSign: headsign,
            shortName: shortName,
            directionIdentifier: directionIdentifier,
            blockIdentifier: blockIdentifier,
            shapeIdentifier: shapeIdentifier,
            wheelchairAccessible: wheelchairAccessible,
            bikesAllowed: bikesAllowed
        )
    }

    // MARK: - StopTime

    static func sampleStopTime(
        tripIdentifier: String = "TRIP1",
        arrivalTime: Date = Date(),
        departureTime: Date = Date(),
        stopIdentifier: String = "STOP1",
        stopSequence: UInt = 1,
        stopHeadsign: String? = nil,
        pickupType: StopTime.PickupDropoffMethod? = .regularlyScheduled,
        dropoffType: StopTime.PickupDropoffMethod? = .regularlyScheduled,
        continuousPickup: StopTime.ContinuationType? = .notContinuous,
        continuousDropoff: StopTime.ContinuationType? = .notContinuous,
        shapeDistanceTraveled: Double? = nil,
        timepoint: StopTime.TimepointType? = .exact,
        isLastStop: Bool? = false
    ) -> StopTime {
        StopTime(
            tripIdentifier: tripIdentifier,
            arrivalTime: arrivalTime,
            departureTime: departureTime,
            stopIdentifier: stopIdentifier,
            stopSequence: stopSequence,
            stopHeadsign: stopHeadsign,
            pickupType: pickupType,
            dropoffType: dropoffType,
            continuousPickup: continuousPickup,
            continuousDropoff: continuousDropoff,
            shapeDistanceTraveled: shapeDistanceTraveled,
            timepoint: timepoint,
            isLastStop: isLastStop
        )
    }

    // MARK: - Shape

    static func sampleShape(
        identifier: String = "SHAPE1",
        latitude: Double = 37.7749,
        longitude: Double = -122.4194,
        sequence: UInt = 1,
        distanceTraveled: Double? = 0
    ) -> Shape {
        Shape(
            identifier: identifier,
            latitude: latitude,
            longitude: longitude,
            sequence: sequence,
            distanceTraveled: distanceTraveled
        )
    }

    // MARK: - FareAttribute

    static func sampleFareAttribute(
        identifier: String = "FARE1",
        price: Float = 2.50,
        currencyType: String = "USD",
        paymentMethod: FareAttribute.PaymentMethod = .paidOnBoard,
        transfers: FareAttribute.AllowedTransfers = .unlimited,
        agencyIdentifier: String? = "TEST_AGENCY",
        transferDuration: UInt? = 5400 // 90 minutes
    ) -> FareAttribute {
        FareAttribute(
            identifier: identifier,
            price: price,
            currencyType: currencyType,
            paymentMethod: paymentMethod,
            transfers: transfers,
            agencyIdentifier: agencyIdentifier,
            transferDuration: transferDuration
        )
    }

    // MARK: - FareRule

    static func sampleFareRule(
        fareIdentifier: String = "FARE1",
        routeIdentifier: String? = "ROUTE1",
        originIdentifier: String? = nil,
        destinationIdentifier: String? = nil,
        containsIdentifier: String? = nil
    ) -> FareRule {
        FareRule(
            fareIdentifier: fareIdentifier,
            routeIdentifier: routeIdentifier,
            originIdentifier: originIdentifier,
            destinationIdentifier: destinationIdentifier,
            containsIdentifier: containsIdentifier
        )
    }

    // MARK: - CalendarDate

    static func sampleCalendarDate(
        serviceIdentifier: String = "WEEKDAY",
        date: Date = Date(),
        exceptionType: CalendarDate.ExceptionType = .added
    ) -> CalendarDate {
        CalendarDate(
            serviceIdentifier: serviceIdentifier,
            date: date,
            exceptionType: exceptionType
        )
    }

    // MARK: - Direction

    static func sampleDirection(
        identifier: Int = 0,
        routeIdentifier: String = "ROUTE1",
        direction: Direction.DirectionType = .north,
        name: String? = "Northbound"
    ) -> Direction {
        Direction(
            identifier: identifier,
            routeIdentifier: routeIdentifier,
            direction: direction,
            name: name
        )
    }
}
