//
//  RMLocation.swift
//  RickAndMorty
//
//  Created by Sean Veal on 12/5/23.
//

import Foundation

struct RMLocation: Codable {
    let id: Int
    let name: String
    let type: String
    let dimension: String
    let residents: [String]
    let url: String
    let created: String
}
