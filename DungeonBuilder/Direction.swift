//
//  Direction.swift
//  DungeonBuilder
//
//  Created by Pierce Darragh on 2/13/19.
//  Copyright © 2019 Pierce Corp. All rights reserved.
//

enum Direction: Int, CaseIterable {
    case North = 0
    case East = 1
    case South = 2
    case West = 3

    static func generateRandom() -> Direction {
        return Direction(rawValue: Int.random(in: 0 ... 3))!
    }

    func toUnitPoint() -> Point {
        switch self {
        case .North: return Point(0, 1)
        case .East: return Point(1, 0)
        case .South: return Point(0, -1)
        case .West: return Point(-1, 0)
        }
    }
}

protocol Directional {
    associatedtype Member

    var northSide: [Member] { get }
    var eastSide: [Member] { get }
    var southSide: [Member] { get }
    var westSide: [Member] { get }
}

extension Directional {
    func getSideForDirection(_ direction: Direction) -> [Member] {
        switch direction {
        case .North: return northSide
        case .East: return eastSide
        case .South: return southSide
        case .West: return westSide
        }
    }
}
