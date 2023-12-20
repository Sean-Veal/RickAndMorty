//
//  RMAPICacheManager.swift
//  RickAndMorty
//
//  Created by Sean Veal on 12/13/23.
//

import Foundation

/// Manages in  memory session scoped API caches
final class RMAPICacheManager {
    // API URL : Data
    private var cacheDictionary: [RMEndpoint : NSCache<NSString, NSData>] = [:]
    
    private var cacahe = NSCache<NSString, NSData>()
    
    init() {
        setUpCache()
    }
    
    // MARK: - Public
    public func cacheResponse(for endpoint: RMEndpoint, url: URL?) -> Data? {
        guard let targetCache = cacheDictionary[endpoint],
              let url = url
        else { return nil }
        let key = url.absoluteString as NSString
        return targetCache.object(forKey: key) as? Data
    }
    
    public func setCache(for endpoint: RMEndpoint, url: URL?, data: Data) {
        guard let targetCache = cacheDictionary[endpoint],
              let url = url
        else { return }
        let key = url.absoluteString as NSString
        let value = data as NSData
        targetCache.setObject(value, forKey: key)
    }
    
    // MARK: - Private
    
    private func setUpCache() {
         _ = RMEndpoint.allCases.compactMap { endpoint in
            cacheDictionary[endpoint] = NSCache<NSString, NSData>()
        }
    }
    
    
}
