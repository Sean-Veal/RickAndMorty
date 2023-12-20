//
//  RMLocationDetailViewController.swift
//  RickAndMorty
//
//  Created by Sean Veal on 12/20/23.
//

import UIKit

import UIKit

/// Detail about single location
final class RMLocationDetailViewController: UIViewController, RMLocationDetailViewViewModelDelegate, RMLocationDetailViewDelegate {

    private let viewModel: RMLocationDetailViewViewModel
    
    private let detailView = RMLocationDetailView()
    
    // MARK: - Init
    
    init(location: RMLocation) {
        self.viewModel = RMLocationDetailViewViewModel(endpointUrl: URL(string: location.url))
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(detailView)
        addConstraints()
        title = "Location"
        detailView.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShare))
        
        viewModel.delegate = self
        viewModel.fetchLocationData()
    }
    
    @objc
    private func didTapShare() {
        
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            detailView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            detailView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            detailView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            detailView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    // MARK: - View Delegate
    
    func didFetchLocationDetails() {
        detailView.configure(with: viewModel)
    }
    
    // MARK: - ViewModel Delegate
    
    func rmLocationDetailView(_ detailView: RMLocationDetailView, didSelectCharacter character: RMCharacter) {
        let viewModel = RMCharacterDetailViewViewModel(character: character)
        let vc = RMCharacterDetailViewController(viewModel: viewModel)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }

}
