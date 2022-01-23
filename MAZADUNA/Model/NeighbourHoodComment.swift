//
//  NeighbourHoodComment.swift
//  MAZADUNA
//
//  Created by Macintosh HD on 03/12/21.
//

import Foundation
import FirebaseDatabase
import FirebaseCore

class NeighbourHoodComment {
    var userID: String = ""
    var email: String = ""
    var phoneNumber: String = ""
    var commentID: String = ""
    var comment: String = ""
    var commentDate: Double = 0.0
    var neighbourHood: String = ""
    var date: String = ""
    
    convenience init(with json: [String: Any]?) {
        self.init()
        guard let commentData = json else { return }
        self.userID = commentData["userID"] as? String ?? ""
        self.email = commentData["email"] as? String ?? ""
        self.phoneNumber = commentData["number"] as? String ?? ""
        self.commentID = commentData["commentID"] as? String ?? ""
        self.comment = commentData["comment"] as? String ?? ""
        self.commentDate = commentData["commentDate"] as? Double ?? 0.0
        self.neighbourHood = commentData["neighbourHood"] as? String ?? ""
        self.date = self.commentDate.getDateString("dd.MM.yyyy")
    }
    
    func getJson() -> [String: Any] {
        var user = Dictionary<String, Any>()
        user["userID"] = self.userID
        user["email"] = self.email
        user["number"] = self.phoneNumber
        user["commentID"] = self.commentID
        user["comment"] = self.comment
        user["commentDate"] = self.commentDate
        user["neighbourHood"] = self.neighbourHood
        return user
    }
    
    func addToFirebase() {
        self.userID = MZUser.shared.userID
        self.email = MZUser.shared.email
        self.phoneNumber = MZUser.shared.phoneNumber
        self.commentID = FirebaseManager.shared.ref.childByAutoId().key ?? ""
        self.commentDate = Date().timeIntervalSince1970
        self.date = self.commentDate.getDateString("dd.MM.yyyy")
        FirebaseManager.shared.addCommentToFirebase(self.getJson()) { response, error in
            guard let response = response else {
                print("Comment Add Error: \(error?.localizedDescription)")
                return
            }
            print("Added Comment: \(response)")
        }
    }
    
    func deleteComment() {
        FirebaseManager.shared.deleteComment(self.commentID, self.neighbourHood) { error in
            if error == nil {
                print("Comment deleted successfully..")
            }
        }
    }
}
