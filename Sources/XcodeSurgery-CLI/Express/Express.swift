//
//  Express.swift
//  
//
//  Created by Kenneth Poon on 28/2/21.
//

import Foundation
import ArgumentParser

extension XcodeSurgery {

    struct Express: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "express",
            abstract: "express commands for applying simplified xcodesurgery",
            subcommands: [
                XcodeSurgery.Express.ExpressKeyGen.self,
                XcodeSurgery.Express.ExpressEncrypt.self])
        
        static var encryptionKeyFilePath: String {
            let fileManager = FileManager.default
            let hiddenArtifactsDirectoryPath = XcodeSurgery.hiddenArtifactsDirectoryPath(projectDirectoryPath: fileManager.currentDirectoryPath)
            let filePath = "\(hiddenArtifactsDirectoryPath)/encryption-key"
            return filePath
        }
        
        static var ivOutputFile: String {
            let fileManager = FileManager.default
            let hiddenArtifactsDirectoryPath = XcodeSurgery.hiddenArtifactsDirectoryPath(projectDirectoryPath: fileManager.currentDirectoryPath)
            let outputFile = "\(hiddenArtifactsDirectoryPath)/iv"
            return outputFile
        }

        static var encryptedOutputFile: String {
            let fileManager = FileManager.default
            let hiddenArtifactsDirectoryPath = XcodeSurgery.hiddenArtifactsDirectoryPath(projectDirectoryPath: fileManager.currentDirectoryPath)
            let outputFile = "\(hiddenArtifactsDirectoryPath)/encryptedPlist"
            return outputFile
        }
        
        static func plistReaderSourceOutputFile(structName: String) -> String {
            let fileManager = FileManager.default
            let hiddenArtifactsDirectoryPath = XcodeSurgery.hiddenArtifactsDirectoryPath(projectDirectoryPath: fileManager.currentDirectoryPath)
            let outputFile = "\(hiddenArtifactsDirectoryPath)/\(structName).swift"
            return outputFile
        }
        
        static var variantPlistReaderOutputFile: String {
            let fileManager = FileManager.default
            let hiddenArtifactsDirectoryPath = XcodeSurgery.hiddenArtifactsDirectoryPath(projectDirectoryPath: fileManager.currentDirectoryPath)
            let outputFile = "\(hiddenArtifactsDirectoryPath)/VariantPlistReader.swift"
            return outputFile
        }
        
        
    }
}
