//
//  RMEpisodeDetailViewViewModel.swift
//  RickAndMorty
//
//  Created by Sean Veal on 12/13/23.
//

import Foundation

protocol RMEpisodeDetailViewViewModelDelegate: AnyObject {
    func didFetchEpisodeDetails()
}

final class RMEpisodeDetailViewViewModel {
    private let endpointUrl: URL?
    private var dataTuple: (episode: RMEpisode, characters: [RMCharacter])? {
        didSet {
            createCellViewModels()
            delegate?.didFetchEpisodeDetails()
        }
    }
    
    enum SectionType {
        case information(viewModels: [RMEpisodeInfoCollectionViewCellViewModel])
        case characters(viewModel: [RMCharacterCollectionViewCellViewModel])
    }
    
    public weak var delegate: RMEpisodeDetailViewViewModelDelegate?
    
    public private(set) var cellViewModels: [SectionType] = []
    
    // MARK: - Init
    
    init(endpointUrl: URL?) {
        self.endpointUrl = endpointUrl
    }
    
    public func character(at index: Int) -> RMCharacter? {
        guard let dataTuple = dataTuple else { return nil }
        return dataTuple.characters[index]
    }
    
    /// Fetch episode model
    public func fetchEpisodeData() {
        guard let endpointUrl = endpointUrl,
            let request = RMRequest(url: endpointUrl) else { return }
        
        RMService.shared.execute(request, expecting: RMEpisode.self) { [weak self] result in
            switch result {
            case .success(let episode):
                self?.fetchRelatedCharacters(episode: episode)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func createCellViewModels() {
        guard let dataTuple = dataTuple else { return }
        let episode = dataTuple.episode
        let characters = dataTuple.characters
        
        var createdString = ""
        if let date = RMCharacterInfoCollectionViewCellViewModel.dateFormatter.date(from: episode.created) {
            createdString = RMCharacterInfoCollectionViewCellViewModel.shortDateFormatter.string(from: date)
        }
        
        cellViewModels = [
            .information(viewModels: [
                .init(title: "Episode Name", value: episode.name),
                .init(title: "Air Date", value: episode.air_date),
                .init(title: "Episode", value: episode.episode),
                .init(title: "Created", value: createdString),
            ]),
            .characters(viewModel: characters.compactMap({
                RMCharacterCollectionViewCellViewModel(characterName: $0.name, characterStatus: $0.status, characterImageUrl: URL(string: $0.image))
            }))
        ]
    }
    
    private func fetchRelatedCharacters(episode: RMEpisode) {
        let requests: [RMRequest] = episode.characters.compactMap {
            URL(string: $0)
        }.compactMap {
            RMRequest(url: $0)
        }
        
        // 10 or X amount of parallel requests
        // notified once all done
        
        let group = DispatchGroup()
        var characters: [RMCharacter] = []
        for request in requests {
            group.enter()
            RMService.shared.execute(request, expecting: RMCharacter.self) { result in
                defer { group.leave() }
                switch result {
                case .success(let character):
                    characters.append(character)
                case .failure:
                    break
                }
            }
        }
        
        group.notify(queue: .main) {
            self.dataTuple = (
                episode: episode,
                characters: characters
            )
        }
    }
}
