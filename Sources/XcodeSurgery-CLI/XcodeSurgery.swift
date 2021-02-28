import ArgumentParser

struct XcodeSurgery: ParsableCommand {
  
    static var configuration = CommandConfiguration(subcommands: [
                                                        XcodeSurgery.Express.self,
                                                        XcodeSurgery.Transplant.self,
                                                        XcodeSurgery.Prepare.self,
                                                        XcodeSurgery.KeyGen.self,
                                                        XcodeSurgery.Encryption.self,
                                                        XcodeSurgery.SourceGen.self])
}

extension XcodeSurgery {
    
    static func hiddenDirectoryPath(projectDirectoryPath: String) -> String {
        return "\(projectDirectoryPath)/.xcodesurgery"
    }
}

func printDebug(_ string: String) {
    #if DEBUG
        print(string)
    #endif
}
