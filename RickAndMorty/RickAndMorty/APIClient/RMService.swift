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
    ///   - request: Request instance
    ///   - type: The type of object we expect to get back
    ///   - completion: Callback with data or error
    public func execute<T: Codable>(_ request: RMRequest, expecting type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        
    }
}
