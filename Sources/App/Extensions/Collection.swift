//
//  File.swift
//  
//
//  Created by Maxime De Greve on 23/07/2021.
//

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
