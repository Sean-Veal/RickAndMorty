//
//  RMSearchViewViewModel.swift
//  RickAndMorty
//
//  Created by Sean Veal on 12/20/23.
//

import Foundation

final class RMSearchViewViewModel {
    let config: RMSearchViewController.Config
    private var optionMap: [RMSearchInputViewViewModel.DynamicOption: String] = [:]
    private var searchText: String = ""
    
    private var optionMapUpdateBlock: (((RMSearchInputViewViewModel.DynamicOption, String)) -> Void)?
    
    private var searchResultsHandler: ((RMSearchResultViewModel) -> Void)?
    private var noResultsHandler: (() -> Void)?
    
    private var searchResultModel: Codable?
    
    init(config: RMSearchViewController.Config) {
        self.config = config
    }
    
    public func registerSearchResultHandler(_ block: @escaping (RMSearchResultViewModel)-> Void) {
        self.searchResultsHandler = block
    }
    
    public func registerNoResultsHandler(_ block: @escaping () -> Void) {
        self.noResultsHandler = block
    }
    
    public func executeSearch() {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        var queryParams: [URLQueryItem] = [URLQueryItem(name: "name", value: searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))]
        
        queryParams.append(contentsOf: optionMap.enumerated().compactMap({ _, element in
            let key: RMSearchInputViewViewModel.DynamicOption = element.key
            let value: String = element.value
            return URLQueryItem(name: key.queryArgument, value: value)
        }))
        
        let request = RMRequest(
            endpoint: config.type.endPoint,
            queryParameters: queryParams
        )
        
        switch config.type.endPoint {
        case .character:
            makeSearchAPICall(RMGetAllCharactersResponse.self, request: request)
        case .location:
            makeSearchAPICall(RMGetAllLocationsResponse.self, request: request)
        case .episode:
            makeSearchAPICall(RMGetAllEpisodesResponse.self, request: request)
        }
    }
    
    private func makeSearchAPICall<T: Codable>(_ type: T.Type, request: RMRequest) {
        RMService.shared.execute(request, expecting: type) { [weak self] result in
            switch result {
            case .success(let model):
                self?.processSearchResults(model)
            case .failure:
                self?.handleNoResults()
            }
        }
    }
    
    private func processSearchResults(_ model: Codable) {
        var resultsVM: RMSearchResultType?
        var nextUrl: String?
        if let characterResults = model as? RMGetAllCharactersResponse {
            resultsVM = .characters(characterResults.results.compactMap({
                RMCharacterCollectionViewCellViewModel(
                    characterName: $0.name,
                    characterStatus: $0.status,
                    characterImageUrl: URL(string: $0.image))
            }))
            nextUrl = characterResults.info.next
        }
        else if let episodeResults = model as? RMGetAllEpisodesResponse {
            resultsVM = .episodes(episodeResults.results.compactMap({
                RMCharacterEpisodeCollectionViewCellViewModel(episodeUrl: URL(string: $0.url))
            }))
            nextUrl = episodeResults.info.next
        }
        else if let locationResults = model as? RMGetAllLocationsResponse {
            resultsVM = .locations(locationResults.results.compactMap({
                RMLocationTableViewCellViewModel(location: $0)
            }))
            nextUrl = locationResults.info.next
        }
        
        if let resultsVM = resultsVM {
            self.searchResultModel = model
            let vm = RMSearchResultViewModel(results: resultsVM, next: nextUrl)
            self.searchResultsHandler?(vm)
        } else {
            handleNoResults()
        }
    }
    
    private func handleNoResults() {
        self.noResultsHandler?()
    }
    
    public func set(query text: String) {
        self.searchText = text
    }
    
    public func set(value: String, for option: RMSearchInputViewViewModel.DynamicOption) {
        self.optionMap[option] = value
        let tuple = (option, value)
        optionMapUpdateBlock?(tuple)
    }
    
    public func registerOptionChangeBlock(_ block: @escaping ((RMSearchInputViewViewModel.DynamicOption, String)) -> Void) {
        self.optionMapUpdateBlock = block
    }
    
    public func locationSearchResult(at index: Int) -> RMLocation? {
        guard let searchResultModel = searchResultModel as? RMGetAllLocationsResponse else { return nil }
        return searchResultModel.results[index]
    }
    
    public func characterSearchResult(at index: Int) -> RMCharacter? {
        guard let searchResultModel = searchResultModel as? RMGetAllCharactersResponse else { return nil }
        return searchResultModel.results[index]
    }
    
    public func episodeSearchResult(at index: Int) -> RMEpisode? {
        guard let searchResultModel = searchResultModel as? RMGetAllEpisodesResponse else { return nil }
        return searchResultModel.results[index]
    }
}
