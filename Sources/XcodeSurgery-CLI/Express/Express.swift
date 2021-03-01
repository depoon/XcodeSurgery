//
//  Express.swift
//  
//
//  Created by Kenneth Poon on 28/2/21.
//

import Foundation
import ArgumentParser

extension XcodeSurgery {

    struct Express: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "express",
            abstract: "express commands for applying simplified xcodesurgery",
            subcommands: [XcodeSurgery.Express.ExpressKeyGen.self])
    }
}
