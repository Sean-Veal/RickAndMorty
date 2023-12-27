//
//  Extensions.swift
//  RickAndMorty
//
//  Created by Sean Veal on 12/8/23.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach {
            addSubview($0)
        }
    }
}

extension UIDevice {
    static let isIphone = UIDevice.current.userInterfaceIdiom == .phone
}
