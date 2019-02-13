//
//  Point.swift
//  DungeonBuilder
//
//  Created by Pierce Darragh on 2/7/19.
//  Copyright © 2019 Pierce Corp. All rights reserved.
//

public struct Point: Comparable, CustomStringConvertible {
    public static let Origin = Point(0, 0)

    public let x: Int
    public let y: Int

    public var description: String { return "(\(self.x), \(self.y))" }

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    /// Produces a list of the current point and its neighboring points up to `size` points away.
    public func neighborhood(ofSize size: Int = 1) -> [Point] {
        return (-size ... size).flatMap { x in (-size ... size).map { y in self + Point(x, y) } }
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
}
