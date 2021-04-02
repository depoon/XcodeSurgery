//
//  ExpressKeyGen.swift
//  
//
//  Created by Kenneth Poon on 28/2/21.
//

import Foundation
import ArgumentParser
import VariantEncryption

extension XcodeSurgery.Express {
    struct ExpressKeyGen: ParsableCommand, VerboseCommand {
        static var configuration = CommandConfiguration(
            commandName: "keygen",
            abstract: "Generate encryption key")
        
        @Flag var verbose = false
        
        func run() throws {
            do {
                XcodeSurgery.setVerboseMode(self)
                XcodeSurgery.log("--- Start of Express Keygen Execution")
                try XcodeSurgery.checkIfXcodeprojExistsInCurrentDirectory()
                try XcodeSurgery.createXcodeSurgeryHiddenDirectoryIfNeeded()
                try deleteExistingEncryptionKeyIfExists()
                
                try createEncryptionPassword()

                XcodeSurgery.log("--- End of Express Keygen Execution")
            }
            catch {
                XcodeSurgery.log("--- Express Keygen failed with error: \(error.localizedDescription)")
            }
        }

        func deleteExistingEncryptionKeyIfExists() throws {
            let encryptionKeyFilePath = XcodeSurgery.Express.encryptionKeyFilePath
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: encryptionKeyFilePath) {
                try fileManager.removeItem(atPath: encryptionKeyFilePath)
            }
        }

        func createEncryptionPassword() throws {
            let password = Password.generateRandomPassword()
            try password.savePasswordToFile()
        }
    }
}

private extension Password {
    func savePasswordToFile() throws {
        try XcodeSurgery.createSecretsDirectoryIfNeeded()
        
        try VariantEncryption.FileManager()
            .saveSecretStringToFile(string: self.password,
                                    toPath: XcodeSurgery.Express.encryptionPasswordFilePath)
        try VariantEncryption.FileManager()
            .saveSecretStringToFile(string: self.salt,
                                    toPath: XcodeSurgery.Express.encryptionPasswordSaltFilePath)
        
    }
}
