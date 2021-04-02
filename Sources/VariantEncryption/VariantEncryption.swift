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
    
    public static let passwordSaltFileName: String = "encryption-password-salt"
    public static let passwordFileName: String = "encryption-password"
    
    public init() {}

    public struct EncryptionResult {
        public let ciphertext: Data
        public let iv: EncryptionIV
    }
    
    public struct DecryptionInput {
        let encryptionResult: EncryptionResult
        let encryptionKey: EncryptionKey
    }

    public func encrypt(plainText: Data, key: EncryptionKey) throws -> EncryptionResult {
        let iv = self.generateRandomAesIV()
        let aes = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs7)
        let encryptedBytes = try aes.encrypt(plainText.bytes)
        let encryptedData = Data(encryptedBytes)
        return EncryptionResult(ciphertext: encryptedData, iv: iv)
    }
    
    public func decrypt(decryptionInput: DecryptionInput) throws -> Data {
        let iv = decryptionInput.encryptionResult.iv
        let aes = try AES(key: decryptionInput.encryptionKey, blockMode: CBC(iv: iv), padding: .pkcs7)
        let decryptedBytes = try aes.decrypt(decryptionInput.encryptionResult.ciphertext.bytes)
        let decryptedData = Data(decryptedBytes)
        return decryptedData
    }
    
    public func generateEncryptionKey(password: [UInt8],
                                      salt: [UInt8]) throws -> EncryptionKey {
        let key = try PKCS5.PBKDF2(
            password: password,
            salt: salt,
            iterations: 4096,
            keyLength: 32, /* AES-256 */
            variant: .sha256
        ).calculate()
        return key
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
    
    public func generateRandomPassword() -> String {
        let passwordString = self.generateRandomString(of: 1000)
        return passwordString
    }
    
    public func generateRandomPasswordSalt() -> String {
        let passwordSaltString = self.generateRandomString(of: 100)
        return passwordSaltString
    }
    
    public func createDecryptionInput(encryptionKeyFilePath: String,
                               ivFilePath: String,
                               cipherTextFilePath: String) throws -> DecryptionInput {
        let ciphertextFileURL: URL = URL(fileURLWithPath: cipherTextFilePath)
        let cipherText = try Data(contentsOf: ciphertextFileURL)
        let variantFileManager = VariantEncryption.FileManager()
        let encryptionIv = try variantFileManager.readIv(filePath: ivFilePath)
        let encryptionKey = try variantFileManager.readKey(filePath: encryptionKeyFilePath)
        let encryptionResult = EncryptionResult(ciphertext: cipherText, iv: encryptionIv)
        return DecryptionInput(encryptionResult: encryptionResult, encryptionKey: encryptionKey)
    }
    
    public func createDecryptionInput(encryptionPassword: String,
                                      ivFilePath: String,
                                      cipherTextFilePath: String) throws -> DecryptionInput {
        let ciphertextFileURL: URL = URL(fileURLWithPath: cipherTextFilePath)
        let cipherText = try Data(contentsOf: ciphertextFileURL)
        
        let variantFileManager = VariantEncryption.FileManager()
        let encryptionIv = try variantFileManager.readIv(filePath: ivFilePath)

        let encryptionKey = try encryptionPassword.createEncryptionKey()
        let encryptionResult = EncryptionResult(ciphertext: cipherText, iv: encryptionIv)
        return DecryptionInput(encryptionResult: encryptionResult, encryptionKey: encryptionKey)
    }
    
    public func createDecryptionInput(password: Password,
                                      ivFilePath: String,
                                      cipherTextFilePath: String) throws -> DecryptionInput {
        let ciphertextFileURL: URL = URL(fileURLWithPath: cipherTextFilePath)
        let cipherText = try Data(contentsOf: ciphertextFileURL)
        
        let variantFileManager = VariantEncryption.FileManager()
        let encryptionIv = try variantFileManager.readIv(filePath: ivFilePath)

        let encryptionKey = try password.generateEncryptionKey()
        let encryptionResult = EncryptionResult(ciphertext: cipherText, iv: encryptionIv)
        return DecryptionInput(encryptionResult: encryptionResult, encryptionKey: encryptionKey)
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
        
        public func saveSecretStringToFile(string: String, toPath: String) throws {
            let targetURL = URL(fileURLWithPath: toPath)
            try string.write(to: targetURL, atomically: false, encoding: .utf8)
            print("** Secret String saved to: \(targetURL.absoluteURL)")
        }

        public func readKey(filePath: String) throws -> EncryptionKey {
            return try self.readBytes(filePath: filePath)
        }

        public func readIv(filePath: String) throws -> EncryptionIV {
            return try self.readBytes(filePath: filePath)
        }
        
        public func readSecretFromFile(filePath: String) throws -> String {
            return try self.readString(filePath: filePath)
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
    
    private func readString(filePath: String) throws -> String {
        let fileURL = URL(fileURLWithPath: filePath)
        let string = try String(contentsOf: fileURL, encoding: .utf8)
        return string
    }
}

public extension String {
    func createEncryptionKey(salt: [UInt8] = []) throws -> EncryptionKey {
        print("aaaa: \(self)")
        let key = try PKCS5.PBKDF2(
            password: Array(self.utf8),
            salt: [],
            iterations: 4096,
            keyLength: 32, /* AES-256 */
            variant: .sha256
        ).calculate()
        return key
    }
}

public extension Password {
    func generateEncryptionKey() throws -> EncryptionKey {
        let password: [UInt8] = Array(self.password.utf8)
        let salt: [UInt8] = Array(self.salt.utf8)
        let key = try PKCS5.PBKDF2(
            password: password,
            salt: salt,
            iterations: 4096,
            keyLength: 32, /* AES-256 */
            variant: .sha256
        ).calculate()
        return key
    }
}
