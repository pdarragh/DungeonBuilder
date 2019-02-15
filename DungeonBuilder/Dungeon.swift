//
//  Dungeon.swift
//  DungeonBuilder
//
//  Created by Pierce Darragh on 2/7/19.
//  Copyright © 2019 Pierce Corp. All rights reserved.
//

let DEFAULT_MAX_SIZE = 100
let DEFAULT_MODIFIER = 0.8
let MIN_ENDPOINTS_DISTANCE = Double(10)
let DEFAULT_MIN_WIDTH = 40
let DEFAULT_MIN_HEIGHT = 20
let DEFAULT_MIN_ROOM_WIDTH = 5
let DEFAULT_MIN_ROOM_HEIGHT = 5

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

public class Dungeon  {
    let minRoomWidth: Int
    let maxRoomWidth: Int
    let minRoomHeight: Int
    let maxRoomHeight: Int
    var blocks: [[Block]]  // y-indexed first, then x-indexed; (0, 0) is the bottom-left corner, so all coordinates have positive values
    public var images: [UIImage] = []
    public let width: Int
    public let height: Int

    public convenience init(minWidth: Int? = nil, maxWidth: Int? = nil, minHeight: Int? = nil, maxHeight: Int? = nil, minRoomWidth: Int? = nil, minRoomHeight: Int? = nil, modifier: Double? = nil) {
        self.init(minWidth: minWidth ?? DEFAULT_MIN_WIDTH, maxWidth: maxWidth ?? DEFAULT_MAX_SIZE, minHeight: minHeight ?? DEFAULT_MIN_HEIGHT, maxHeight: maxHeight ?? DEFAULT_MAX_SIZE, minRoomWidth: minRoomWidth ?? DEFAULT_MIN_ROOM_WIDTH, minRoomHeight: minRoomHeight ?? DEFAULT_MIN_ROOM_HEIGHT, modifier: modifier ?? DEFAULT_MODIFIER)
    }

    init(minWidth: Int, maxWidth: Int, minHeight: Int, maxHeight: Int, minRoomWidth: Int, minRoomHeight: Int, modifier: Double) {
        // Generate width and height.
        self.width = Int.random(in: max(Int(modifier * Double(maxWidth)), minWidth) ... maxWidth)
        self.height = Int.random(in: max(Int(modifier * Double(maxHeight)), minHeight) ... maxHeight)
        self.minRoomWidth = minRoomWidth
        self.minRoomHeight = minRoomHeight
        self.maxRoomWidth = Int.random(in: minRoomWidth ... Int(modifier * Double(width / 5)))
        self.maxRoomHeight = Int.random(in: minRoomHeight ... Int(modifier * Double(height / 5)))
        // Generate uninitialized blocks to populate the list.
        let xRange = 0 ..< width
        let yRange = 0 ..< height
        self.blocks = yRange.map { y in xRange.map { x in Block(type: .Uninitialized, x: x, y: y) }}
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
        let radius = convertPassageWidthToRadius(passageWidth)
        let neighborhood = point.neighborhood(ofRadius: radius)
        guard canExcavateNeighborhood(neighborhood, withMinimumGap: minimumGap) else {
            return
        }
        excavateNeighborhood(neighborhood)
        if let image = render() {
            images.append(image)
        }
        // Then excavate until we can't anymore.
        var maybeNeighborhood: Neighborhood? = neighborhood
        while let neighborhood = maybeNeighborhood {
            // Attempt a step.
            maybeNeighborhood = takeExcavationStep(withNeighborhood: neighborhood, withMinimumGap: minimumGap)
            if let image = render() {
                images.append(image)
            }
        }
    }

    private func takeExcavationStep(withNeighborhood neighborhood: Neighborhood, withMinimumGap minimumGap: Int) -> Neighborhood? {
        // Determine which directions are valid.
        let validDirectionalEdges = neighborhood.getDirectionalEdges().filter({ (direction, edge) in
            return canExcavateNeighborhood(edge, inDirection: direction, withMinimumGap: minimumGap)
        })
        // Pick just one of those.
        guard let (direction, _) = validDirectionalEdges.randomElement() else {
            // There were no valid directions to dig.
            return nil
        }
        // Dig it out and return the new neighborhood.
        let newNeighborhood = neighborhood.translate(inDirection: direction, byAmount: 1)
        excavateNeighborhood(newNeighborhood)
        return newNeighborhood
    }

    private func convertPassageWidthToRadius(_ passageWidth: Int) -> Int {
        return (passageWidth - (passageWidth % 2)) / 2
    }

    private func canExcavateNeighborhood(_ neighborhood: Neighborhood, withMinimumGap minimumGap: Int) -> Bool {
        // Check that every point in this neighborhood is uninitialized.
        guard neighborhood.points.allSatisfy({ blockAt(point: $0)?.type == .Uninitialized }) else {
            return false
        }
        // Ensure the minimum gap is satisfied on all sides.
        guard Direction.allCases.allSatisfy({ canExcavateNeighborhood(neighborhood, inDirection: $0, withMinimumGap: minimumGap) }) else {
            return false
        }
        // Everything checks out.
        return true
    }

    private func canExcavateNeighborhood(_ neighborhood: Neighborhood, inDirection direction: Direction, withMinimumGap minimumGap: Int) -> Bool {
        for scalar in 1 ... minimumGap {
            guard neighborhood.getElementForDirection(direction).translate(inDirection: direction, byAmount: scalar).points.allSatisfy({ blockAt(point: $0)?.type == .Uninitialized }) else {
                return false
            }
        }
        return true
    }

    private func excavateNeighborhood(_ neighborhood: Neighborhood) {
        // Excavate the neighborhood.
        fill(in: neighborhood, withBlockType: .EmptyPassage)
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
                if newRoom.overlapsWithNeighborhood(room) {
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

    private static func getPixelForBlock(_ block: Block) -> PixelData {
        switch block.type {
        case .Uninitialized: return .Black
        case .EmptyRoom: return .White
        case .EmptyPassage: return .Red
        }
    }

    public func render() -> UIImage? {
        let pixels = self.flatMapBlocks(Dungeon.getPixelForBlock)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        guard let provider = CGDataProvider.init(data: NSData(bytes: pixels, length: pixels.count * PixelData.size)) else {
            print("Unable to initialize provider.")
            return nil
        }
        guard let cgImage = CGImage.init(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: width * PixelData.size, space: colorSpace, bitmapInfo: bitmapInfo, provider: provider, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent) else {
            print("Unable to build CGImage.")
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}
