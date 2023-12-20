//
//  RMSettingsCellViewModel.swift
//  RickAndMorty
//
//  Created by Sean Veal on 12/13/23.
//

import UIKit

struct RMSettingsCellViewModel: Identifiable {
    let id = UUID()
    
    let type: RMSettingsOption
    public let onTapHandler: (RMSettingsOption) -> Void
    
    init(type: RMSettingsOption, onTapHandler: @escaping (RMSettingsOption) -> Void) {
        self.type = type
        self.onTapHandler = onTapHandler
    }
    
    public var image: UIImage? {
        type.iconImage
    }
    public var title: String {
        type.displayTitle
    }
    
    public var iconContainerColor: UIColor {
        type.iconContainerColor
    }
}
