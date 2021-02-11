//
//  Keygen.swift
//  
//
//  Created by Kenneth Poon on 5/2/21.
//

import Foundation
import ArgumentParser
import VariantEncryption

extension XcodeSurgery {

    struct Keygen: ParsableCommand {

        @Option(name: [.customLong("outputFile"),
                       .customShort("o")],
                help: "Output file")
        var outputFile: String

        private lazy var variantEncryption: VariantEncryption = {
            return VariantEncryption()
        }()

        func run() throws {
            let url = URL(fileURLWithPath: outputFile)
            print("url: \(url)")

            do {
                print("--- Start of Keygen Execution")

                let key = try VariantEncryption().generateRandomEncryptionKey()
                try VariantEncryption.FileManager().saveKeyToFile(key: key, toPath: outputFile)
                
//                let readKey = try VariantEncryption.FileManager().readKey(filePath: outputFile)
//                try encryptionTest(encryptionKey: key, decryptionKey: readKey)
                print("--- End of Keygen Execution")
            }
            catch {
                print("--- Keygen failed with error: \(error.localizedDescription)")
            }
        }
    }
}
/*
extension XcodeSurgery.Keygen {
    
    private func encryptionTest(encryptionKey: EncryptionKey,
                        decryptionKey: EncryptionKey) throws {
        let plainText = "heello world"
        let plainTextData: Data! = plainText.data(using: .utf8)

        let variantEncryption = VariantEncryption()
        let encryptionResult = try variantEncryption.encrypt(plainText: plainTextData,
                                                             key: encryptionKey)
        let decryptedData = try variantEncryption.decrypt(result: encryptionResult,
                                                          key: decryptionKey)
        let decryptedText = String(data: decryptedData, encoding: .utf8)!
        print("decryptedText: \(decryptedText)")
    }
}
*/
