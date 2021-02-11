//
//  VariantPlistReader.swift
//  
//
//  Created by Kenneth Poon on 6/2/21.
//

import Foundation
import VariantEncryption

public class VariantPlistReader: NSObject {

    static let shared = VariantPlistReader()

    var decryptionInput: VariantEncryption.DecryptionInput?
    var encryptionKey: EncryptionKey?

    var plist: [String: Any]!
    private override init() {}

    func loadPlistIfNeeded() throws {
        if plist != nil {
            return
        }
        guard let decryptionInput = self.decryptionInput else {
            fatalError("Unable to load Config")
        }
        guard let encryptionKey = self.encryptionKey else {
            fatalError("Unable to load encryptionKey")
        }
        let variantEncryption = VariantEncryption()
        let decryptedData = try variantEncryption.decrypt(result: decryptionInput, key: encryptionKey)

        guard let dicFromData =  try? PropertyListSerialization.propertyList(from: decryptedData, options: [], format: nil) else {
            fatalError("Unable to load Config")
        }
        guard let dictionary = dicFromData as? [String: Any] else {
            fatalError("Unable to load Config")
        }
        self.plist = dictionary
    }

    func string(for keys: [String]) throws -> String {
        try loadPlistIfNeeded()
        return string(for: self.plist, keys: keys)
    }

    func string(for dictionary: [String: Any], keys: [String]) -> String {
        guard keys.count >= 1 else {
            fatalError("Error Reading Config Dictionary")
        }
        guard let key = keys.first else {
            fatalError("Error Reading Config Dictionary")
        }
        if keys.count == 1 {
            guard let result = dictionary[key] as? String else {
                fatalError("Error Reading Config Dictionary")
            }
            return result
        }
        guard let subDictionary = dictionary[key] as? [String: Any] else {
            fatalError("Error Reading Config Dictionary")
        }
        let slicedKeys: [String] = Array(keys.dropFirst(1))
        return self.string(for: subDictionary, keys: slicedKeys)
    }

    func bool(for keys: [String]) throws -> Bool {
        try loadPlistIfNeeded()
        return bool(for: self.plist, keys: keys)
    }

    func bool(for dictionary: [String: Any], keys: [String]) -> Bool {
        guard keys.count >= 1 else {
            fatalError("Error Reading Config Dictionary")
        }
        guard let key = keys.first else {
            fatalError("Error Reading Config Dictionary")
        }
        if keys.count == 1 {
            guard let result = dictionary[key] as? Bool else {
                fatalError("Error Reading Config Dictionary")
            }
            return result
        }
        guard let subDictionary = dictionary[key] as? [String: Any] else {
            fatalError("Error Reading Config Dictionary")
        }
        let slicedKeys: [String] = Array(keys.dropFirst(1))
        return self.bool(for: subDictionary, keys: slicedKeys)
    }

    func number(for keys: [String]) throws -> NSNumber {
        try loadPlistIfNeeded()
        return number(for: self.plist, keys: keys)
    }

    func number(for dictionary: [String: Any], keys: [String]) -> NSNumber {
        guard keys.count >= 1 else {
            fatalError("Error Reading Config Dictionary")
        }
        guard let key = keys.first else {
            fatalError("Error Reading Config Dictionary")
        }
        if keys.count == 1 {
            guard let result = dictionary[key] as? NSNumber else {
                fatalError("Error Reading Config Dictionary")
            }
            return result
        }
        guard let subDictionary = dictionary[key] as? [String: Any] else {
            fatalError("Error Reading Config Dictionary")
        }
        let slicedKeys: [String] = Array(keys.dropFirst(1))
        return self.number(for: subDictionary, keys: slicedKeys)
    }

    func stringArray(for keys: [String]) throws -> [String] {
        try loadPlistIfNeeded()
        return stringArray(for: self.plist, keys: keys)
    }

    func stringArray(for dictionary: [String: Any], keys: [String]) -> [String] {
        guard keys.count >= 1 else {
            fatalError("Error Reading Config Dictionary")
        }
        guard let key = keys.first else {
            fatalError("Error Reading Config Dictionary")
        }
        if keys.count == 1 {
            guard let result = dictionary[key] as? [String] else {
                fatalError("Error Reading Config Dictionary")
            }
            return result
        }
        guard let subDictionary = dictionary[key] as? [String: Any] else {
            fatalError("Error Reading Config Dictionary")
        }
        let slicedKeys: [String] = Array(keys.dropFirst(1))
        return self.stringArray(for: subDictionary, keys: slicedKeys)
    }
}
