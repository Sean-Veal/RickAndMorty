//
//  RMSearchResultsView.swift
//  RickAndMorty
//
//  Created by Sean Veal on 12/23/23.
//

import UIKit

protocol RMSearchResultsViewDelegate: AnyObject {
    func rmSearchResultsView(_ resultsView: RMSearchResultsView, didSelectLocationAt index: Int)
    func rmSearchResultsView(_ resultsView: RMSearchResultsView, didSelectCharcaterAt index: Int)
    func rmSearchResultsView(_ resultsView: RMSearchResultsView, didSelectEpisodeAt index: Int)
}

/// Shows search results UI (table or collection as need)
final class RMSearchResultsView: UIView {

    weak var delegate: RMSearchResultsViewDelegate?
    
    private var viewModel: RMSearchResultViewModel? {
        didSet {
            self.processViewModel()
        }
    }
    
    private var locationCellViewModels: [RMLocationTableViewCellViewModel] = []
    private var collectionViewCellViewModels: [any Hashable] = []
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(RMLocationTableViewCell.self, forCellReuseIdentifier: RMLocationTableViewCell.cellIdentifier)
        return table
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isHidden = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(RMCharacterCollectionViewCell.self, forCellWithReuseIdentifier: RMCharacterCollectionViewCell.cellIdentifier)
        collectionView.register(RMCharacterEpisodeCollectionViewCell.self, forCellWithReuseIdentifier: RMCharacterEpisodeCollectionViewCell.cellIdentifier)
        collectionView.register(
            RMFooterLoadingCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: RMFooterLoadingCollectionReusableView.identifier)
        return collectionView
    }()
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(tableView, collectionView)
        addConstraints()
    }
    
    private func processViewModel() {
        guard let viewModel = viewModel else { return }
        
        switch viewModel.results {
        case .characters(let viewModels):
            self.collectionViewCellViewModels = viewModels
            setUpCollectionView()
        case .episodes(let viewModels):
            self.collectionViewCellViewModels = viewModels
            setUpCollectionView()
        case .locations(let viewModels):
            setUpTableView(viewModels)
        }
    }
    
    private func setUpTableView(_ viewModels: [RMLocationTableViewCellViewModel]) {
        tableView.isHidden = false
        tableView.delegate = self
        tableView.dataSource = self
        self.locationCellViewModels = viewModels
        tableView.reloadData()
    }
    
    private func setUpCollectionView() {
        tableView.isHidden = true
        collectionView.isHidden = false
        collectionView.reloadData()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.rightAnchor.constraint(equalTo: rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    public func configure(with viewModel: RMSearchResultViewModel) {
        self.viewModel = viewModel
    }

}

extension RMSearchResultsView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewCellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Character
        let currentViewModel = collectionViewCellViewModels[indexPath.row]
        
        if let characterVM = currentViewModel as? RMCharacterCollectionViewCellViewModel {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RMCharacterCollectionViewCell.cellIdentifier, for: indexPath) as? RMCharacterCollectionViewCell else { fatalError() }
                cell.configure(with: characterVM)
            return cell
        }
        
        // Episode
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RMCharacterEpisodeCollectionViewCell.cellIdentifier, for: indexPath) as? RMCharacterEpisodeCollectionViewCell else { fatalError() }
        if let episodeVM = currentViewModel as? RMCharacterEpisodeCollectionViewCellViewModel {
            cell.configure(with: episodeVM)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let viewModel = viewModel else { return }
        switch viewModel.results {
        case .characters:
            delegate?.rmSearchResultsView(self, didSelectCharcaterAt: indexPath.row)
        case .episodes:
            delegate?.rmSearchResultsView(self, didSelectEpisodeAt: indexPath.row)
        default: break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let currentViewModel = collectionViewCellViewModels[indexPath.row]
        
        if currentViewModel is RMCharacterCollectionViewCellViewModel {
            let bounds = UIScreen.main.bounds.width
            let width = UIDevice.isIphone ? (bounds-30)/2 : (bounds-50)/4
            return CGSize(width: width, height: width*1.5)
        }
        
        let bounds = collectionView.bounds
        let width = UIDevice.isIphone ? (bounds.width - 20) : (bounds.width - 60) / 4
        return CGSize(width: width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter,
              let viewModel = viewModel,
                viewModel.shouldShowLoadMoreIndicator,
              let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: RMFooterLoadingCollectionReusableView.identifier,
                for: indexPath) as? RMFooterLoadingCollectionReusableView
        else {
            fatalError("Unsupported")
        }
        
        footer.startAnimating()
        
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let viewModel = viewModel,
              viewModel.shouldShowLoadMoreIndicator else { return .zero }
        return CGSize(width: collectionView.frame.width, height: 100)
    }
}

extension RMSearchResultsView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.locationCellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = self.locationCellViewModels[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RMLocationTableViewCell.cellIdentifier, for: indexPath) as? RMLocationTableViewCell else { fatalError() }
        cell.configure(with: viewModel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.delegate?.rmSearchResultsView(self, didSelectLocationAt: indexPath.row)
    }
}

extension RMSearchResultsView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !locationCellViewModels.isEmpty {
            handlePagination(scrollView)
        } else {
            handleCollectionPagination(scrollView)
        }
    }
    
    private func handleCollectionPagination(_ scrollView: UIScrollView) {
        guard let viewModel = viewModel,
              !collectionViewCellViewModels.isEmpty,
              viewModel.shouldShowLoadMoreIndicator,
              !viewModel.isLoadingMoreResults
               else { return }
//        DispatchQueue.main.async {
//            self.showLoadingIndicator()
//        }

        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] timer in
            let offset = scrollView.contentOffset.y
            let totalContentHeight = scrollView.contentSize.height
            let totalScrollViewFixedHeight = scrollView.frame.size.height

            // Had to add the totalContentHeight check because on app start fetchAdditionalCharacters() fires
            if totalContentHeight > 0 {
                if offset >= (totalContentHeight - totalScrollViewFixedHeight - 120) {
                    self?.viewModel?.fetchAdditionalResults { [weak self] newResults in
                        guard let strongSelf = self else { return }
                            
                        DispatchQueue.main.async {
                            let originalCount = strongSelf.collectionViewCellViewModels.count
                            let newCount = (newResults.count - originalCount)
                            let total = originalCount + newCount
                            let startingIndex = total - newCount
                            let indexPathsToAdd: [IndexPath] = Array(startingIndex..<(startingIndex+newCount)).compactMap {
                                return IndexPath(row: $0, section: 0)
                            }
                        
                        strongSelf.collectionViewCellViewModels = newResults
                            strongSelf.collectionView.insertItems(at: indexPathsToAdd)
                        }
                    }
                }
            }
            timer.invalidate()
        }
    }
    
    private func handlePagination(_ scrollView: UIScrollView) {
        guard let viewModel = viewModel,
              !locationCellViewModels.isEmpty,
              viewModel.shouldShowLoadMoreIndicator,
              !viewModel.isLoadingMoreResults
               else { return }
        DispatchQueue.main.async {
            self.showTableLoadingIndicator()
        }

        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] timer in
            let offset = scrollView.contentOffset.y
            let totalContentHeight = scrollView.contentSize.height
            let totalScrollViewFixedHeight = scrollView.frame.size.height

            // Had to add the totalContentHeight check because on app start fetchAdditionalCharacters() fires
            if totalContentHeight > 0 {
                if offset >= (totalContentHeight - totalScrollViewFixedHeight - 120) {
                    self?.viewModel?.fetchAdditionalLocations { [weak self] newResults in
                        DispatchQueue.main.async {
                            self?.tableView.tableFooterView = nil
                            self?.locationCellViewModels = newResults
                            self?.tableView.reloadData()
                        }
                    }
                }
            }
            timer.invalidate()
        }
    }
    
    private func showTableLoadingIndicator() {
        tableView.tableFooterView = RMTableLoadingFooterView(frame: .init(x: 0, y: 0, width: frame.size.width, height: 100))
    }
}
