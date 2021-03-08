//
//  DsymPatchingAction.swift
//  
//
//  Created by Kenneth Poon on 12/1/21.
//

import Foundation

class DsymPatchingAction {

    let transplantCommand: XcodeSurgery.Transplant
    
    init(transplantCommand: XcodeSurgery.Transplant) {
        self.transplantCommand = transplantCommand
    }
    
    func validateComments() throws {
        XcodeSurgery.log("------- begin validateComments")
        guard let formatArgument = self.transplantCommand.debugInformationFormat else {
            return
        }
        guard let format = DebugInformationFormat(rawValue: formatArgument) else {
            throw NSError(domain: "Invalid Debug Information Format value", code: 0, userInfo: nil)
        }
        guard format == .dwarfWithDsym else {
            XcodeSurgery.log("Skip Patching Dsym for: \(formatArgument)")
            return
        }
        let destinationDsym = "\(self.transplantCommand.targetBuildDirectory)/\(self.transplantCommand.destinationTarget).app.dSYM"
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: destinationDsym) else {
            throw NSError(domain: "Destination dSYM file not available. Did you forget to set `dwarf-with-dsym`", code: 0, userInfo: nil)
        }
    }
    
    func createWorkingDsymFolder() throws {
        XcodeSurgery.log("------- begin createWorkingDsymFolder")
        let sourceDsym = "\(self.transplantCommand.workingDirectory)/\(self.transplantCommand.sourceTarget).app.dSYM"
        let workingDsym = "\(self.transplantCommand.workingDirectory)/\(self.transplantCommand.sourceTarget).app.dSYM_Backup"
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: workingDsym) {
            try fileManager.removeItem(atPath: workingDsym)
        }
        try fileManager.copyItem(atPath: sourceDsym,
                                 toPath: workingDsym)
    }
    
    func deleteCurrentDestinationDwarf() throws {
        XcodeSurgery.log("------- begin deleteCurrentDestinationDwarf")
        let destinationDwarf = "\(self.transplantCommand.targetBuildDirectory)/\(self.transplantCommand.destinationTarget).app.dSYM/Contents/Resources/DWARF/\(self.transplantCommand.destinationTarget)"
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destinationDwarf) {
            try fileManager.removeItem(atPath: destinationDwarf)
        } else {
            throw NSError(domain: "Destination dSYM-DWARF file not available.", code: 0, userInfo: nil)
        }
    }
    
    func replaceDestinationDwarf() throws {
        XcodeSurgery.log("------- begin replaceDestinationDwarf")
        let sourceDwarf = "\(self.transplantCommand.workingDirectory)/\(self.transplantCommand.sourceTarget).app.dSYM_Backup/Contents/Resources/DWARF/\(self.transplantCommand.sourceTarget)"
        let destinationDwarf = "\(self.transplantCommand.targetBuildDirectory)/\(self.transplantCommand.destinationTarget).app.dSYM/Contents/Resources/DWARF/\(self.transplantCommand.destinationTarget)"
        let fileManager = FileManager.default
        try fileManager.copyItem(atPath: sourceDwarf,
                                 toPath: destinationDwarf)
        
        XcodeSurgery.log("------- end replaceDestinationDwarf")
    }
    
    func executeDsymPatch() throws {
        try validateComments()
        try createWorkingDsymFolder()
        try deleteCurrentDestinationDwarf()
        try replaceDestinationDwarf()
    }
}

fileprivate enum DebugInformationFormat: String {
    case stabs
    case dwarf
    case dwarfWithDsym = "dwarf-with-dsym"
}
