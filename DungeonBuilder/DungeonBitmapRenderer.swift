//
//  DungeonBitmapRenderer.swift
//  DungeonBuilder
//
//  Created by Pierce Darragh on 2/12/19.
//  Copyright © 2019 Pierce Corp. All rights reserved.
//

private struct PixelData {
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

public class DungeonBitmapRenderer {
    public static func generateImageRepresentation(ofDungeon dungeon: Dungeon) -> UIImage? {
        let pixels = dungeon.flatMapBlocks(getPixelForBlock)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        guard let provider = CGDataProvider.init(data: NSData(bytes: pixels, length: pixels.count * PixelData.size)) else {
            print("Unable to initialize provider.")
            return nil
        }
        guard let cgImage = CGImage.init(width: dungeon.width, height: dungeon.height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: dungeon.width * PixelData.size, space: colorSpace, bitmapInfo: bitmapInfo, provider: provider, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent) else {
            print("Unable to build CGImage.")
            return nil
        }
        return UIImage(cgImage: cgImage)
    }

    private static func getPixelForBlock(_ block: Block) -> PixelData {
        switch block.type {
        case .Uninitialized:
            return .Black
        case .EmptyRoom:
            return .White
        case .EmptyPassage:
            return .Red
        }
    }
}
