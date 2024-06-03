//
//  OCRManager.swift
//  Receipt Splitter
//
//  Created by Brian Liu on 12/29/23.
//

import Foundation
import UIKit

class OCRManager {
    var clientId: String
    var clientSecret: String
    var username: String
    var apiKey: String

    init() {
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let config = NSDictionary(contentsOfFile: path) as? [String: Any] {
            clientId = config["clientId"] as? String ?? ""
            clientSecret = config["clientSecret"] as? String ?? ""
            username = config["username"] as? String ?? ""
            apiKey = config["apiKey"] as? String ?? ""
        } else {
            clientId = ""
            clientSecret = ""
            username = ""
            apiKey = ""
        }
    }

    func processImage(_ image: UIImage, completion: @escaping (Result<[String], Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.9) else {
            completion(.failure(URLError(.cannotCreateFile)))
            return
        }

        let url = URL(string: "https://api.veryfi.com/api/v8/partner/documents")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let url = URL(string: "https://api.veryfi.com/api/v8/partner/documents")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Client-ID \(clientId)", forHTTPHeaderField: "CLIENT-ID")
        request.setValue("apikey \(username):\(apiKey)", forHTTPHeaderField: "Authorization")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"receipt.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(.failure(error ?? URLError(.badServerResponse)))
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // This is where you'd typically parse the JSON response into a more structured format
                    // For now, we're just capturing the entire JSON
                    print(jsonResponse)
                    struct ReceiptItem: Identifiable {
                        let id = UUID()
                        var name: String
                        var price: Double
                        // Add any other relevant fields
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
