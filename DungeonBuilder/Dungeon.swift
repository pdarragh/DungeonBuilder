//
//  Dungeon.swift
//  Trench Digger iOS
//
//  Created by Pierce Darragh on 2/7/19.
//  Copyright © 2019 Pierce Corp. All rights reserved.
//

let DEFAULT_SIZE = 100
let DEFAULT_MODIFIER = 0.8
let MIN_ENDPOINTS_DISTANCE = Double(10)

public class Dungeon {
    let blocks: [[Block]]
    public let width: Int
    public let height: Int
    public let start: Point
    public let end: Point

    public convenience init(maxWidth: Int? = nil, maxHeight: Int? = nil, modifier: Double? = nil) {
        self.init(maxWidth: maxWidth ?? DEFAULT_SIZE, maxHeight: maxHeight ?? DEFAULT_SIZE, modifier: modifier ?? DEFAULT_MODIFIER)
    }

    init(maxWidth: Int, maxHeight: Int, modifier: Double) {
        // Generate width and height.
        width = Int.random(in: Int(modifier * Double(maxWidth)) ... maxWidth)
        height = Int.random(in: Int(modifier * Double(maxHeight)) ... maxHeight)
        // Generate uninitialized blocks to populate the list.
        let xRange = 0 ..< width
        let yRange = 0 ..< height
        blocks = xRange.map { _ in yRange.map { _ in UninitializedBlock() }}
        // Determine start/end positions.
        start = Point.generateRandomPoint(xMin: 0, xMax: width, yMin: 0, yMax: height)
        var tempEnd = start
        while tempEnd.distanceFrom(other: start) < MIN_ENDPOINTS_DISTANCE {
            tempEnd = Point.generateRandomPoint(xMin: 0, xMax: width, yMin: 0, yMax: height)
        }
        end = tempEnd
    }

    public func getBlockAt(x: Int, y: Int) -> Block? {
        guard x >= 0 && x < blocks.count else {
            return nil
        }
        guard y >= 0 && y < blocks[0].count else {
            return nil
        }
        return blocks[x][y]
    }

    public func getBlockAt(point: Point) -> Block? {
        return getBlockAt(x: point.x, y: point.y)
    }
}
