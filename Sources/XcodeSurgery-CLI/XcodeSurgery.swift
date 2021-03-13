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
}

protocol VerboseCommand {
    var verbose: Bool { get }
}
