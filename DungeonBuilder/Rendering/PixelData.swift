//
//  PixelData.swift
//  DungeonBuilder
//
//  Created by Pierce Darragh on 2/12/19.
//  Copyright © 2019 Pierce Corp. All rights reserved.
//

struct PixelData {
    var a: UInt8
    var r: UInt8
    var g: UInt8
    var b: UInt8

    static let size = MemoryLayout<PixelData>.size

    static let Black = PixelData(a: 255, r: 0, g: 0, b: 0)
    static let Gray = PixelData(a: 255, r: 122, g: 122, b: 122)
    static let White = PixelData(a: 255, r: 255, g: 255, b: 255)
    static let Red = PixelData(a: 255, r: 255, g: 0, b: 0)
}
