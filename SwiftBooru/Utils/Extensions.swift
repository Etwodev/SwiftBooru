//
//  Extensions.swift
//  SwiftBooru
//
//  Created by Ethan Woods on 20/03/2023.
//

import Foundation
import SwiftUI

enum SearchKind {
    case imagesearchGelbooru
    case imagesearchSafebooru
    case tagsearchGelbooru
    case tagsearchSafebooru
}

struct Swiftbooru {
    static let defaultCornerRadius1: CGFloat = 10
    static let defaultCornerRadius2: CGFloat = 7
    static let defaultCornerRadius3: CGFloat = 5
    
    static let defaultPadding1: CGFloat = 10
    static let defaultPadding2: CGFloat = 7
    static let defaultPadding3: CGFloat = 5
    
    static func getURL(kind: SearchKind, term: String = "", limit: String = "", page: String = "") -> URL? {
        switch kind {
        case .imagesearchGelbooru:
            let urlString = "https://www.gelbooru.com/index.php?page=dapi&s=post&q=index&json=1&tags=\(term)&limit=\(limit)&pid=\(page)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            if let url = URL(string: urlString) {
                return url
            } else {
                return nil
            }
        case .imagesearchSafebooru:
            let urlString = "https://www.safebooru.org/index.php?page=dapi&s=post&q=index&json=1&tags=\(term)&limit=\(limit)&pid=\(page)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            if let url = URL(string: urlString) {
                return url
            } else {
                return nil
            }
        case .tagsearchGelbooru:
            let urlString = "https://www.gelbooru.com/index.php?page=autocomplete2&term=\(term)&type=tag_query&limit=\(String(limit))".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            if let url = URL(string: urlString) {
                return url
            } else {
                return nil
            }
        case .tagsearchSafebooru:
            let urlString = "https://www.safebooru.org/autocomplete.php?q=\(term)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            if let url = URL(string: urlString) {
                return url
            } else {
                return nil
            }
        }
    }
}

extension Color {
    static let defaultGrey1 = Color(red: 245/255, green: 245/255, blue: 245/255) // for #F5F5F5
    static let defaultGrey2 = Color(red: 237/255, green: 237/255, blue: 237/255) // for #EDEDED
    static let defaultGrey3 = Color(red: 214/255, green: 214/255, blue: 214/255) // for #D6D6D6
    static let defaultGrey4 = Color(red: 190/255, green: 190/255, blue: 190/255) // for #BEBEBE
    static let defaultGrey5 = Color(red: 153/255, green: 153/255, blue: 153/255) // for #999999
    static let defaultGrey6 = Color(red: 102/255, green: 102/255, blue: 102/255) // for #666666
    
    static let overlayColor = Color.black.opacity(0.6)
    static let backgroundColor = Color.gray.opacity(0.2)
    static let highlightColor = Color.gray.opacity(0.4)
    static let selectionColor = Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 0.25)
}

extension Collection {
    var indexedDictionary: [Int: Element] {
        return Dictionary(uniqueKeysWithValues: enumerated().map{($0,$1)})
    }
}

extension Image {
    func centerCropped(radius: CGFloat) -> some View {
        Color.clear
        .overlay(
            self
            .resizable()
            .scaledToFill()
        )
        .clipShape(RoundedRectangle(cornerRadius: radius))
        .contentShape(Rectangle())
    }
}

class FileDownloader {

    static func loadFileSync(url: URL, completion: @escaping (String?, Error?) -> Void)
    {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)

        if FileManager().fileExists(atPath: destinationUrl.path)
        {
            print("File already exists [\(destinationUrl.path)]")
            completion(destinationUrl.path, nil)
        }
        else if let dataFromURL = NSData(contentsOf: url)
        {
            if dataFromURL.write(to: destinationUrl, atomically: true)
            {
                print("file saved [\(destinationUrl.path)]")
                completion(destinationUrl.path, nil)
            }
            else
            {
                print("error saving file")
                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                completion(destinationUrl.path, error)
            }
        }
        else
        {
            let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
            completion(destinationUrl.path, error)
        }
    }

    static func loadFileAsync(url: URL, saveURL: URL, completion: @escaping (String?, Error?) -> Void)
    {
        let destinationUrl = saveURL

        if FileManager().fileExists(atPath: destinationUrl.path)
        {
            print("File already exists [\(destinationUrl.path)]")
            completion(destinationUrl.path, nil)
        }
        else
        {
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = session.dataTask(with: request, completionHandler:
            {
                data, response, error in
                if error == nil
                {
                    if let response = response as? HTTPURLResponse
                    {
                        if response.statusCode == 200
                        {
                            if let data = data
                            {
                                if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                                {
                                    completion(destinationUrl.path, error)
                                }
                                else
                                {
                                    completion(destinationUrl.path, error)
                                }
                            }
                            else
                            {
                                completion(destinationUrl.path, error)
                            }
                        }
                    }
                }
                else
                {
                    completion(destinationUrl.path, error)
                }
            })
            task.resume()
        }
    }
}
