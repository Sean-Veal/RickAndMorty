//
//  RMEpisodeDetailViewController.swift
//  RickAndMorty
//
//  Created by Sean Veal on 12/12/23.
//

import UIKit

/// Detail about single episode
final class RMEpisodeDetailViewController: UIViewController, RMEpisodeDetailViewViewModelDelegate, RMEpisodeDetailViewDelegate {

    private let viewModel: RMEpisodeDetailViewViewModel
    
    private let detailView = RMEpisodeDetailView()
    
    // MARK: - Init
    
    init(url: URL?) {
        self.viewModel = RMEpisodeDetailViewViewModel(endpointUrl: url)
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
        title = "Episode"
        detailView.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShare))
        
        viewModel.delegate = self
        viewModel.fetchEpisodeData()
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
    
    func didFetchEpisodeDetails() {
        detailView.configure(with: viewModel)
    }
    
    // MARK: - ViewModel Delegate
    
    func rmEpisodeDetailView(_ detailView: RMEpisodeDetailView, didSelectCharacter character: RMCharacter) {
        let viewModel = RMCharacterDetailViewViewModel(character: character)
        let vc = RMCharacterDetailViewController(viewModel: viewModel)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }

}
