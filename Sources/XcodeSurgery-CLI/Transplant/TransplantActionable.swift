import Foundation

protocol TransplantActionable {
    func execute() throws
    var canHandleSdk: Bool { get }
    var pathOfWorkingFolder: String { get }
    var pathOfBaseTargetApp: String { get }
    var pathOfProductApp: String { get }
    
    var transplantCommand: XcodeSurgery.Transplant { get }
}

extension TransplantActionable {
    func cleanFolders() throws {
        print("----- begin cleanFolders")
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: self.pathOfWorkingFolder) {
            try fileManager.removeItem(atPath: self.pathOfWorkingFolder)
        }
    }
    
    func createWorkingFolder() throws {
        print("----- begin createWorkingFolder")
        let fileManager = FileManager.default
        try fileManager.copyItem(atPath: pathOfBaseTargetApp,
                             toPath: pathOfWorkingFolder)
    }
    
    func removeFiles() throws {
        print("----- begin removeFiles")
        let filesToRemove = self.transplantCommand.filesToRemove
        print("filesToRemove: \(filesToRemove)")
        let fileManager = FileManager.default
        try fileManager.removeItem(atPath: "\(self.pathOfWorkingFolder)/Info.plist")
        for fileToRemove in filesToRemove {
            let pathOfFileToRemove = "\(pathOfWorkingFolder)/\(fileToRemove)"
            print("-- attempt to remove : \(pathOfFileToRemove)")
            try fileManager.removeItem(atPath: pathOfFileToRemove)
        }
    }
    
    func copyFilesToWorkingFolder() throws {
        print("----- begin copyFilesToWorkingFolder")
        let filesToInject = self.transplantCommand.filesToInject
        let fileManager = FileManager.default
        try fileManager.copyItem(atPath: "\(self.pathOfProductApp)/Info.plist",
                                 toPath: "\(pathOfWorkingFolder)/Info.plist")
        for fileToInject in filesToInject {
            guard let url = URL(string: fileToInject) else {
                throw NSError(domain: "Invalid file url: \(fileToInject)", code: 0, userInfo: nil)
            }
            let file = url.lastPathComponent
            let destination = "\(pathOfWorkingFolder)/\(file)"
            try fileManager.copyItem(atPath: fileToInject,
                                     toPath: destination)
        }
    }

    func renameBinary() throws {
        print("----- begin renameBinary")
        let baseTargetBinary = "\(self.pathOfWorkingFolder)/\(self.transplantCommand.sourceTarget)"
        let targetBinary = "\(self.pathOfWorkingFolder)/\(self.transplantCommand.destinationTarget)"
        
        let fileManager = FileManager.default
        try fileManager.moveItem(atPath: baseTargetBinary,
                             toPath: targetBinary)
        guard fileManager.fileExists(atPath: targetBinary) else {
            throw NSError(domain: "Error in renaming binary", code: 0, userInfo: nil)
        }
    }
    
    func removeSignature() throws {
        print("----- begin removeSignature")
        let embeddedProvisioning = "\(self.pathOfWorkingFolder)/embedded.mobileprovision"
        let codeSignature = "\(self.pathOfWorkingFolder)/_CodeSignature"
        let pkgInfo = "\(self.pathOfWorkingFolder)/PkgInfo"

        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: embeddedProvisioning) {
            try fileManager.removeItem(atPath: embeddedProvisioning)
        }

        if fileManager.fileExists(atPath: codeSignature) {
            try fileManager.removeItem(atPath: codeSignature)
        }
        if fileManager.fileExists(atPath: pkgInfo) {
            try fileManager.removeItem(atPath: pkgInfo)
        }

        let isProvisioningExists = fileManager.fileExists(atPath: embeddedProvisioning)
        let isSignatureExists = fileManager.fileExists(atPath: codeSignature)
        let isPkgInfoExists = fileManager.fileExists(atPath: pkgInfo)

        if isProvisioningExists || isSignatureExists || isPkgInfoExists {
            throw NSError(domain: "Error in deleting signature", code: 0, userInfo: nil)
        }
    }
    
    func replaceApp() throws {
        print("----- begin replaceApp")
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: self.pathOfProductApp) {
            try fileManager.removeItem(atPath: self.pathOfProductApp)
        }
        try fileManager.moveItem(atPath: self.pathOfWorkingFolder,
                                 toPath: self.pathOfProductApp)
    }
    
    func patchDsym() throws {
        print("----- begin PatchDsym")
        let dsymPatchingAction = DsymPatchingAction(transplantCommand: self.transplantCommand)
        try dsymPatchingAction.executeDsymPatch()
        print("----- end PatchDsym")
    }

    func execute() throws {
        do {
            print("--- Start of \(self) Execution")
            try self.cleanFolders()
            try self.createWorkingFolder()
            try self.removeFiles()
            try self.copyFilesToWorkingFolder()
            try self.renameBinary()
            try self.removeSignature()
            try self.replaceApp()
            try self.patchDsym()
            print("--- End of \(self) Execution")
        }
        catch {
            print("--- Moved failed with error: \(error.localizedDescription)")
        }
    }
}
