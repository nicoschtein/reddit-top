//
//  NetworkManager.swift
//  reddit
//
//  Created by Nicolas Schteinschraber on 10/05/2019.
//  Copyright © 2019 Schtein. All rights reserved.
//

import Foundation
import UIKit

enum NetworkManagerError: Error {
    case EndpointError(reason: String)
    case NetworkError(reason: String)
    case DataError(reason: String)
    case ParsingError(reason: String)
}

struct Listing: Codable {
    var data:ListingData
    var kind: String

    static func endpointTop50() -> String {
        return endpointTop50(after:"")
    }
    static func endpointTop50(after:String) -> String {
        return "https://api.reddit.com/top?limit=50&after="+after
    }

}
struct Link: Codable  {
    var name: String
    var url: String?
    var title: String
    var author: String
    var created_utc: Int
    var thumbnail: String?
    var ups: Int
    var num_comments: Int
    var subreddit: String
    var post_hint: String?
    var app_user_read: Bool?

    var isImage:Bool {
        return (post_hint ?? "") == "image"
    }
    var created:Date? {
        return Date(timeIntervalSince1970: TimeInterval(self.created_utc))
    }
}

struct ListingData: Codable {
    var after:String?
    var before:String?
    var children:[ListingChild]
}

struct ListingChild: Codable {
    var kind:String
    var data:Link
}

class NetworkManager {
    var lastFetchedId:String = ""
    var fetching: Bool = false
    /// Fetches top listing from endpoint and calls completion handler when finished
    /// Check for nil Listing and/or NetworkManagerError to handle appropriately.
    private func fetchTopListing(paginate:Bool, completionHandler: @escaping (Listing?, NetworkManagerError?) -> Void) {
        
        let endpoint = paginate ? Listing.endpointTop50(after:lastFetchedId) : Listing.endpointTop50()
        
        guard let endpointUrl = URL(string: endpoint) else {
            let error = NetworkManagerError.EndpointError(reason: "Invalid Top 50 URL endpoint.")
            completionHandler(nil, error)
            return
        }
        let urlRequest = URLRequest(url: endpointUrl)
        
        // Setup data task
        let task = URLSession.shared.dataTask(with: urlRequest) {[weak self]
            (data, response, error) in
            
            self?.fetching = false
            
            // Network request checks
            guard error == nil else {
                completionHandler(nil, NetworkManagerError.NetworkError(reason: error!.localizedDescription))
                return
            }
            guard let responseData = data else {
                let error = NetworkManagerError.DataError(reason: "No data returned from endpoint.")
                completionHandler(nil, error)
                return
            }
            
            // Parsing response data
            let decoder = JSONDecoder()
            do {
                let listing = try decoder.decode(Listing.self, from: responseData)
                self?.lastFetchedId = listing.data.after ?? ""
                completionHandler(listing, nil)
            } catch {
                let netError = NetworkManagerError.ParsingError(reason: error.localizedDescription)
                completionHandler(nil, netError)
            }
        }
        fetching = true
        // Run data task
        task.resume()
    }

    /// Fetches Reddit Top 50 listing and calls completion handler when finished
    /// - Parameter completionHandler:
    /// - Parameter links: arry of Links. (optional)
    /// - Parameter errorString: String with error reason if any. (optional)
    func getTopListing(paginate:Bool, completionHandler:@escaping (_ links:[Link]?, _ errorString:String?) -> Void) {
        fetchTopListing(paginate:paginate){ (listing, error) in
            if let error = error {
                
                // For now only return the error type with reason, but this could be used for handling different errors in different ways.
                // i.e. retrying on NeteorkError
                
                var errorReason:String = "Unknown Error"
                if case let .EndpointError(reason) = error {
                    errorReason = "EndpointError: " + reason
                } else if case let .NetworkError(reason) = error {
                    errorReason = "NetworkError: " + reason
                } else if case let .DataError(reason) = error {
                    errorReason = "DataError: " + reason
                } else if case let .ParsingError(reason) = error {
                    errorReason = "ParsingError: " + reason
                }
                
                completionHandler(nil, errorReason)
                return
            }
            guard let listing = listing else {
                completionHandler(nil, "Implementation error, this should never happen.")
                return
            }

            let links = listing.data.children.compactMap({ (child) -> Link? in
                return child.data
            })
            completionHandler(links, nil)
        }
    }
    
    static var imageCache = NSCache<NSString, UIImage>()
    
    static func loadImageFromWeb(url:String, completionHandler:@escaping (_ image:UIImage?) -> Void) {
        
        if let imageFromCache = imageCache.object(forKey: url as NSString) {
            // Call completion handler with image from cache
            completionHandler(imageFromCache)
            return
        }
        
        guard let endpointUrl = URL(string: url) else {
            completionHandler(nil)
            return
        }
        let urlRequest = URLRequest(url: endpointUrl)
        
        // Setup data task
        let task = URLSession.shared.dataTask(with: urlRequest) {
            (data, response, error) in
            
            // Network request checks
            guard error == nil, let responseData = data else {
                completionHandler(nil)
                return
            }
            
            guard let image = UIImage(data: responseData) else {
                completionHandler(nil)
                return
            }
            
            // Add to Cache
            imageCache.setObject(image, forKey: url as NSString)
            
            // Call completion handler with image
            completionHandler(image)
        }
        // Run data task
        task.resume()

        
    }
    
}
