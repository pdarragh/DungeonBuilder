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
let MIN_WIDTH = 40
let MIN_HEIGHT = 20
let MIN_ROOM_WIDTH = 5
let MIN_ROOM_HEIGHT = 5

/*

 Generating a dungeon

 1. Randomly create open rooms in the space.
    a. Use "variability" parameter to determine how much the rooms can vary from one another.
 2. Connect rooms with smaller corridors.
 3. Select one room to have entrance.
 4. Select another room (minimum distance away?) for exit.

 Considerations:

 - are all rooms rectangular?
 - can rooms connect to on another?
 - can rooms overlap?
 - do rooms need to be abstracted?
 - ensure rooms do not reach beyond valid boundaries
 - allow using full area; edges can be enforced in other ways

 */


public class Dungeon {
    let minRoomWidth: Int = MIN_ROOM_WIDTH
    let maxRoomWidth: Int
    let minRoomHeight: Int = MIN_ROOM_HEIGHT
    let maxRoomHeight: Int
    var blocks: [[Block]]
    public let width: Int
    public let height: Int

    public convenience init(minWidth: Int? = nil, maxWidth: Int? = nil, minHeight: Int? = nil, maxHeight: Int? = nil, modifier: Double? = nil) {
        self.init(minWidth: minWidth ?? MIN_WIDTH, maxWidth: maxWidth ?? DEFAULT_SIZE, minHeight: minHeight ?? MIN_HEIGHT, maxHeight: maxHeight ?? DEFAULT_SIZE, modifier: modifier ?? DEFAULT_MODIFIER)
    }

    init(minWidth: Int, maxWidth: Int, minHeight: Int, maxHeight: Int, modifier: Double) {
        // Generate width and height.
        width = Int.random(in: max(Int(modifier * Double(maxWidth)), minWidth) ... maxWidth)
        height = Int.random(in: max(Int(modifier * Double(maxHeight)), minHeight) ... maxHeight)
        maxRoomWidth = Int.random(in: minRoomWidth ... Int(modifier * Double(width / 4)))
        maxRoomHeight = Int.random(in: minRoomHeight ... Int(modifier * Double(height / 5)))
        // Generate uninitialized blocks to populate the list.
        let xRange = 0 ..< width
        let yRange = 0 ..< height
        blocks = xRange.map { _ in yRange.map { _ in UninitializedBlock() }}
        // Begin excavation.
        excavate()

//        // Determine start/end positions.
//        start = Point.generateRandomPoint(xMin: 0, xMax: width, yMin: 0, yMax: height)
//        var tempEnd = start
//        while tempEnd.distanceFrom(other: start) < MIN_ENDPOINTS_DISTANCE {
//            tempEnd = Point.generateRandomPoint(xMin: 0, xMax: width, yMin: 0, yMax: height)
//        }
//        end = tempEnd
    }

    private func excavate() {
        // This initial implementation builds left-to-right dungeons (with vertical variance).
        // TODO: Allow for more interesting dungeons.
        // Pick a starting point somewhere on the left tenth of the dungeon.
        let roomWidth = Int.random(in: minRoomWidth ... maxRoomWidth)
        let roomHeight = Int.random(in: minRoomHeight ... maxRoomHeight)
        let start = Point.generateRandomPoint(xMin: 0, xMax: width / 5, yMin: 0, yMax: height - roomHeight)
        // The starting block is the bottom-left corner of the first room. Move rightwards.
        let end = Point(start.x + roomWidth, start.y + roomHeight)
        fill(from: start, to: end, withBlockType: EmptyBlock.self)
    }

    private func fill(from pointA: Point, to pointB: Point, withBlockType blockType: Block.Type) {
        (pointA.x ... pointB.x).forEach { x in
            (pointA.y ... pointB.y).forEach { y in
                blocks[x][y] = blockType.init()
            }
        }
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
