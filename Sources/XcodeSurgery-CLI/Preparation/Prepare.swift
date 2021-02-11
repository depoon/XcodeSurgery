//
//  Prepare.swift
//  
//
//  Created by Kenneth Poon on 23/12/20.
//

import Foundation
import ArgumentParser

extension XcodeSurgery {
    
    struct Prepare: ParsableCommand {
        
        @Option(name: [.customLong("targetBuildDirectory"),
                       .customLong("tbd")],
                help: "Target Build Directory eg.${TARGET_BUILD_DIR}")
        var targetBuildDirectory: String
        
        @Option(name: [.short,
                       .customLong("workingDirectory")],
                help: "Working Directory")
        var workingDirectory: String
        
        @Option(name: [.customLong("targetName"),
                       .customShort("t")],
                help: "Destination Target Name eg. ${TARGETNAME}")
        var targetName: String
        
        func run() throws {
            try clearDirectory()
            try createDirectory()
            try copyAppToWorkingDirectory()
            try copyDsymToWorkingDirectory()

        }
        
        func clearDirectory() throws {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: self.workingDirectory) {
                try fileManager.removeItem(atPath: self.workingDirectory)
            }
        }
        
        func createDirectory() throws {
            try FileManager.default.createDirectory(atPath: self.workingDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        
        func copyAppToWorkingDirectory() throws {
            let source = "\(self.targetBuildDirectory)/\(targetName).app"
            let destination = "\(self.workingDirectory)/\(targetName).app"
            
            let fileManager = FileManager.default
            try fileManager.copyItem(atPath: source,
                                     toPath: destination)
        }
        
        func copyDsymToWorkingDirectory() throws {
            let fileManager = FileManager.default
            let sourceDsym = "\(self.targetBuildDirectory)/\(targetName).app.dSYM"
            let destinationDsym = "\(self.workingDirectory)/\(targetName).app.dSYM"
            if fileManager.fileExists(atPath: sourceDsym) {
                try fileManager.copyItem(atPath: sourceDsym,
                                         toPath: destinationDsym)
            } else {
                printDebug("No Dsym to copy")
            }
        }
    }
}
