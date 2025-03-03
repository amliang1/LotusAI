//
//  Item.swift
//  LotusAI
//
//  Created by Alan Liang on 3/2/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
