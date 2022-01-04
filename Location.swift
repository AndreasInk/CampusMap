//
//  File.swift
//  My App
//
//  Created by Andreas Ink on 1/3/22.
//

import Foundation

struct Location: Codable {
    var id: String
    var long: Double
    var lat: Double
    var place: String
    var description: String
}
