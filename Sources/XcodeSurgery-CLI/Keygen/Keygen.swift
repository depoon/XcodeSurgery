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

    struct KeyGen: ParsableCommand {

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
                
                print("--- End of Keygen Execution")
            }
            catch {
                print("--- Keygen failed with error: \(error.localizedDescription)")
            }
        }
    }
}
