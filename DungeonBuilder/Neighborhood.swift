//
//  Neighborhood.swift
//  DungeonBuilder
//
//  Created by Pierce Darragh on 2/13/19.
//  Copyright © 2019 Pierce Corp. All rights reserved.
//

struct Neighborhood: DirectionIndexable {
    typealias DirectionalElement = Neighborhood

    let bottomLeftCorner: Point
    let bottomRightCorner: Point
    let topLeftCorner: Point
    let topRightCorner: Point

    var corners: [Point] { return [self.bottomLeftCorner, self.bottomRightCorner, self.topLeftCorner, self.topRightCorner] }
    var pointsGrid: [[Point]] { return (leftX ... rightX).map { x in (bottomY ... topY).map { y in Point(x, y) } } }
    var points: [Point] { return pointsGrid.flatMap { $0 } }

    var leftX: Int { return self.bottomLeftCorner.x }    // Identical to topLeftCorner.x
    var rightX: Int { return self.bottomRightCorner.x }  // Identical to topRightCorner.x
    var bottomY: Int { return self.bottomLeftCorner.y }  // Identical to bottomRightCorner.y
    var topY: Int { return self.topLeftCorner.y }        // Identical to topRightCorner.y

    var leftNeighborhood: Neighborhood { return Neighborhood(bottomLeftCorner: Point(leftX, bottomY), topRightCorner: Point(leftX, topY)) }
    var rightNeighborhood: Neighborhood { return Neighborhood(bottomLeftCorner: Point(rightX, bottomY), topRightCorner: Point(rightX, topY)) }
    var bottomNeighborhood: Neighborhood { return Neighborhood(bottomLeftCorner: Point(leftX, bottomY), topRightCorner: Point(rightX, bottomY)) }
    var topNeighborhood: Neighborhood { return Neighborhood(bottomLeftCorner: Point(leftX, topY), topRightCorner: Point(rightX, topY)) }

    var north: Neighborhood { return self.topNeighborhood }
    var east:  Neighborhood { return self.rightNeighborhood }
    var south: Neighborhood { return self.bottomNeighborhood }
    var west:  Neighborhood { return self.leftNeighborhood }

    init(bottomLeftCorner: Point, topRightCorner: Point) {
        let bottomRightCorner = Point(topRightCorner.x, bottomLeftCorner.y)
        let topLeftCorner = Point(bottomLeftCorner.x, topRightCorner.y)
        self.init(bottomLeftCorner: bottomLeftCorner, bottomRightCorner: bottomRightCorner, topLeftCorner: topLeftCorner, topRightCorner: topRightCorner)
    }

    init(bottomLeftCorner: Point, bottomRightCorner: Point, topLeftCorner: Point, topRightCorner: Point) {
        guard (bottomLeftCorner <= topLeftCorner && bottomLeftCorner <= bottomRightCorner && bottomLeftCorner <= topRightCorner &&
               topRightCorner >= topLeftCorner && topRightCorner >= bottomRightCorner && topRightCorner >= bottomLeftCorner) else {
            fatalError("Neighborhoods must be oriented such that the bottom-left corner is the closest to the origin and the top-right corner is farthest.")
        }
        self.bottomLeftCorner = bottomLeftCorner
        self.bottomRightCorner = bottomRightCorner
        self.topLeftCorner = topLeftCorner
        self.topRightCorner = topRightCorner
    }

    func translate(inDirection direction: Direction, byAmount amount: Int) -> Neighborhood {
        let offset = Point.getUnitPointForDirection(direction) * amount
        return Neighborhood(bottomLeftCorner: self.bottomLeftCorner + offset, topRightCorner: self.topRightCorner + offset)
    }

    func getElementForDirection(_ direction: Direction) -> Neighborhood {
        switch direction {
        case .North: return north
        case .East: return east
        case .South: return south
        case .West: return west
        }
    }

    func getDirectionalEdges() -> [(Direction, Neighborhood)] {
        return Direction.allCases.map { direction in
            return (direction, self.getElementForDirection(direction))
        }
    }

    func contains(point: Point) -> Bool {
        // It is assumed that the bottom-left is the least-valued corner (i.e., is the closest to the origin).
        return point.x >= leftX && point.x <= rightX && point.y >= bottomY && point.y <= topY
    }

    func contains(neighborhood other: Neighborhood) -> Bool {
        return other.corners.allSatisfy({ self.contains(point: $0) })
    }

    func overlapsWithNeighborhood(_ other: Neighborhood) -> Bool {
        for lPoint in self.corners {
            if other.contains(point: lPoint) {
                return true
            }
        }
        for rPoint in other.corners {
            if self.contains(point: rPoint) {
                return true
            }
        }
        return false
    }
}

