//
//  HTTPBasicAuthenticator.swift
//  WatsonSTT
//
//  Created by Eralp Karaduman on 12/17/16.
//  Copyright © 2016 Super Damage. All rights reserved.
//

import Foundation

class HTTPBasicAuthenticator {

    enum Result {
        case Success(token: String)
        case Failure
    }

    private let urlSession: URLSession
    private let urlRequest: URLRequest

    init?(tokenURLString: String,
         username: String,
         password: String,
         queryParams: [String : String]) {

        urlSession = URLSession(configuration: URLSessionConfiguration.default)

        let credentials = String(format: "%@:%@", username, password)
        guard let encodedCredentials = credentials.data(using: .utf8)?.base64EncodedString() else {
            return nil
        }

        guard let url = URL(string: tokenURLString)?.appendingQueryParameters(queryParams) else {
            return nil
        }

        var request = URLRequest(url: url)
        request.addValue(
            String(format: "Basic %@", encodedCredentials),
            forHTTPHeaderField: "Authorization"
        )

        self.urlRequest = request
    }

    func authenticationRequestTask(
        withCompletionHandler completionHandler: @escaping (Result) -> Void)
        -> URLSessionDataTask {

        return urlSession.dataTask(with: urlRequest) { (data, response, error) in

            DispatchQueue.main.async {

                guard let response = response as? HTTPURLResponse else {
                    completionHandler(Result.Failure)
                    return
                }

                guard error == nil else {
                    completionHandler(Result.Failure)
                    return
                }

                guard let data = data else {
                    completionHandler(Result.Failure)
                    return
                }

                guard response.statusCode == 200 else {
                    completionHandler(Result.Failure)
                    return
                }

                guard let stringData = String(data: data, encoding: .utf8) else {
                    completionHandler(Result.Failure)
                    return
                }

                completionHandler(Result.Success(token: stringData))
            }

        }
    }

}

protocol URLQueryParameterStringConvertible {
    var queryParameters: String {get}
}

extension Dictionary : URLQueryParameterStringConvertible {

    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {

            guard let encodedKey = String(describing: key).addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed
                ) else { fatalError() }

            guard let endocedValue = String(describing: value).addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed
                ) else { fatalError() }

            let part = String(format: "%@=%@", encodedKey, endocedValue)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }

}

extension URL {

    func appendingQueryParameters(_ parametersDictionary: [String : String]) -> URL {

        let URLString = String(
            format: "%@?%@",
            self.absoluteString,
            parametersDictionary.queryParameters
        )
        
        return URL(string: URLString)!
    }
}
