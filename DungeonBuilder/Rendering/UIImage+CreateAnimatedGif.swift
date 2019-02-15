//
//  UIImage+CreateAnimatedGif.swift
//  DungeonBuilder
//
//  Created by Pierce Darragh on 2/15/19.
//  Copyright © 2019 Pierce Corp. All rights reserved.
//

import CoreServices
import ImageIO

extension UIImage {
    static func createAnimatedGif(from images: [UIImage], savingTo url: CFURL) {
        let fileProperties: CFDictionary = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]]  as CFDictionary
        let frameProperties: CFDictionary = [kCGImagePropertyGIFDictionary as String: [(kCGImagePropertyGIFDelayTime as String): 0.05]] as CFDictionary

        if let destination = CGImageDestinationCreateWithURL(url, kUTTypeGIF, images.count, nil) {
            CGImageDestinationSetProperties(destination, fileProperties)
            for image in images {
                if let cgImage = image.cgImage {
                    CGImageDestinationAddImage(destination, cgImage, frameProperties)
                }
            }
            if !CGImageDestinationFinalize(destination) {
                print("Failed to finalize the image destination")
            }
        }
    }
}
