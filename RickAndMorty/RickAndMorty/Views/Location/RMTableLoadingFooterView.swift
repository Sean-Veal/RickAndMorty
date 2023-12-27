//
//  RMTableLoadingFooterView.swift
//  RickAndMorty
//
//  Created by Sean Veal on 12/23/23.
//

import UIKit

final class RMTableLoadingFooterView: UIView {
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(spinner)
        spinner.startAnimating()
        addConstraints()
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            spinner.widthAnchor.constraint(equalToConstant: 55),
            spinner.heightAnchor.constraint(equalToConstant: 55),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            self.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            self.heightAnchor.constraint(equalToConstant: 100),
        ])
    }
}
