//
//  KeychainStorage.swift
//  Roadmap
//
//  Created by Onur Bas on 10/03/2024.
//

import Foundation
import KeychainAccess

enum KeychainStorage {
    static let keychain = Keychain(service: "dk.invoke.Roadmap")

    enum Key: String {
        case appleUserId
        case authorizationToken
    }

    static func save(_ value: String, forKey key: Key) {
        do {
            try keychain.set(value, key: key.rawValue)
        } catch {
            print("Error saving to keychain: \(error)")
        }
    }

    static func load(_ key: Key) -> String? {
        do {
            return try keychain.get(key.rawValue)
        } catch {
            print("Error loading from keychain: \(error)")
            return nil
        }
    }

    static func loadUser() -> SessionViewModel.User? {
        guard let appleUserId = load(.appleUserId), let authorizationToken = load(.authorizationToken) else { return nil }
        return SessionViewModel.User(appleUserId: appleUserId, authorizationToken: authorizationToken)
    }

    static func delete(_ key: Key) {
        do {
            try keychain.remove(key.rawValue)
        } catch {
            print("Error deleting from keychain: \(error)")
        }
    }
}
