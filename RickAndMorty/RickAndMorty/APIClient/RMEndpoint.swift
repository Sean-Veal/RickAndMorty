//
//  RMEndpoint.swift
//  RickAndMorty
//
//  Created by Sean Veal on 12/5/23.
//

import Foundation

/// Represents unique API Endpoint
@frozen enum RMEndpoint: String, CaseIterable, Hashable {
    case character
    case location
    case episode
}
