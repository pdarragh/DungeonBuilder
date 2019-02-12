//
//  Block.swift
//  DungeonBuilder
//
//  Created by Pierce Darragh on 2/7/19.
//  Copyright © 2019 Pierce Corp. All rights reserved.
//

public enum BlockType {
    case Uninitialized
    case EmptyRoom
    case EmptyPassage

    public var traversable: Bool {
        switch self {
        case .Uninitialized: return false
        case .EmptyRoom: return true
        case .EmptyPassage: return true
        }
    }
}

public struct Block {
    let type: BlockType
    let point: Point

    public init(type: BlockType, x: Int, y: Int) {
        self.type = type
        self.point = Point(x, y)
    }
}
