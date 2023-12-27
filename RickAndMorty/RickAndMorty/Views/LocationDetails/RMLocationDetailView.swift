//
//  RMLocationDetailView.swift
//  RickAndMorty
//
//  Created by Sean Veal on 12/20/23.
//

import UIKit

protocol RMLocationDetailViewDelegate: AnyObject {
    func rmLocationDetailView(_ detailView: RMLocationDetailView,
                             didSelectCharacter character: RMCharacter
    )
}

final class RMLocationDetailView: UIView {

    public weak var delegate: RMLocationDetailViewDelegate?
    
    private var viewModel: RMLocationDetailViewViewModel? {
        didSet {
            spinner.stopAnimating()
            self.collectionView?.isHidden = false
            self.collectionView?.reloadData()
            UIView.animate(withDuration: 0.3) {
                self.collectionView?.alpha = 1
            }
            
        }
    }
    
    private var collectionView: UICollectionView?
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        let collectionView = createCollectionView()
        addSubviews(collectionView, spinner)
        self.collectionView = collectionView
        
        addConstraints()
        
        spinner.startAnimating()
    }
    
    private func addConstraints() {
        guard let collectionView = collectionView else { return }
        NSLayoutConstraint.activate([
            spinner.heightAnchor.constraint(equalToConstant: 100),
            spinner.widthAnchor.constraint(equalToConstant: 100),
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewCompositionalLayout { section, _ in
            return self.layout(for: section)
        }
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isHidden = true
        collectionView.alpha = 0
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(RMEpisodeInfoCollectionViewCell.self, forCellWithReuseIdentifier: RMEpisodeInfoCollectionViewCell.cellIdentifier)
        collectionView.register(RMCharacterCollectionViewCell.self, forCellWithReuseIdentifier: RMCharacterCollectionViewCell.cellIdentifier)
        
        return collectionView
    }
    
    // MARK: - Public
    
    public func configure(with viewModel: RMLocationDetailViewViewModel) {
        self.viewModel = viewModel
    }

}

extension RMLocationDetailView: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel?.cellViewModels.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionTypes = viewModel?.cellViewModels else { return 0 }
        switch sectionTypes[section] {
        case .information(let viewModels):
            return viewModels.count
        case .characters(let viewModels):
            return viewModels.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionTypes = viewModel?.cellViewModels else { fatalError("No ViewModel") }
        switch sectionTypes[indexPath.section] {
        case .information(let viewModels):
            let viewModel = viewModels[indexPath.row]
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RMEpisodeInfoCollectionViewCell.cellIdentifier, for: indexPath) as? RMEpisodeInfoCollectionViewCell else { fatalError("Unsupported") }
            cell.configure(with: viewModel)
            
            return cell
            
        case .characters(let viewModels):
            let viewModel = viewModels[indexPath.row]
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RMCharacterCollectionViewCell.cellIdentifier, for: indexPath) as? RMCharacterCollectionViewCell else { fatalError("Unsupported") }
            cell.configure(with: viewModel)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let viewModel = viewModel else { fatalError() }
        let sectionTypes = viewModel.cellViewModels
        let sectionType = sectionTypes[indexPath.section]
        
        switch sectionType {
        case .information:
            break
        case .characters:
            guard let character = viewModel.character(at: indexPath.row)
            else { return }
            delegate?.rmLocationDetailView(self, didSelectCharacter: character)
            
            
        }
    }
}

extension RMLocationDetailView {
    private func layout(for section: Int) -> NSCollectionLayoutSection {
        guard let sections = viewModel?.cellViewModels else { return createInfoLayout() }
        
        switch sections[section] {
        case .information:
            return createInfoLayout()
        case .characters:
            return createCharacterLayout()
        }
    }
    
    private func createInfoLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80)), subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    private func createCharacterLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(
            widthDimension: .fractionalWidth(UIDevice.isIphone ? 0.5 : 0.25),
            heightDimension: .fractionalHeight(1)))
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(UIDevice.isIphone ? 260 : 320)),
            subitems: UIDevice.isIphone ? [item, item] : [item, item, item, item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
}

