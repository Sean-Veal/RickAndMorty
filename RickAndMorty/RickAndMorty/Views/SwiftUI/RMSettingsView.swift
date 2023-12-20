//
//  RMSettingsView.swift
//  RickAndMorty
//
//  Created by Sean Veal on 12/13/23.
//

import SwiftUI

struct RMSettingsView: View {
    
    let viewModel: RMSettingsViewViewModel
    
    init(viewModel: RMSettingsViewViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        List(viewModel.cellViewModels) { viewModel in
            HStack {
                if let image = viewModel.image {
                    Image(uiImage: image)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.white)
                        .frame(width: 20, height: 20)
                        .padding(8)
                        .background {
                            Color(uiColor: viewModel.iconContainerColor)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                Text(viewModel.title)
                    .padding(.leading, 10)
                Spacer()
            }
            .padding(.bottom, 3)
            .onTapGesture {
                viewModel.onTapHandler(viewModel.type)
            }
        }
    }
}

#Preview {
    RMSettingsView(viewModel: RMSettingsViewViewModel(cellViewModels: RMSettingsOption.allCases.compactMap({
        RMSettingsCellViewModel(type: $0) { option in
        }
    })))
}
