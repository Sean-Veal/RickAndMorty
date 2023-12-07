//
//  RMRequest.swift
//  RickAndMorty
//
//  Created by Sean Veal on 12/5/23.
//

import Foundation

/// Object that represents a single API call
final class RMRequest {
    
    /// API Constants
    private struct Constants {
        static let baseUrl = "https://rickandmortyapi.com/api"
    }
    
    /// Desired endpoint
    private let endpoint: RMEndpoint
    
    /// Path components for API if any
    private let pathComponents: Set<String>
    
    private let queryParameters: [URLQueryItem]
    
    /// Constructed url for the api request in string format
    private var urlString: String {
        var string = Constants.baseUrl
        string += "/"
        string += endpoint.rawValue
        
        if !pathComponents.isEmpty {
            string += "/"
            pathComponents.forEach {
                string += "\($0)"
            }
        }
        
        if !queryParameters.isEmpty {
            string += "?"
            let argumentString = queryParameters.compactMap {
                guard let value = $0.value else { return nil }
                return "\($0.name)=\(value)"
            }.joined(separator: "&")
            
            string += argumentString
        }
        
        return string
    }
    
    // MARK: - Public
    
    /// Computed & constructed API url
    public var url: URL? {
        return URL(string: urlString)
    }
    
    /// Construct Request
    /// - Parameters:
    ///   - endpoint: Target endpoit
    ///   - pathComponents: Collection of path components
    ///   - queryParameters: Collection of query parameters
    public init(endpoint: RMEndpoint,
                pathComponents: Set<String> = [],
                queryParameters: [URLQueryItem] = []) {
        self.endpoint = endpoint
        self.pathComponents = pathComponents
        self.queryParameters = queryParameters
    }
}
