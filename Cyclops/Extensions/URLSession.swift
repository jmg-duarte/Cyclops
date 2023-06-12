//
//  URLSession.swift
//  Cyclops
//
//  Created by José Duarte on 12/06/2023.
//

import Foundation

extension URLSession {
    func httpData(from url: URL) async throws -> Data {
        guard let (data, response) = try await self.data(from: url, delegate: nil) as? (Data, HTTPURLResponse),
              (200...299).contains(response.statusCode)
        else {
            fatalError("Unimplemented")
        }
        return data
    }
}
