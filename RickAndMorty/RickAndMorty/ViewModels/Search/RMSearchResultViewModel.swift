//
//  RMSearchResultViewModel.swift
//  RickAndMorty
//
//  Created by Sean Veal on 12/22/23.
//

import Foundation

enum RMSearchResultViewModel {
    case characters([RMCharacterCollectionViewCellViewModel])
    case episodes([RMCharacterEpisodeCollectionViewCellViewModel])
    case locations([RMLocationTableViewCellViewModel])
}
