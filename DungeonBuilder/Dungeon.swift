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

typealias Room = Neighborhood

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

    public func forEachPoint(_ body: ((Point) -> Void)) {
        for y in 0 ..< height {
            for x in 0 ..< width {
                body(Point(x, y))
            }
        }
    }

    private func excavate() {
        generateRooms().forEach{ room in
            fill(in: room, withBlockType: .EmptyRoom)
        }
        forEachPoint { point in
            generatePassageFromPoint(point: point, passageWidth: 3, minimumGap: 1)
        }
    }

    private func fill(in room: Room, withBlockType blockType: BlockType) {
        fill(from: room.bottomLeftCorner, to: room.topRightCorner, withBlockType: blockType)
    }

    private func fill(from pointA: Point, to pointB: Point, withBlockType blockType: BlockType) {
        for y in pointA.y ... pointB.y {
            for x in pointA.x ... pointB.x {
                setBlockAt(x: x, y: y, toValue: Block(type: blockType, x: x, y: y))
            }
        }
    }

    private func generatePassageFromPoint(point: Point, passageWidth: Int, minimumGap: Int) {
        // Determine which points (including the current one) are actually valid. This depends on two factors:
        //   1. Each point exists within the map (not out of bounds).
        //   2. The block at each point is uninitialized.
        let radius = (passageWidth - (passageWidth % 2)) / 2
        let neighborhood = point.neighborhood(ofRadius: radius)
        guard neighborhood.points.allSatisfy({ blockAt(point: $0)?.type == .Uninitialized }) else {
            return
        }
        // Ensure the minimum gap is satisfied on all sides.
        for scalar in 1 ... minimumGap {
            let lookaheadPoints = neighborhood.getDirectionalEdges().flatMap { (direction, neighborhood) in
                neighborhood.getElementForDirection(direction).points.map { $0 + (Point.getUnitPointForDirection(direction) * scalar) }
            }
            guard lookaheadPoints.allSatisfy({ blockAt(point: $0)?.type == .Uninitialized }) else {
                return
            }
        }
        // Excavate the neighborhood.
        fill(in: neighborhood, withBlockType: .EmptyPassage)
        // Then excavate until we can't anymore.
        var center: Point = point
        while true {
            let neighborhood = center.neighborhood(ofRadius: radius)
            // Filter the edges to find only those which are valid for further excavation.
            let validDirectionalEdges = neighborhood.getDirectionalEdges().filter({ (direction, edge) in
                // Ensure a single step in the given direction would be acceptable.
                guard edge.points.map({ $0 + (Point.getUnitPointForDirection(direction) * minimumGap) }).allSatisfy({ blockAt(point: $0)?.type == .Uninitialized }) else {
                    return false
                }
                // Check that the gaps orthogonal to the given direction would be maintained.
                return direction.orthogonal.allSatisfy({ orth in
                    // For each orthogonal direction...
                    return (1 ... minimumGap).allSatisfy({ scalar in
                        edge.getElementForDirection(orth).points.allSatisfy({ point in
                            blockAt(point: point + (Point.getUnitPointForDirection(orth) * scalar))?.type == .Uninitialized
                        })
                    })
                })
            })
            // Pick a random direction to go.
            guard let (digDirection, digEdge) = validDirectionalEdges.randomElement() else {
                // There were no valid directions in which to dig.
                return
            }
            // A direction has been selected. Perform the excavation.
            fill(in: digEdge, withBlockType: .EmptyPassage)
            center = center.getElementForDirection(digDirection)
        }
    }

    public func blockAt(x: Int, y: Int) -> Block? {
        guard x >= 0 && x < width else {
            return nil
        }
        guard y >= 0 && y < height else {
            return nil
        }
        return blocks[y][x]  // y-indexed first, then x-indexed
    }

    public func blockAt(point: Point) -> Block? {
        return blockAt(x: point.x, y: point.y)
    }

    private func setBlockAt(x: Int, y: Int, toValue block: Block) {
        blocks[y][x] = block  // y-indexed first, then x-indexed
    }

    private func setBlockAt(point: Point, toType type: BlockType) {
        setBlockAt(x: point.x, y: point.y, toValue: Block(type: type, x: point.x, y: point.y))
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
        let start = Point.generateRandom(xMin: 0, xMax: width - 1 - roomWidth, yMin: 0, yMax: height - 1 - roomHeight)
        let end = Point(start.x + roomWidth, start.y + roomHeight)
        let room = Room(bottomLeftCorner: start, topRightCorner: end)
        return room
    }
}
