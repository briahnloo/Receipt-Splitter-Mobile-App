//
//  OCRManager.swift
//  Receipt Splitter
//
//  Created by Brian Liu on 12/29/23.
//

import Foundation
import UIKit

class OCRManager {
    let clientId = "vrfvOVhYZ8eZL44z7sg0fVuPEFx9iLVBpuXM4xC"
    let clientSecret = "s4Lmx4Gc5AA3zI9sMrOM1FeGPzDPnWcYhaYgpsJyW2e5YKSEP74kGhUHX7vFc6BxYoBV6OsVyTOxBWsolLG05USwTuWYWnUahs9ngSfjv2t4GEdJwrksHIkvZJYm2Z5o"
    let username = "brian.liu2021"
    let apiKey = "de7f8706f94237c7601aa4f0c5f6076c"

    func processImage(_ image: UIImage, completion: @escaping (Result<[String], Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.9) else {
            completion(.failure(URLError(.cannotCreateFile)))
            return
        }

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
