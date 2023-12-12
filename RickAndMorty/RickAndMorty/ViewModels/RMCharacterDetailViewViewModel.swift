//
//  RMCharacterDetailViewViewModel.swift
//  RickAndMorty
//
//  Created by Sean Veal on 12/9/23.
//

import Foundation

final class RMCharacterDetailViewViewModel {
    private let character: RMCharacter
    
    enum SectionType: CaseIterable {
        case photo
        case information
        case episodes
    }
    
    public let sections = SectionType.allCases
    
    // MARK: - Init
    
    init(character: RMCharacter) {
        self.character = character
    }
    
    private var requestUrl: URL? {
        URL(string: character.type)
    }
    
    public var title: String {
        character.name.uppercased()
    }
}
