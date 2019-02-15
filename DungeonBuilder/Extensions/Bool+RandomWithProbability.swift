//
//  Bool+RandomWithProbability.swift
//  DungeonBuilder
//
//  Created by Pierce Darragh on 2/15/19.
//  Copyright © 2019 Pierce Corp. All rights reserved.
//

extension Bool {
    /// Returns a random Boolean value, where the likelihood of returning `true` is the given probability.
    static func random(withProbability probability: Double) -> Bool {
        // Using an exclusive upper bound with a strict less-than ensures that a given probability of 1 will always produce `true`.
        return Double.random(in: 0 ..< 1) < probability
    }
}
