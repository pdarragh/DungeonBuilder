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
}


public class DungeonBitmapRenderer {
    public static func generateImageRepresentation(ofDungeon dungeon: Dungeon) -> UIImage? {
        let blackPixel = PixelData(a: 255, r: 0, g: 0, b: 0)
        let whitePixel = PixelData(a: 255, r: 255, g: 255, b: 255)
        let pixels = dungeon.flatMapBlocks { (block) -> PixelData in
            switch block {
            case is UninitializedBlock:
                return blackPixel
            case is EmptyBlock:
                return whitePixel
            default:
                fatalError("Unknown block type: \(block).")
            }
        }
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
}
