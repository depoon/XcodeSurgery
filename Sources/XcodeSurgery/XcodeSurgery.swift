import ArgumentParser

struct XcodeSurgery: ParsableCommand {
  
    static var configuration = CommandConfiguration(subcommands: [
                                                        XcodeSurgery.Transplant.self,
                                                        XcodeSurgery.Prepare.self])
}

