//
//  SourceGen.swift
//  
//
//  Created by Kenneth Poon on 11/2/21.
//

import Foundation
import ArgumentParser

extension XcodeSurgery {

    struct SourceGen: ParsableCommand {

        @Option(name: [.customLong("plistFile"),
                       .customShort("p")],
                help: "plistFile file")
        var plistFile: String

        @Option(name: [.customLong("outputFile"),
                       .customShort("o")],
                help: "Output file")
        var outputFile: String

        @Option(name: [.customLong("structName"),
                       .customShort("n")],
                help: "Name of struct to access variant values")
        var structName: String

        func run() throws {
            let sourceCodeWriter = SourceCodeWriter()
            let sourceCode = sourceCodeWriter.generatePlistReaderSourceCode(plistFile: plistFile,
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
