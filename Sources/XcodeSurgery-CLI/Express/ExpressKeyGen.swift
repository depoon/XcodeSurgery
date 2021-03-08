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
                try createXcodeSurgeryHiddenDirectoryIfNeeded()
                try deleteExistingEncryptionKeyIfExists()
                try createEncryptionKey()

                XcodeSurgery.log("--- End of Express Keygen Execution")
            }
            catch {
                XcodeSurgery.log("--- Express Keygen failed with error: \(error.localizedDescription)")
            }
        }

        func createXcodeSurgeryHiddenDirectoryIfNeeded() throws {
            let fileManager = FileManager.default
            let artifactsDirectoryPath = XcodeSurgery.hiddenDirectoryPath(projectDirectoryPath: fileManager.currentDirectoryPath)

            var isDir:ObjCBool = true
            
            if !fileManager.fileExists(atPath: artifactsDirectoryPath, isDirectory: &isDir) {

                let directoryURL = URL(fileURLWithPath: artifactsDirectoryPath)
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            }
        }

        func deleteExistingEncryptionKeyIfExists() throws {
            let encryptionKeyFilePath = XcodeSurgery.Express.encryptionKeyFilePath
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: encryptionKeyFilePath) {
                try fileManager.removeItem(atPath: encryptionKeyFilePath)
            }
        }

        func createEncryptionKey() throws {
            let fileManager = FileManager.default
            let hiddenArtifactsDirectoryPath = XcodeSurgery.hiddenArtifactsDirectoryPath(projectDirectoryPath: fileManager.currentDirectoryPath)
            try self.createDirectoryIfNeeded(directoryPath: hiddenArtifactsDirectoryPath)
            
            let encryptionKeyFilePath = XcodeSurgery.Express.encryptionKeyFilePath
            let key = try VariantEncryption().generateRandomEncryptionKey()
            try VariantEncryption.FileManager().saveKeyToFile(key: key,
                                                              toPath: encryptionKeyFilePath)
        }
        
        func createDirectoryIfNeeded(directoryPath: String) throws {
            var isDir:ObjCBool = true
            
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: directoryPath, isDirectory: &isDir) {
                let directoryURL = URL(fileURLWithPath: directoryPath)
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            }
        }
    }
}
