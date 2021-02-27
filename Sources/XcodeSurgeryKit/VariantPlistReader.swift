//
//  VariantPlistReader.swift
//  
//
//  Created by Kenneth Poon on 6/2/21.
//

import Foundation
import VariantEncryption

public class VariantPlistReader: NSObject {

    public static let shared = VariantPlistReader()

    public var decryptionInput: VariantEncryption.DecryptionInput?

    var plist: [String: Any]!
    private override init() {}

    public func loadPlistIfNeeded() {
        if plist != nil {
            return
        }
        guard let decryptionInput = self.decryptionInput else {
            fatalError("Unable to load Config")
        }
        do {
            let variantEncryption = VariantEncryption()
            let decryptedData = try variantEncryption.decrypt(decryptionInput: decryptionInput)

            guard let dicFromData =  try? PropertyListSerialization.propertyList(from: decryptedData, options: [], format: nil) else {
                fatalError("Unable to load Config")
            }
            guard let dictionary = dicFromData as? [String: Any] else {
                fatalError("Unable to load Config")
            }
            self.plist = dictionary
        } catch {
            fatalError("Unable to load Config")
        }
    }

    public func string(for keys: [String]) -> String {
        loadPlistIfNeeded()
        return string(for: self.plist, keys: keys)
    }

    public func string(for dictionary: [String: Any], keys: [String]) -> String {
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

    public func bool(for keys: [String]) -> Bool {
        loadPlistIfNeeded()
        return bool(for: self.plist, keys: keys)
    }

    public func bool(for dictionary: [String: Any], keys: [String]) -> Bool {
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

    public func number(for keys: [String]) -> NSNumber {
        loadPlistIfNeeded()
        return number(for: self.plist, keys: keys)
    }

    public func number(for dictionary: [String: Any], keys: [String]) -> NSNumber {
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

    func stringArray(for keys: [String]) -> [String] {
        loadPlistIfNeeded()
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
