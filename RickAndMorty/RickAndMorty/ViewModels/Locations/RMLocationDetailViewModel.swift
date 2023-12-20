//
//  RMLocationDetailViewModel.swift
//  RickAndMorty
//
//  Created by Sean Veal on 12/20/23.
//

import Foundation

protocol RMLocationDetailViewViewModelDelegate: AnyObject {
    func didFetchLocationDetails()
}

final class RMLocationDetailViewViewModel {
    private let endpointUrl: URL?
    private var dataTuple: (location: RMLocation, characters: [RMCharacter])? {
        didSet {
            createCellViewModels()
            delegate?.didFetchLocationDetails()
        }
    }
    
    enum SectionType {
        case information(viewModels: [RMEpisodeInfoCollectionViewCellViewModel])
        case characters(viewModel: [RMCharacterCollectionViewCellViewModel])
    }
    
    public weak var delegate: RMLocationDetailViewViewModelDelegate?
    
    public private(set) var cellViewModels: [SectionType] = []
    
    // MARK: - Init
    
    init(endpointUrl: URL?) {
        self.endpointUrl = endpointUrl
    }
    
    public func character(at index: Int) -> RMCharacter? {
        guard let dataTuple = dataTuple else { return nil }
        return dataTuple.characters[index]
    }
    
    /// Fetch location model
    public func fetchLocationData() {
        guard let endpointUrl = endpointUrl,
            let request = RMRequest(url: endpointUrl) else { return }
        
        RMService.shared.execute(request, expecting: RMLocation.self) { [weak self] result in
            switch result {
            case .success(let location):
                self?.fetchRelatedCharacters(location: location)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func createCellViewModels() {
        guard let dataTuple = dataTuple else { return }
        let location = dataTuple.location
        let characters = dataTuple.characters
        
        var createdString = location.created
        if let date = RMCharacterInfoCollectionViewCellViewModel.dateFormatter.date(from: location.created) {
            createdString = RMCharacterInfoCollectionViewCellViewModel.shortDateFormatter.string(from: date)
        }
        
        cellViewModels = [
            .information(viewModels: [
                .init(title: "Location Name", value: location.name),
                .init(title: "Type", value: location.type),
                .init(title: "Dimenstion", value: location.dimension),
                .init(title: "Created", value: createdString),
            ]),
            .characters(viewModel: characters.compactMap({
                RMCharacterCollectionViewCellViewModel(characterName: $0.name, characterStatus: $0.status, characterImageUrl: URL(string: $0.image))
            }))
        ]
    }
    
    private func fetchRelatedCharacters(location: RMLocation) {
        let requests: [RMRequest] = location.residents.compactMap {
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
                location: location,
                characters: characters
            )
        }
    }
}

