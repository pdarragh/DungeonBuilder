//
//  Dungeon.swift
//  DungeonBuilder
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
    var blocks: [[Block]]  // y-indexed first, then x-indexed; (0, 0) is the bottom-left corner, so all coordinates have positive values
    public let width: Int
    public let height: Int

    public convenience init(minWidth: Int? = nil, maxWidth: Int? = nil, minHeight: Int? = nil, maxHeight: Int? = nil, modifier: Double? = nil) {
        self.init(minWidth: minWidth ?? MIN_WIDTH, maxWidth: maxWidth ?? DEFAULT_SIZE, minHeight: minHeight ?? MIN_HEIGHT, maxHeight: maxHeight ?? DEFAULT_SIZE, modifier: modifier ?? DEFAULT_MODIFIER)
    }

    init(minWidth: Int, maxWidth: Int, minHeight: Int, maxHeight: Int, modifier: Double) {
        // Generate width and height.
        width = Int.random(in: max(Int(modifier * Double(maxWidth)), minWidth) ... maxWidth)
        height = Int.random(in: max(Int(modifier * Double(maxHeight)), minHeight) ... maxHeight)
        maxRoomWidth = Int.random(in: minRoomWidth ... Int(modifier * Double(width / 5)))
        maxRoomHeight = Int.random(in: minRoomHeight ... Int(modifier * Double(height / 5)))
        // Generate uninitialized blocks to populate the list.
        let xRange = 0 ..< width
        let yRange = 0 ..< height
        blocks = yRange.map { y in xRange.map { x in Block(type: .Uninitialized, x: x, y: y) }}
        // Begin excavation.
        excavate()
    }

    public func flatMapBlocks<T>(_ transform: ((Block) -> T)) -> [T] {
        return blocks.flatMap { $0.map { transform($0) } }
    }

    public func forEachBlock(_ body: ((Block) -> Void)) {
        blocks.forEach{ $0.forEach { body($0) } }
    }

    private func excavate() {
        generateRooms().forEach{ room in
            fill(from: room.bottomLeftCorner, to: room.topRightCorner, withBlockType: .Empty)
        }
    }

    private func fill(from pointA: Point, to pointB: Point, withBlockType blockType: BlockType) {
        for y in pointA.y ... pointB.y {
            for x in pointA.x ... pointB.x {
                setBlockAt(x: x, y: y, toValue: Block(type: blockType, x: x, y: y))
            }
        }
    }

    public func getBlockAt(x: Int, y: Int) -> Block? {
        guard x >= 0 && x < width else {
            return nil
        }
        guard y >= 0 && y < height else {
            return nil
        }
        return blocks[y][x]  // y-indexed first, then x-indexed
    }

    public func getBlockAt(point: Point) -> Block? {
        return getBlockAt(x: point.x, y: point.y)
    }

    private func setBlockAt(x: Int, y: Int, toValue block: Block) {
        blocks[y][x] = block  // y-indexed first, then x-indexed
    }

    private func generateRooms() -> [Room] {
        let attempts = 100
        let maxRooms = 10
        var rooms: [Room] = []
        for _ in 0 ..< attempts {
            let newRoom = generateRoom()
            var roomOverlaps = false
            for room in rooms {
                if newRoom.overlapsWith(other: room) {
                    roomOverlaps = true
                    break
                }
            }
            if roomOverlaps {
                continue
            }
            rooms.append(newRoom)
            if rooms.count >= maxRooms {
                break
            }
        }
        return rooms
    }

    private func generateRoom() -> Room {
        let roomWidth = Int.random(in: minRoomWidth ... maxRoomWidth)
        let roomHeight = Int.random(in: minRoomHeight ... maxRoomHeight)
        let start = Point.generateRandomPoint(xMin: 0, xMax: width - 1 - roomWidth, yMin: 0, yMax: height - 1 - roomHeight)
        let end = Point(start.x + roomWidth, start.y + roomHeight)
        let room = Dungeon.Room(bottomLeftCorner: start, topRightCorner: end)
        return room
    }

    private class Room {
        let bottomLeftCorner: Point
        let bottomRightCorner: Point
        let topLeftCorner: Point
        let topRightCorner: Point
        let corners: [Point]

        convenience init(bottomLeftCorner: Point, topRightCorner: Point) {
            let bottomRightCorner = Point(topRightCorner.x, bottomLeftCorner.y)
            let topLeftCorner = Point(bottomLeftCorner.x, topRightCorner.y)
            self.init(bottomLeftCorner: bottomLeftCorner, bottomRightCorner: bottomRightCorner, topLeftCorner: topLeftCorner, topRightCorner: topRightCorner)
        }

        init(bottomLeftCorner: Point, bottomRightCorner: Point, topLeftCorner: Point, topRightCorner: Point) {
            self.bottomLeftCorner = bottomLeftCorner
            self.bottomRightCorner = bottomRightCorner
            self.topLeftCorner = topLeftCorner
            self.topRightCorner = topRightCorner
            self.corners = [self.bottomLeftCorner, self.bottomRightCorner, self.topLeftCorner, self.topRightCorner]
        }

        func leftX() -> Int {
            return self.bottomLeftCorner.x  // This is identical to topLeftCorner.x.
        }

        func rightX() -> Int {
            return self.bottomRightCorner.x  // This is identical to topRightCorner.x.
        }

        func bottomY() -> Int {
            return self.bottomLeftCorner.y  // This is identical to bottomRightCorner.y.
        }

        func topY() -> Int {
            return self.topLeftCorner.y  // This is identical to topRightCorner.y.
        }

        func containsPoint(_ point: Point) -> Bool {
            // It is assumed that the bottom-left is the least-valued corner (i.e., is the closest to the origin).
            return point.x >= leftX() && point.x <= rightX() && point.y >= bottomY() && point.y <= topY()
        }

        static func overlapsWith(lhs: Room, rhs: Room) -> Bool {
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

        func overlapsWith(other: Room) -> Bool {
            return Room.overlapsWith(lhs: self, rhs: other)
        }
    }
}
