//
//  Neighborhood.swift
//  DungeonBuilder
//
//  Created by Pierce Darragh on 2/13/19.
//  Copyright © 2019 Pierce Corp. All rights reserved.
//

struct Neighborhood: Directional {
    typealias DirectionalElement = [Point]

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

    var leftEdge: [Point] { return (bottomY ... topY).map { y in Point(leftX, y) } }
    var rightEdge: [Point] { return (bottomY ... topY).map { y in Point(rightX, y) } }
    var bottomEdge: [Point] { return (leftX ... rightX).map { x in Point(x, bottomY) } }
    var topEdge: [Point] { return (leftX ... rightX).map { x in Point(x, topY) } }

    var north: [Point] { return self.topEdge }
    var east:  [Point] { return self.rightEdge }
    var south: [Point] { return self.bottomEdge }
    var west:  [Point] { return self.leftEdge }

    init(bottomLeftCorner: Point, topRightCorner: Point) {
        let bottomRightCorner = Point(topRightCorner.x, bottomLeftCorner.y)
        let topLeftCorner = Point(bottomLeftCorner.x, topRightCorner.y)
        self.init(bottomLeftCorner: bottomLeftCorner, bottomRightCorner: bottomRightCorner, topLeftCorner: topLeftCorner, topRightCorner: topRightCorner)
    }

    init(bottomLeftCorner: Point, bottomRightCorner: Point, topLeftCorner: Point, topRightCorner: Point) {
        guard (bottomLeftCorner < topLeftCorner && bottomLeftCorner < bottomRightCorner && bottomLeftCorner < topRightCorner &&
               topRightCorner > topLeftCorner && topRightCorner > bottomRightCorner && topRightCorner > bottomLeftCorner) else {
            fatalError("Neighborhoods must be oriented such that the bottom-left corner is the closest to the origin.")
        }
        self.bottomLeftCorner = bottomLeftCorner
        self.bottomRightCorner = bottomRightCorner
        self.topLeftCorner = topLeftCorner
        self.topRightCorner = topRightCorner
    }

    func containsPoint(_ point: Point) -> Bool {
        // It is assumed that the bottom-left is the least-valued corner (i.e., is the closest to the origin).
        return point.x >= leftX && point.x <= rightX && point.y >= bottomY && point.y <= topY
    }

    static func overlapsWith(lhs: Neighborhood, rhs: Neighborhood) -> Bool {
        for lPoint in lhs.corners {
            if rhs.containsPoint(lPoint) {
                return true
            }
        }
        for rPoint in rhs.corners {
            if lhs.containsPoint(rPoint) {
                return true
            }
        }
        return false
    }

    func overlapsWith(other: Neighborhood) -> Bool {
        return Neighborhood.overlapsWith(lhs: self, rhs: other)
    }
}

