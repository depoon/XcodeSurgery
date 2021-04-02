//
//  Password.swift
//  
//
//  Created by Kenneth Poon on 27/3/21.
//

import Foundation

public struct Password {
    public let password: String
    public let salt: String
    
    public init(password: String, salt: String) {
        self.password = password
        self.salt = salt
    }
    
    public static func generateRandomPassword() -> Password {
        let passwordString = Password.generateRandomPasswordString()
        let saltString = Password.generateRandomPasswordSaltString()
        return Password(password: passwordString,
                 salt: saltString)
    }
}

private extension Password {
    
    private static func generateRandomString(of length: Int) -> String {
        var key = ""
        for _ in 0 ..< length {
            key.append(Password.characters.randomElement()!)
        }
        return key
    }
    
    private static var characters: String {
        return "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    }
    
    private static func generateRandomPasswordString() -> String {
        let passwordString = Password.generateRandomString(of: 1000)
        return passwordString
    }
    
    private static func generateRandomPasswordSaltString() -> String {
        let passwordSaltString = Password.generateRandomString(of: 100)
        return passwordSaltString
    }
}
