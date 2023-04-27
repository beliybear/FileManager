//
//  KeychainService.swift
//  FileManager
//
//  Created by Beliy.Bear on 24.04.2023.
//

import UIKit
import KeychainAccess

protocol KeychainServiceProtocol {
    func getData(forKey key: String) -> Data?
    func saveData(_ data: Data, forKey key: String) -> Bool
    func updateData(_ data: Data, forKey key: String) -> Bool
    func deleteData(forKey key: String) -> Bool
}

class KeychainService: KeychainServiceProtocol {
    private let keychain = Keychain(service: "ru.beliybear.FileManager")

    func getData(forKey key: String) -> Data? {
        return try? keychain.getData(key)
    }

    func saveData(_ data: Data, forKey key: String) -> Bool {
        do {
            try keychain.set(data, key: key)
            return true
        } catch {
            return false
        }
    }

    func updateData(_ data: Data, forKey key: String) -> Bool {
        do {
            try keychain
                .accessibility(.afterFirstUnlock)
                .set(data, key: key)
            return true
        } catch {
            return false
        }
    }
    
    func deleteData(forKey key: String) -> Bool {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}
