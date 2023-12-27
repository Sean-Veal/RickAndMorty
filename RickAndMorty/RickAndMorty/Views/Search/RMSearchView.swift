//
//  RMSearchView.swift
//  RickAndMorty
//
//  Created by Sean Veal on 12/20/23.
//

import UIKit

protocol RMSearchViewDelegate: AnyObject {
    func rmSearchView(_ searchView: RMSearchView, didSelectOption option: RMSearchInputViewViewModel.DynamicOption)
    
    func rmSearchView(_ searchView: RMSearchView, didSelectLocation location: RMLocation)
    func rmSearchView(_ searchView: RMSearchView, didSelectCharacter character: RMCharacter)
    func rmSearchView(_ searchView: RMSearchView, didSelectEpisode episode: RMEpisode)
}

final class RMSearchView: UIView {

    weak var delegate: RMSearchViewDelegate?
    
    private let viewModel: RMSearchViewViewModel
    
    private let searchInputView = RMSearchInputView()
    private let noResultsView = RMNoSearchResultsView()
    private let resultsView = RMSearchResultsView()
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init(frame: CGRect, viewModel: RMSearchViewViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(noResultsView, searchInputView, resultsView)
        addConstraints()
        
        searchInputView.configure(with: .init(type: viewModel.config.type))
        searchInputView.delegate = self
        
        resultsView.delegate = self
        
        setUpHandlers()
    }
    
    private func setUpHandlers() {
        viewModel.registerOptionChangeBlock { [weak self] tuple in
            self?.searchInputView.update(option: tuple.0, value: tuple.1)
        }
        
        viewModel.registerSearchResultHandler { [weak self] resultsVM in
            DispatchQueue.main.async {
                self?.resultsView.configure(with: resultsVM)
                self?.noResultsView.isHidden = true
                self?.resultsView.isHidden = false
            }
        }
        
        viewModel.registerNoResultsHandler { [weak self] in
            DispatchQueue.main.async {
                self?.noResultsView.isHidden = false
                self?.resultsView.isHidden = true
            }
        }
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            // Search Input View
            searchInputView.topAnchor.constraint(equalTo: topAnchor),
            searchInputView.leftAnchor.constraint(equalTo: leftAnchor),
            searchInputView.rightAnchor.constraint(equalTo: rightAnchor),
            searchInputView.heightAnchor.constraint(equalToConstant: viewModel.config.type == .episode ? 55 : 110),
            
            // Results View
            resultsView.topAnchor.constraint(equalTo: searchInputView.bottomAnchor),
            resultsView.leftAnchor.constraint(equalTo: leftAnchor),
            resultsView.rightAnchor.constraint(equalTo: rightAnchor),
            resultsView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // No Results
            noResultsView.widthAnchor.constraint(equalToConstant: 150),
            noResultsView.heightAnchor.constraint(equalToConstant: 150),
            noResultsView.centerXAnchor.constraint(equalTo: centerXAnchor),
            noResultsView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    public func presentKeyboard() {
        searchInputView.presentKeyboard()
    }

}

extension RMSearchView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension RMSearchView: RMSearchInputViewDelegate {
    func rmSearchInputView(_ inputView: RMSearchInputView, didSelectOption option: RMSearchInputViewViewModel.DynamicOption) {
        delegate?.rmSearchView(self, didSelectOption: option)
    }
    
    func rmSearchInputView(_ inputView: RMSearchInputView, didChangeSearchText text: String) {
        viewModel.set(query: text)
    }
    
    func rmSearchInputViewDidTapSearchKeyboardButton(_ inputView: RMSearchInputView) {
        viewModel.executeSearch()
    }
    
}

extension RMSearchView: RMSearchResultsViewDelegate {
    func rmSearchResultsView(_ resultsView: RMSearchResultsView, didSelectLocationAt index: Int) {
        guard let location = viewModel.locationSearchResult(at: index) else { return }
        self.delegate?.rmSearchView(self, didSelectLocation: location)
    }
    
    func rmSearchResultsView(_ resultsView: RMSearchResultsView, didSelectCharcaterAt index: Int) {
        guard let character = viewModel.characterSearchResult(at: index) else { return }
        self.delegate?.rmSearchView(self, didSelectCharacter: character)
    }
    
    func rmSearchResultsView(_ resultsView: RMSearchResultsView, didSelectEpisodeAt index: Int) {
        guard let episode = viewModel.episodeSearchResult(at: index) else { return }
        self.delegate?.rmSearchView(self, didSelectEpisode: episode)
    }
}
