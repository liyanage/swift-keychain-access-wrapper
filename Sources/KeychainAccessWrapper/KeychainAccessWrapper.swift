
import Foundation
import Security

public struct KeychainAccessWrapper {

    public static func usernameAndPassword(forKeychainItemLabel keychainItemLabel: String) -> (String, String)? {
        let keychainQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrLabel as String: keychainItemLabel,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]

        var queryOutput: CFTypeRef?
        let status = SecItemCopyMatching(keychainQuery as CFDictionary, &queryOutput)
        guard status == errSecSuccess, let keychainItem = queryOutput else {
            print("Unable to find keychain item labeled '\(keychainItemLabel)', please add it and try again.")
            return nil
        }

        guard keychainItem[kSecAttrAccount] != nil && keychainItem[kSecValueData] != nil else {
            print("Unable to find required information in keychain item labeled '\(keychainItemLabel)'")
            return nil
        }

        guard let username = keychainItem[kSecAttrAccount] as? String else {
            print("Unable to find username property value in keychain item '\(keychainItemLabel)': \(keychainItem)")
            return nil
        }

        guard let passwordData = keychainItem[kSecValueData] as? Data else {
            print("Unable to find password data value in keychain item '\(keychainItemLabel)', or wrong value type")
            return nil
        }

        guard let passwordString = String(data: passwordData, encoding: .utf8) else {
            print("Unable to convert password data value for keychain item '\(keychainItemLabel)' to string")
            return nil
        }
        
        return (username, passwordString)
    }

    public static func httpBasicAuthorizationHeaderValue(forKeychainItemLabel keychainItemLabel: String) -> String? {
        
        guard let (username, password) = usernameAndPassword(forKeychainItemLabel: keychainItemLabel) else {
            return nil
        }
        
        let userPasswordString = "\(username):\(password)"
        guard let userPasswordData = userPasswordString.data(using: .utf8) else {
            print("Unable to convert user+password string to data for keychain item '\(keychainItemLabel)'")
            return nil
        }

        let base64EncodedCredentialData = userPasswordData.base64EncodedData()
        guard let base64EncodedCredentialString = String(data:base64EncodedCredentialData, encoding: .utf8) else {
            print("Unable to convert user+password base64 data to string for keychain item \(keychainItemLabel)")
            return nil
        }

        let authString = "Basic \(base64EncodedCredentialString)"
        return authString
    }

}

