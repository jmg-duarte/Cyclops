//
//  Opened.swift
//  Cyclops
//
//  Created by José Duarte on 30/10/2023.
//

import Foundation
import SwiftData

@Model
final class Viewed: Identifiable {
    var id: Int
    
    init(_ id: Int) {
        self.id = id
    }
}
