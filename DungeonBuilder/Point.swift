//
//  Point.swift
//  DungeonBuilder
//
//  Created by Pierce Darragh on 2/7/19.
//  Copyright © 2019 Pierce Corp. All rights reserved.
//

public class Point: Comparable, CustomStringConvertible {
    public static let Origin = Point(0, 0)

    public let x: Int
    public let y: Int

    public var description: String { return "(\(self.x), \(self.y))" }

    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }

    static func generateRandomPoint(xMin: Int, xMax: Int, yMin: Int, yMax: Int) -> Point {
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
}
