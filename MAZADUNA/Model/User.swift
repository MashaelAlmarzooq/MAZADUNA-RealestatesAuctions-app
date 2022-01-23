//
//  File.swift
//  MAZADUNA
//
//  Created by Macintosh HD on 01/11/21.
//

import Foundation

class MZUser {
    static var shared: MZUser = MZUser()
    var userID: String = ""
    var email: String = ""
    var phoneNumber: String = ""
    var favouritePosts: [String] = Array()
    
    convenience init(with json: [String: Any]?) {
        self.init()
        guard let user = json else { return }
        self.userID = user["userID"] as? String ?? ""
        self.email = user["email"] as? String ?? ""
        self.phoneNumber = user["number"] as? String ?? ""
        self.favouritePosts = user["favouritePosts"] as? Array<String> ?? Array()
    }
    
    func getJson() -> [String: Any] {
        var user = Dictionary<String, Any>()
        user["userID"] = self.userID
        user["email"] = self.email
        user["number"] = self.phoneNumber
        user["favouritePosts"] = self.favouritePosts
        return user
    }
}
