//
//  RMEpisodeDetailViewController.swift
//  RickAndMorty
//
//  Created by Sean Veal on 12/12/23.
//

import UIKit

/// Detail about single episode
final class RMEpisodeDetailViewController: UIViewController {

    private let url: URL?
    
    // MARK: - Init
    
    init(url: URL?) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Episode"
        view.backgroundColor = .systemGreen
    }

}
