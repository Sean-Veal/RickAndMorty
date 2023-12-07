//
//  RMCharacterStatus.swift
//  RickAndMorty
//
//  Created by Sean Veal on 12/5/23.
//

import Foundation

enum RMCharacterStatus: String, Codable {
    case alive = "Alive"
    case dead = "Dead"
    case `unknown` = "unknown"
}