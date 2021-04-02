//
//  ExpressEncrypt.swift
//  
//
//  Created by Kenneth Poon on 2/3/21.
//

import Foundation
import ArgumentParser
import VariantEncryption

extension XcodeSurgery.Express {
    struct ExpressEncrypt: ParsableCommand, VerboseCommand {
        static var configuration = CommandConfiguration(
            commandName: "encrypt",
            abstract: "Generate sourcecodes to read variant file")
        
        @Option(name: [.customLong("targetPlist")],
                help: "filepath of plist to encrypt")
        var targetPlist: String
        
        @Option(name: [.customLong("structName"),
                       .customShort("n")],
                help: "Name of struct to access variant values")
        var structName: String
        
        @Flag var verbose = false

        func run() throws {
            do {
                XcodeSurgery.setVerboseMode(self)
                XcodeSurgery.log("--- Start of Express Encrypt Execution")
                try XcodeSurgery.checkIfXcodeprojExistsInCurrentDirectory()
                try XcodeSurgery.checkIfXcodeSurgeryExistsInCurrentDirectory()
                try XcodeSurgery.createArtifactsDirectoryIfNeeded()

                let password = try self.readEncryptionPassword()
                try encryption(password: password)
                try generatePlistReaderStructSourceCode(password: password)
                XcodeSurgery.log("--- End of Express Encrypt Execution")
            }
            catch {
                XcodeSurgery.log("--- Express Encrypt failed with error: \(error)")
            }
        }
        
        func encryption(password: Password) throws {
            let encryptionKey = try password.generateEncryptionKey()
            let target = try XcodeSurgery.createTargetData(targetFilePath: targetPlist)
            let encryptionResult = try VariantEncryption().encrypt(plainText: target,
                                                                   key: encryptionKey)

            let variantEncryptionFileManager = VariantEncryption.FileManager()
            try variantEncryptionFileManager.saveIvToFile(iv: encryptionResult.iv,
                                                          toPath: XcodeSurgery.Express.ivOutputFile)
            try variantEncryptionFileManager.saveCipertextToFile(ciphertext: encryptionResult.ciphertext,
                                                                 toPath: XcodeSurgery.Express.encryptedOutputFile)

            XcodeSurgery.log("--- Attempt Encryption Verification")
            let variantEncryption = VariantEncryption()
            let decryptionInput =
                try variantEncryption
                        .createDecryptionInput(password:password,
                                               ivFilePath: XcodeSurgery.Express.ivOutputFile,
                                               cipherTextFilePath: XcodeSurgery.Express.encryptedOutputFile)
            let data = try variantEncryption.decrypt(decryptionInput: decryptionInput)
            
            let originalString = String(decoding: data, as: UTF8.self)
            let decryptedString = String(decoding: data, as: UTF8.self)
            if originalString != decryptedString {
                throw NSError(domain: "Error in Encryption Process", code: 0, userInfo: nil)
            }
        }
        
        func generatePlistReaderStructSourceCode(password: Password) throws {
            let outputFile = XcodeSurgery.Express.plistReaderSourceOutputFile(structName: structName)
            let sourceCodeWriter = SourceCodeWriter()
            let sourceCode = sourceCodeWriter.generatePlistReaderSourceCode(createMode: .express,
                                                                            plistFile: targetPlist,
                                                                            structName: structName,
                                                                            encryptionPassword: password.password,
                                                                            password: password)
            let shouldWriteOutputfile = sourceCodeWriter
                                            .shouldWriteOutputfile(outputFile: outputFile,
                                                                   sourceCodeToWrite: sourceCode)
            if shouldWriteOutputfile {
                sourceCodeWriter.writeSourceCode(outputFile: outputFile, sourceCodeToWrite: sourceCode)
            }
        }
        
        func readEncryptionPassword() throws -> Password {
            let encryptionPasswordFilePath = XcodeSurgery.Express.encryptionPasswordFilePath
            let encryptionPasswordSaltFilePath = XcodeSurgery.Express.encryptionPasswordSaltFilePath
            let variantEncryptionFileManager = VariantEncryption.FileManager()
            
            let passwordString = try variantEncryptionFileManager.readSecretFromFile(filePath: encryptionPasswordFilePath)
            let saltString = try variantEncryptionFileManager.readSecretFromFile(filePath: encryptionPasswordSaltFilePath)
            
            return Password(password: passwordString, salt: saltString)
        }
    }
}
