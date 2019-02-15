//
//  RenderableDungeon.swift
//  DungeonBuilder
//
//  Created by Pierce Darragh on 2/15/19.
//  Copyright © 2019 Pierce Corp. All rights reserved.
//

public class RenderableDungeon: Dungeon {
    public var images: [UIImage] = []

    override func excavatePassages() {
        render()
        super.excavatePassages()
    }

    override func excavateNeighborhood(_ neighborhood: Neighborhood, withBlockType blockType: BlockType) {
        super.excavateNeighborhood(neighborhood, withBlockType: blockType)
        render()
    }

    func render() {
        let pixels = self.flatMapBlocks(RenderableDungeon.getPixelForBlock)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        guard let provider = CGDataProvider.init(data: NSData(bytes: pixels, length: pixels.count * PixelData.size)) else {
            print("Unable to initialize provider.")
            return
        }
        guard let cgImage = CGImage.init(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: width * PixelData.size, space: colorSpace, bitmapInfo: bitmapInfo, provider: provider, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent) else {
            print("Unable to build CGImage.")
            return
        }
        images.append(UIImage(cgImage: cgImage))
    }

    public func renderToGif(withDestination destination: URL) {
        UIImage.createAnimatedGif(from: images, savingTo: destination as CFURL)
    }

    public func renderCurrentStateToImage(withDestination destination: URL) {
        if let image = images.last, let data = UIImage.pngData(image)() {
            do {
                try data.write(to: destination)
            } catch {
                print("Unable to write image to file: \(destination)")
            }
        }
    }

    static func getPixelForBlock(_ block: Block) -> PixelData {
        switch block.type {
        case .Uninitialized: return .Black
        case .EmptyRoom: return .White
        case .EmptyPassage: return .Red
        }
    }
}
