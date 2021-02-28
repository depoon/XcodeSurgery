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
    struct ExpressKeyGen: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "keygen",
            abstract: "Generate encryption key")
        
        @Option(name: [.customLong("projectDir")],
                help: "xcodeproj Directory eg. \"{PROJECT_DIR}\"")
        var projectDirPath: String

        func run() throws {
            do {
                print("--- Start of Express Keygen Execution")
                try createXcodeSurgeryHiddenDirectoryIfNeeded()
                try deleteExistingEncryptionKeyIfExists()
                try createEncryptionKey()
                print("--- End of Express Keygen Execution")
            }
            catch {
                print("--- Express Keygen failed with error: \(error.localizedDescription)")
            }
        }

        func createXcodeSurgeryHiddenDirectoryIfNeeded() throws {
            let hiddenDirectoryPath = XcodeSurgery.hiddenDirectoryPath(projectDirectoryPath: self.projectDirPath)
            let artifactsDirectoryPath = "\(hiddenDirectoryPath)/artifacts"
            let fileManager = FileManager.default

            var isDir:ObjCBool = true
            if !fileManager.fileExists(atPath: artifactsDirectoryPath, isDirectory: &isDir) {
                let directoryURL = URL(fileURLWithPath: artifactsDirectoryPath)
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            }
        }

        var encryptionKeyFilePath: String {
            let hiddenDirectoryPath = XcodeSurgery.hiddenDirectoryPath(projectDirectoryPath: self.projectDirPath)
            let filePath = "\(hiddenDirectoryPath)/artifacts/encryption-key"
            return filePath
        }

        func deleteExistingEncryptionKeyIfExists() throws {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: self.encryptionKeyFilePath) {
                try fileManager.removeItem(atPath: self.encryptionKeyFilePath)
            }
        }

        func createEncryptionKey() throws {
            let key = try VariantEncryption().generateRandomEncryptionKey()
            try VariantEncryption.FileManager().saveKeyToFile(key: key, toPath: self.encryptionKeyFilePath)
        }
    }
}
