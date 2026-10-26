import Foundation

public protocol Defaultable: Codable, Hashable, Sendable {
    static var defaultValue: Self { get }
}

@propertyWrapper
public struct Default<T: Defaultable>: Codable, Hashable, Sendable {
    public var wrappedValue: T

    public init(wrappedValue: T = T.defaultValue) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self.wrappedValue = T.defaultValue
        } else {
            self.wrappedValue = try container.decode(T.self)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

extension KeyedDecodingContainer {
    public func decode<T: Defaultable>(
        _ type: Default<T>.Type,
        forKey key: Key
    ) throws -> Default<T> {
        guard let value = try decodeIfPresent(T.self, forKey: key) else {
            return Default(wrappedValue: T.defaultValue)
        }
        return Default(wrappedValue: value)
    }
}
