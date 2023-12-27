//
//  RMLocationViewViewModel.swift
//  RickAndMorty
//
//  Created by Sean Veal on 12/20/23.
//

import Foundation

protocol RMLocationViewViewModelDelegate: AnyObject {
    func didFetchInitialLocations()
}

final class RMLocationViewViewModel {
    
    weak var delegate: RMLocationViewViewModelDelegate?
    
    private var locations: [RMLocation] = [] {
        didSet {
            for location in locations {
                let cellViewModel = RMLocationTableViewCellViewModel(location: location)
                if !cellViewModels.contains(where: { model in
                    model == cellViewModel
                }) {
                    cellViewModels.append(cellViewModel)
                }
            }
        }
    }
    
    private var didFinishPagination: (() -> Void)?
    
    public func registerDidFinishPaginationBlock(_ block: @escaping () -> Void) {
        self.didFinishPagination = block
    }
    
    // Location response info
    //Will contain next url if present
    private var apiInfo: RMGetAllLocationsResponse.Info?
    
    public var shouldShowLoadMoreIndicator: Bool {
        apiInfo?.next != nil
    }
    
    public var isLoadingMoreLocations: Bool = false
    
    public private(set) var cellViewModels: [RMLocationTableViewCellViewModel] = []
    
    init() {}
    
    public func location(at index: Int) -> RMLocation? {
        guard index < locations.count, index >= 0 else { return nil }
        return self.locations[index]
    }
    
    public func fetchLocations() {
        RMService.shared.execute(.listLocationsRequest, expecting: RMGetAllLocationsResponse.self) { [weak self] result in
            switch result {
            case .success(let model):
                self?.apiInfo = model.info
                self?.locations = model.results
                DispatchQueue.main.async {
                    self?.delegate?.didFetchInitialLocations()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    /// Paginate if additional locations are needed
    public func fetchAdditionalLocations() {
        // Fetch additional characters
        guard !isLoadingMoreLocations else { return }
        
        isLoadingMoreLocations = true
        guard let urlString = apiInfo?.next,
              let url = URL(string: urlString),
            let request = RMRequest(url: url) else {
            isLoadingMoreLocations = false
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
                strongSelf.apiInfo = info
                
//                let originalCount = strongSelf.locations.count
//                let newCount = moreResults.count
//                let total = originalCount + newCount
//                let startingIndex = total - newCount
//                let indexPathsToAdd: [IndexPath] = Array(startingIndex..<(startingIndex+newCount)).compactMap {
//                    return IndexPath(row: $0, section: 0)
//                }
                strongSelf.locations.append(contentsOf: moreResults)
                strongSelf.cellViewModels.append(contentsOf: moreResults.compactMap({
                    RMLocationTableViewCellViewModel(location: $0)
                }))
                
                DispatchQueue.main.async {
//                    strongSelf.delegate?.didLoadMoreLocations(with: indexPathsToAdd)
                    strongSelf.isLoadingMoreLocations = false
                    strongSelf.didFinishPagination?()
                }
            case .failure(let failure):
                print("FALED: \(failure)")
                strongSelf.isLoadingMoreLocations = false
            }
        }
    }
    
    private var hasMoreResults: Bool {
        return false
    }
}
