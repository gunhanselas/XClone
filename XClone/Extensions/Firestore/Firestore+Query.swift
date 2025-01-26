//
//  Firestore+Query.swift
//  XClone
//
//  Created by Stephan Dowless on 1/26/25.
//

import FirebaseFirestore

extension Query {
    func getDocuments<T: Decodable>(as type: T.Type) async throws -> [T] {
        let snapshot = try await getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: T.self) }
    }
}
