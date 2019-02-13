//
//  Point.swift
//  DungeonBuilder
//
//  Created by Pierce Darragh on 2/7/19.
//  Copyright © 2019 Pierce Corp. All rights reserved.
//

public struct Point: Comparable, CustomStringConvertible, DirectionIndexable {
    typealias DirectionalElement = Point

    public static let Origin = Point(0, 0)
    public static let NorthUnit = Point(0, 1)
    public static let NorthEastUnit = Point(1, 1)
    public static let EastUnit = Point(1, 0)
    public static let SouthEastUnit = Point(1, -1)
    public static let SouthUnit = Point(0, -1)
    public static let SouthWestUnit = Point(-1, -1)
    public static let WestUnit = Point(-1, 0)
    public static let NorthWestUnit = Point(-1, 1)

    public let x: Int
    public let y: Int

    public var description: String { return "(\(self.x), \(self.y))" }

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    /// Returns a point adjacent to the current point in the indicated direction.
    func getElementForDirection(_ direction: Direction) -> Point {
        switch direction {
        case .North: return self + Point.NorthUnit
        case .East: return self + Point.EastUnit
        case .South: return self + Point.SouthUnit
        case .West: return self + Point.WestUnit
        }
    }

    /// Produces a list of the current point and its neighboring points up to `size` points away.
    func neighborhood(ofRadius size: Int = 1) -> Neighborhood {
        return Neighborhood(bottomLeftCorner: self + (Point.SouthWestUnit * size), topRightCorner: self + (Point.NorthEastUnit * size))
    }

    static func generateRandom(xMin: Int, xMax: Int, yMin: Int, yMax: Int) -> Point {
        return Point(Int.random(in: xMin ..< xMax), Int.random(in: yMin ..< yMax))
    }

    public static func distance(lhs: Point, rhs: Point) -> Double {
        let xDist = abs(lhs.x - rhs.x)
        let yDist = abs(lhs.y - rhs.y)
        return Double((xDist * xDist) + (yDist * yDist)).squareRoot()
    }

    public func distanceFrom(other: Point) -> Double {
        return Point.distance(lhs: self, rhs: other)
    }

    public static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    public static func < (lhs: Point, rhs: Point) -> Bool {
        return distance(lhs: Origin, rhs: lhs) < distance(lhs: Origin, rhs: rhs)
    }

    public static func + (lhs: Point, rhs: Point) -> Point {
        return Point(lhs.x + rhs.x, lhs.y + rhs.y)
    }

    public static func - (lhs: Point, rhs: Point) -> Point {
        return Point(lhs.x - rhs.x, lhs.y - rhs.y)
    }

    public static func * (lhs: Point, rhs: Point) -> Point {
        return Point(lhs.x * rhs.x, lhs.y * rhs.y)
    }

    public static func * (point: Point, scalar: Int) -> Point {
        return Point(point.x * scalar, point.y * scalar)
    }

    public static func * (scalar: Int, point: Point) -> Point {
        return point * scalar
    }
}
