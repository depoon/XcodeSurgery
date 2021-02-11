//
//  VariantEncryption.swift
//  
//
//  Created by Kenneth Poon on 5/2/21.
//

import Foundation
import CryptoSwift

public typealias EncryptionKey = [UInt8]
public typealias EncryptionIV = [UInt8]

public class VariantEncryption {
    
    public init() {}
    
    public typealias DecryptionInput = EncryptionResult

    public struct EncryptionResult {
        public let ciphertext: Data
        public let iv: EncryptionIV
    }

    public func encrypt(plainText: Data, key: EncryptionKey) throws -> EncryptionResult {
        let iv = self.generateRandomAesIV()
        let aes = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs7)
        let encryptedBytes = try aes.encrypt(plainText.bytes)
        let encryptedData = Data(encryptedBytes)
        return EncryptionResult(ciphertext: encryptedData, iv: iv)
    }
    
    public func decrypt(result: EncryptionResult, key: EncryptionKey ) throws -> Data {
        let iv = result.iv
        let aes = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs7)
        let decryptedBytes = try aes.decrypt(result.ciphertext.bytes)
        let decryptedData = Data(decryptedBytes)
        return decryptedData
    }

    public func generateRandomEncryptionKey() throws -> EncryptionKey {
        let password: [UInt8] = Array(self.generateRandomString(of: 1000).utf8)
        let salt: [UInt8] = Array(self.generateRandomString(of: 100).utf8)
        let key = try PKCS5.PBKDF2(
            password: password,
            salt: salt,
            iterations: 4096,
            keyLength: 32, /* AES-256 */
            variant: .sha256
        ).calculate()
        return key
    }
    
    public func generateRandomAesIV() -> EncryptionIV {
        return AES.randomIV(AES.blockSize)
    }
    
    public func createDecryptionInput(encryptionKeyFilePath: String,
                               ivFilePath: String,
                               cipherTextFilePath: String) throws -> DecryptionInput {
        guard let encryptionFileURL = URL(string: cipherTextFilePath) else {
            fatalError("Unable to load cipherText")
        }
        let cipherText = try Data(contentsOf: encryptionFileURL)
        
        let variantFileManager = VariantEncryption.FileManager()
        let encryptionIv = try variantFileManager.readIv(filePath: ivFilePath)
        
        return DecryptionInput(ciphertext: cipherText, iv: encryptionIv)
        
    }
}

private extension VariantEncryption {
    
    private func generateRandomString(of length: Int) -> String {
        var key = ""
        for _ in 0 ..< length {
            key.append(VariantEncryption.characters.randomElement()!)
        }
        return key
    }
    
    private static var characters: String {
        return "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    }
}

public extension VariantEncryption {
    class FileManager {

        public init() {}
        
        public func saveKeyToFile(key: EncryptionKey, toPath: String) throws {
            let url = try self.saveToFile(bytes: key, toPath: toPath)
            print("** Encryption Key saved to: \(url.absoluteURL)")
        }

        public func saveIvToFile(iv: EncryptionIV, toPath: String) throws {
            let url = try self.saveToFile(bytes: iv, toPath: toPath)
            print("** IV Key saved to: \(url.absoluteURL)")
        }

        public func saveCipertextToFile(ciphertext: Data, toPath: String) throws {
            let url = try self.saveToFile(data: ciphertext, toPath: toPath)
            print("** Ciphertext saved to: \(url.absoluteURL)")
        }

        public func readKey(filePath: String) throws -> EncryptionKey {
            return try self.readBytes(filePath: filePath)
        }

        public func readIv(filePath: String) throws -> EncryptionIV {
            return try self.readBytes(filePath: filePath)
        }
    }
}

private extension VariantEncryption.FileManager {
    
    private func saveToFile(bytes: [UInt8], toPath: String) throws -> URL {
        let fileURL = URL(fileURLWithPath: toPath)
        let data = Data(bytes)
        try data.write(to: fileURL)
        return fileURL
    }
    
    private func saveToFile(data: Data, toPath: String) throws -> URL {
        let fileURL = URL(fileURLWithPath: toPath)
        try data.write(to: fileURL)
        return fileURL
    }
    
    private func readBytes(filePath: String) throws -> [UInt8] {
        guard let data = NSData(contentsOfFile: filePath) else {
            throw NSError(domain: "Unable to read key at path '\(filePath)'", code: 0, userInfo: nil)
        }
        var buffer = [UInt8](repeating: 0, count: data.length)
        data.getBytes(&buffer, length: data.length)

        return buffer
    }
}
