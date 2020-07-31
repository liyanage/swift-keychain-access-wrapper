//
//  File.swift
//  
//
//  Created by Marc Liyanage on 7/30/20.
//

import Foundation
import KeychainAccessWrapper

guard CommandLine.arguments.count > 1 else {
    print("Usage: \(CommandLine.arguments[0]) <keychain item label>")
    exit(1)
}

let label = CommandLine.arguments[1]

print("Hello \(label)")

guard let (username, password) = KeychainAccessWrapper.usernameAndPassword(forKeychainItemLabel: label) else {
    print("Unable to find keychain item with label '\(label)'")
    exit(1)
}

print("\(username) \(password)")
