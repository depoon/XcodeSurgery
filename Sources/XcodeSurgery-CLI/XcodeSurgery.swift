import ArgumentParser
import Foundation

struct XcodeSurgery: ParsableCommand {
  
    static var configuration = CommandConfiguration(subcommands: [
                                                        XcodeSurgery.Express.self,
                                                        XcodeSurgery.Transplant.self,
                                                        XcodeSurgery.Prepare.self,
                                                        XcodeSurgery.KeyGen.self,
                                                        XcodeSurgery.Encryption.self,
                                                        XcodeSurgery.SourceGen.self])
    
    class Logger {
        enum LogMode {
            case verbose, off
        }
        static let shared = Logger()
        
        var logMode: LogMode = .off
        
        private init() {}
        
        func log(string: String) {
            switch logMode {
            case .verbose:
                print(string)
            case .off:
                return
            }
        }
    }
    
    static func setVerboseMode(_ command: VerboseCommand) {
        if command.verbose {
            XcodeSurgery.Logger.shared.logMode = .verbose
        } else {
            XcodeSurgery.Logger.shared.logMode = .off
        }
    }
    
    static func log(_ string: String) {
        XcodeSurgery.Logger.shared.log(string: string)
    }
}

extension XcodeSurgery {
    
    static func hiddenDirectoryPath(projectDirectoryPath: String) -> String {
        return "\(projectDirectoryPath)/.xcodesurgery"
    }
    
    static func hiddenArtifactsDirectoryPath(projectDirectoryPath: String) -> String {
        return "\(XcodeSurgery.hiddenDirectoryPath(projectDirectoryPath: projectDirectoryPath))/artifacts"
    }

    static func hiddenSecretsDirectoryPath(projectDirectoryPath: String) -> String {
        return "\(XcodeSurgery.hiddenDirectoryPath(projectDirectoryPath: projectDirectoryPath))/secrets"
    }
    
    static func checkIfXcodeprojExistsInCurrentDirectory() throws {
        let fileManager = FileManager.default
        let subpaths = try fileManager.subpathsOfDirectory(atPath: fileManager.currentDirectoryPath)
        let filtered = subpaths.filter {
            $0.hasSuffix(".xcodeproj") && !$0.contains("/")
        }
        if filtered.count == 0 {
            throw NSError(domain: "Unable to locate '*.xcodeproj' in current directory", code: 0, userInfo: nil)
        }
    }
    
    static func checkIfXcodeSurgeryExistsInCurrentDirectory() throws {
        let fileManager = FileManager.default
        
        let hiddenDirectoryPath = XcodeSurgery.hiddenDirectoryPath(projectDirectoryPath: fileManager.currentDirectoryPath)
        var isDir:ObjCBool = true
        
        if !fileManager.fileExists(atPath: hiddenDirectoryPath, isDirectory: &isDir) {
            throw NSError(domain: "Unable to locate '.xcodesurgery' folder in current directory", code: 0, userInfo: nil)
        }
    }
    
    static func createXcodeSurgeryHiddenDirectoryIfNeeded() throws {
        let fileManager = FileManager.default
        let artifactsDirectoryPath = XcodeSurgery.hiddenDirectoryPath(projectDirectoryPath: fileManager.currentDirectoryPath)

        var isDir:ObjCBool = true
        
        if !fileManager.fileExists(atPath: artifactsDirectoryPath, isDirectory: &isDir) {

            let directoryURL = URL(fileURLWithPath: artifactsDirectoryPath)
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
    }
    
    static func createArtifactsDirectoryIfNeeded() throws {
        let fileManager = FileManager.default
        let hiddenArtifactsDirectoryPath = XcodeSurgery.hiddenArtifactsDirectoryPath(projectDirectoryPath: fileManager.currentDirectoryPath)
        try XcodeSurgery.createDirectoryIfNeeded(directoryPath: hiddenArtifactsDirectoryPath)
    }
    
    static func createSecretsDirectoryIfNeeded() throws {
        let fileManager = FileManager.default
        let hiddenSecretsDirectoryPath = XcodeSurgery.hiddenSecretsDirectoryPath(projectDirectoryPath: fileManager.currentDirectoryPath)
        try XcodeSurgery.createDirectoryIfNeeded(directoryPath: hiddenSecretsDirectoryPath)
    }

    
    static func createDirectoryIfNeeded(directoryPath: String) throws {
        var isDir:ObjCBool = true
        
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: directoryPath, isDirectory: &isDir) {
            let directoryURL = URL(fileURLWithPath: directoryPath)
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
    }
    
    static func createTargetData(targetFilePath: String) throws -> Data {
        let targetURL = URL(fileURLWithPath: targetFilePath)
        let target = try Data(contentsOf: targetURL)
        return target
    }
}

protocol VerboseCommand {
    var verbose: Bool { get }
}
