import ArgumentParser

struct XcodeSurgery: ParsableCommand {
  
    static var configuration = CommandConfiguration(subcommands: [
                                                        XcodeSurgery.Transplant.self,
                                                        XcodeSurgery.Prepare.self,
                                                        XcodeSurgery.Keygen.self])
}

func printDebug(_ string: String) {
    #if DEBUG
        print(string)
    #endif
}
