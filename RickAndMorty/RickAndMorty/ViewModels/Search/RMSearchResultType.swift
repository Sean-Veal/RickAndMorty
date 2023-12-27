//
//  RMSearchResultType.swift
//  RickAndMorty
//
//  Created by Sean Veal on 12/22/23.
//

import Foundation

final class RMSearchResultViewModel {
    public private(set) var results: RMSearchResultType
    private var next: String? = nil
    
    init(results: RMSearchResultType, next: String? = nil) {
        self.results = results
        self.next = next
    }
    
    public private(set) var isLoadingMoreResults = false
    
    public var shouldShowLoadMoreIndicator: Bool {
        next != nil
    }
    
    public func fetchAdditionalResults(completion: @escaping ([any Hashable]) -> Void) {
        // Fetch additional characters
        guard !isLoadingMoreResults else { return }
        
        isLoadingMoreResults = true
        guard let urlString = next,
              let url = URL(string: urlString),
              let request = RMRequest(url: url) else {
            isLoadingMoreResults = false
            print("Failed to create request")
            return
        }
        
        switch self.results {
        case .characters(let exisitingResults):
            RMService.shared.execute(request,
                                     expecting: RMGetAllCharactersResponse.self) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let responseModel):
                    let moreResults = responseModel.results
                    let info = responseModel.info
                    strongSelf.next = info.next
                    let additionalCharacters = moreResults.compactMap({
                        RMCharacterCollectionViewCellViewModel(characterName: $0.name, characterStatus: $0.status, characterImageUrl: URL(string: $0.image))
                    })
                    var newResults: [RMCharacterCollectionViewCellViewModel] = []
                    newResults = exisitingResults + additionalCharacters
                    
                    DispatchQueue.main.async {
                        strongSelf.isLoadingMoreResults = false
                        completion(newResults)
                    }
                case .failure(let failure):
                    print("FALED: \(failure)")
                    strongSelf.isLoadingMoreResults = false
                }
            }
        case .episodes(let exisitingResults):
            RMService.shared.execute(request,
                                     expecting: RMGetAllEpisodesResponse.self) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let responseModel):
                    let moreResults = responseModel.results
                    let info = responseModel.info
                    strongSelf.next = info.next
                    let additionalEpisodes = moreResults.compactMap({
                        RMCharacterEpisodeCollectionViewCellViewModel(episodeUrl: URL(string: $0.url))
                    })
                    var newResults: [RMCharacterEpisodeCollectionViewCellViewModel] = []
                    newResults = exisitingResults + additionalEpisodes
                    
                    DispatchQueue.main.async {
                        strongSelf.isLoadingMoreResults = false
                        completion(newResults)
                    }
                case .failure(let failure):
                    print("FALED: \(failure)")
                    strongSelf.isLoadingMoreResults = false
                }
            }
        default:
            break
        }
    }
    
    public func fetchAdditionalLocations(completion: @escaping ([RMLocationTableViewCellViewModel]) -> Void) {
        // Fetch additional characters
        guard !isLoadingMoreResults else { return }
        
        isLoadingMoreResults = true
        guard let urlString = next,
              let url = URL(string: urlString),
              let request = RMRequest(url: url) else {
            isLoadingMoreResults = false
            print("Failed to create request")
            return
        }
        
        RMService.shared.execute(request,
                                 expecting: RMGetAllLocationsResponse.self) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let responseModel):
                let moreResults = responseModel.results
                let info = responseModel.info
                strongSelf.next = info.next
                
                //                let originalCount = strongSelf.locations.count
                //                let newCount = moreResults.count
                //                let total = originalCount + newCount
                //                let startingIndex = total - newCount
                //                let indexPathsToAdd: [IndexPath] = Array(startingIndex..<(startingIndex+newCount)).compactMap {
                //                    return IndexPath(row: $0, section: 0)
                //                }
                //                strongSelf.results.append(contentsOf: moreResults)
                let additionalLocations = moreResults.compactMap({
                    RMLocationTableViewCellViewModel(location: $0)
                })
                var newResults: [RMLocationTableViewCellViewModel] = []
                switch strongSelf.results {
                case .locations(let exisitingResults):
                    newResults = exisitingResults + additionalLocations
                default:
                    break
                }
                
                DispatchQueue.main.async {
                    strongSelf.isLoadingMoreResults = false
                    completion(newResults)
                }
            case .failure(let failure):
                print("FALED: \(failure)")
                strongSelf.isLoadingMoreResults = false
            }
        }
    }
}

enum RMSearchResultType {
    case characters([RMCharacterCollectionViewCellViewModel])
    case episodes([RMCharacterEpisodeCollectionViewCellViewModel])
    case locations([RMLocationTableViewCellViewModel])
}
