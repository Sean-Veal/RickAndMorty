//
//  RMLocationTableViewCellViewModel.swift
//  RickAndMorty
//
//  Created by Sean Veal on 12/20/23.
//

import Foundation

struct RMLocationTableViewCellViewModel: Hashable, Equatable {
    
    private let location: RMLocation
    
    init(location: RMLocation) {
        self.location = location
    }
    
    public var name: String {
        location.name
    }
    
    public var type: String {
        "Type: \(location.type)"
    }
    
    public var dimension: String {
        location.dimension
    }
    
    static func == (lhs: RMLocationTableViewCellViewModel, rhs: RMLocationTableViewCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(type)
        hasher.combine(dimension)
        hasher.combine(location.id)
    }
}
