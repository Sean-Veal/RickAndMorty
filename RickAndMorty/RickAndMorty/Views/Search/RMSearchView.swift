//
//  RMSearchView.swift
//  RickAndMorty
//
//  Created by Sean Veal on 12/20/23.
//

import UIKit

class RMSearchView: UIView {

    private let viewModel: RMSearchViewViewModel
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init(frame: CGRect, viewModel: RMSearchViewViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        backgroundColor = .blue
        translatesAutoresizingMaskIntoConstraints = false
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