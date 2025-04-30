//
//  Item.swift
//  Scout
//
//  Created by Andrew Martinez on 4/16/25.
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
