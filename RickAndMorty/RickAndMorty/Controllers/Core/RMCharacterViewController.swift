//
//  RMCharacterViewController.swift
//  RickAndMorty
//
//  Created by Sean Veal on 12/5/23.
//

import UIKit

/// Controller to show and search for characters
final class RMCharacterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Characters"
        
        let request = RMRequest(
            endpoint: .character,
            queryParameters: [
                URLQueryItem(name: "name", value: "rick"),
                URLQueryItem(name: "status", value: "alive")
            ]
        )
        print("URL: \(request.url)")
        
        RMService.shared.execute(request, expecting: RMCharacter.self) { result in
            switch result {
            case .success(let success):
                <#code#>
            case .failure(let failure):
                <#code#>
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
