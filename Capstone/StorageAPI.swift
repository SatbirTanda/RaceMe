//
//  StorageAPI.swift
//  Capstone
//
//  Created by Satbir Tanda on 6/30/16.
//  Copyright © 2016 Satbir Tanda. All rights reserved.
//

import Foundation

class StorageAPI {
    
    let TOKEN = "TOKEN"
    
    func saveToken(token: String) {
        KeychainWrapper.setString(token, forKey: TOKEN)
    }
    
    func getToken() -> String? {
        if let token = KeychainWrapper.stringForKey(TOKEN) {
            return token
        }
        return nil
    }
    
    func removeToken() {
        KeychainWrapper.removeObjectForKey(TOKEN)
    }
    
    func getUsername() -> String? {
        if let token = getToken() {
            if let userDataString = JWT.decodeJWT(token) {
                // print("User Data -> \(userDataString)")
                if let userInfo = JWT.convertStringToDictionary(userDataString) {
                    if let userName = userInfo["username"] as? String {
                        return userName
                    }
                }
            }
        }
        return nil
    }
        
}