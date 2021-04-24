//
//  Encryption.swift
//  
//
//  Created by Kenneth Poon on 11/2/21.
//

import Foundation
import ArgumentParser
import VariantEncryption

extension XcodeSurgery {

    struct Encryption: ParsableCommand {

        @Option(name: [.customLong("keyFile"),
                       .customShort("k")],
                help: "Key file path")
        var keyFile: String

        @Option(name: [.customLong("targetFile"),
                       .customShort("t")],
                help: "Target input file path")
        var targetFile: String

        @Option(name: [.customLong("ivOutputFile"),
                       .customShort("i")],
                help: "IV output file path")
        var ivOutputFile: String

        @Option(name: [.customLong("encryptedOutputFile"),
                       .customShort("o")],
                help: "Encrypted output file path")
        var encryptedOutputFile: String

        private lazy var variantEncryption: VariantEncryption = {
            return VariantEncryption()
        }()

        func run() throws {
            do {
                XcodeSurgery.log("--- Start of Encryption Execution")

                let variantEncryptionFileManager = VariantEncryption.FileManager()

                let encryptionKey = try variantEncryptionFileManager.readKey(filePath: keyFile)
                let target = try XcodeSurgery.createTargetData(targetFilePath: targetFile)
                let encryptionResult = try VariantEncryption().encrypt(plainText: target,
                                                                       key: encryptionKey)
                try variantEncryptionFileManager.saveIvToFile(iv: encryptionResult.iv,
                                                          toPath: ivOutputFile)

                try variantEncryptionFileManager.saveCipertextToFile(ciphertext: encryptionResult.ciphertext,
                                                                     toPath: encryptedOutputFile)
                XcodeSurgery.log("--- End of Encryption Execution")
            }
            catch {
                XcodeSurgery.log("--- Keygen failed with error: \(error.localizedDescription)")
            }
        }        
    }
}
