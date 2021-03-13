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
                try encryption()
                try generatePlistReaderStructSourceCode()
                XcodeSurgery.log("--- End of Express Encrypt Execution")
            }
            catch {
                XcodeSurgery.log("--- Express Encrypt failed with error: \(error.localizedDescription)")
            }
        }
        
        func encryption() throws {
            let variantEncryptionFileManager = VariantEncryption.FileManager()

            let encryptionKey = try variantEncryptionFileManager.readKey(filePath: XcodeSurgery.Express.encryptionKeyFilePath)
            let target = try XcodeSurgery.Encryption.createTargetData(targetFilePath: targetPlist)
            let encryptionResult = try VariantEncryption().encrypt(plainText: target,
                                                                   key: encryptionKey)
            
            try variantEncryptionFileManager.saveIvToFile(iv: encryptionResult.iv,
                                                          toPath: XcodeSurgery.Express.ivOutputFile)

            try variantEncryptionFileManager.saveCipertextToFile(ciphertext: encryptionResult.ciphertext,
                                                                 toPath: XcodeSurgery.Express.encryptedOutputFile)
        }
        
        func generatePlistReaderStructSourceCode() throws {
            let outputFile = XcodeSurgery.Express.plistReaderSourceOutputFile(structName: structName)
            let sourceCodeWriter = SourceCodeWriter()
            let sourceCode = sourceCodeWriter.generatePlistReaderSourceCode(createMode: .express,
                                                                            plistFile: targetPlist,
                                                                            structName: structName)
            let shouldWriteOutputfile = sourceCodeWriter
                                            .shouldWriteOutputfile(outputFile: outputFile,
                                                                   sourceCodeToWrite: sourceCode)
            if shouldWriteOutputfile {
                sourceCodeWriter.writeSourceCode(outputFile: outputFile, sourceCodeToWrite: sourceCode)
            }
        }

    }
}
