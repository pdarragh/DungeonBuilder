//
//  Dungeon+Rendering.swift
//  DungeonBuilder
//
//  Created by Pierce Darragh on 2/15/19.
//  Copyright © 2019 Pierce Corp. All rights reserved.
//

extension Dungeon {
    func renderToGif(withDestination destination: URL) {
        UIImage.createAnimatedGif(from: images, savingTo: destination as CFURL)
    }
}
