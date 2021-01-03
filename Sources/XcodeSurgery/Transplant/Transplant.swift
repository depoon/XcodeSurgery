import ArgumentParser
import Foundation


extension XcodeSurgery {
    enum BuildAction: String {
        case build
        case install
    }
    
    struct Transplant: ParsableCommand {
        @Option(name: [.customShort("a"),
                       .customLong("action")],
                help: "Xcode Action. ${ACTION} eg \"build\", \"install\"",
                transform: { BuildAction(rawValue: $0)})
        var action: BuildAction?
        
        @Option(name: [.customLong("targetBuildDirectory"),
                       .customLong("tbd")],
                help: "Target Build Directory eg.${TARGET_BUILD_DIR}")
        var targetBuildDirectory: String
        
        @Option(name: [.short,
                       .customLong("workingDirectory")],
                help: "Working Directory")
        var workingDirectory: String
        
        @Option(name: [.customLong("sourceTarget"),
                       .customLong("st")],
                help: "Source Target Name")
        var sourceTarget: String
        
        @Option(name: [.customLong("destinationTarget"),
                       .customLong("dt")],
                help: "Destination Target Name eg. ${TARGETNAME}")
        var destinationTarget: String
        
        @Option(name: .customLong("sdkName"), help: "SDK Name eg. ${SDK_NAME}")
        var sdkName: String
        
        @Option(name: .customLong("filesToRemove"), parsing: .upToNextOption, help: "Files to remove (separated by spaces)")
        var filesToRemove: [String] = []
        
        @Option(name: .customLong("filesToInject"), parsing: .upToNextOption, help: "Files to inject (separated by spaces)")
        var filesToInject: [String] = []
        
        func run() throws {
            let actionable = try self.createTransplantActionable()
            try actionable.execute()
        }
        
        func createTransplantActionable() throws -> TransplantActionable {
            guard let action = self.action else {
                throw NSError(domain: "Invalid 'action' argument", code: 0, userInfo: nil)
            }
            switch action {
            case .build:
                return TransplantSimulator(transplantCommand: self)
            case .install:
                return TransplantIphoneosArchive(transplantCommand: self)
            }
        }
    }
}

class TransplantSimulator: TransplantActionable {
    
    let transplantCommand: XcodeSurgery.Transplant
    
    init(transplantCommand: XcodeSurgery.Transplant) {
        self.transplantCommand = transplantCommand
    }

    var canHandleSdk: Bool {
        return self.transplantCommand.sdkName.contains("simulator")
    }
    
    var pathOfWorkingFolder: String {
        return "\(self.transplantCommand.workingDirectory)/\(self.transplantCommand.sourceTarget)_BACKUP.app"
    }
    
    var pathOfBaseTargetApp: String {
        return "\(self.transplantCommand.workingDirectory)/\(self.transplantCommand.sourceTarget).app"
    }
    
    var pathOfProductApp: String {
        return "\(self.transplantCommand.targetBuildDirectory)/\(self.transplantCommand.destinationTarget).app"
    }
}

class TransplantIphoneosArchive: TransplantActionable {
    
    let transplantCommand: XcodeSurgery.Transplant
    
    init(transplantCommand: XcodeSurgery.Transplant) {
        self.transplantCommand = transplantCommand
    }

    var canHandleSdk: Bool {
        if self.transplantCommand.action == .install,
           self.transplantCommand.sdkName.contains("iphoneos") {
            return true
        }
        return false
    }
    
    var pathOfWorkingFolder: String {
        let folder = self.transplantCommand.workingDirectory
        return "\(folder)/\(self.transplantCommand.sourceTarget)_BACKUP.app"
    }
    
    var pathOfBaseTargetApp: String {
        let folder = self.transplantCommand.workingDirectory
        return "\(folder)/\(self.transplantCommand.destinationTarget).app"
    }
    
    var pathOfProductApp: String {
        let folder = self.transplantCommand.targetBuildDirectory
        return "\(folder)/\(self.transplantCommand.destinationTarget).app"
    }
}
