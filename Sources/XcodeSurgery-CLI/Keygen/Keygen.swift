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

    struct KeyGen: ParsableCommand, VerboseCommand {

        @Option(name: [.customLong("outputFile"),
                       .customShort("o")],
                help: "Output file")
        var outputFile: String
        
        @Flag var verbose = false

        private lazy var variantEncryption: VariantEncryption = {
            return VariantEncryption()
        }()

        func run() throws {
            XcodeSurgery.setVerboseMode(self)

            do {
                XcodeSurgery.log("--- Start of Keygen Execution")

                let key = try VariantEncryption().generateRandomEncryptionKey()
                try VariantEncryption.FileManager().saveKeyToFile(key: key, toPath: outputFile)
                
                XcodeSurgery.log("--- End of Keygen Execution")
            }
            catch {
                XcodeSurgery.log("--- Keygen failed with error: \(error.localizedDescription)")
            }
        }
    }
}
