//
//  RMService.swift
//  RickAndMorty
//
//  Created by Sean Veal on 12/5/23.
//

import Foundation

/// Primary API service object to get Rick & Morty data
final class RMService {
    /// Shared singleton instance
    static let shared = RMService()
    
    /// privitized constructor
    private init() {}
    
    /// What makes the API call
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - completion: <#completion description#>
    public func execute(_ request: RMRequest, completion: @escaping () -> Void) {
        
    }
}
