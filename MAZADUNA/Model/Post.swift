//
//  Post.swift
//  MAZADUNA
//
//  Created by Tahani Alsubaie on 24/09/21.
//

import UIKit
import FirebaseAuth
import Firebase

class AllPosts {
    static let shared = AllPosts()
    var posts: [Post] = Array()
    var isPageDataAvailable: Bool = true
    
    func getAllPosts() {
        guard self.isPageDataAvailable else { return }
        FirebaseManager.shared.getAllPosts { (posts, error) in
            guard  error == nil else {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(ok)
                return
            }
            self.isPageDataAvailable = posts.count >= (FirebaseManager.shared.postCountsPerPage - 1)
            self.posts.append(contentsOf: posts)
            self.sortPosts()
            self.getExpiredPosts()
            NotificationCenter.default.post(name: NSNotification.Name.init("PostReload"), object: posts)
            if self.isPageDataAvailable {
                self.getAllPosts()
            } else {
                
            }
        }
    }
    
    func addPost(_ post: Post) {
        self.posts.append(post)
    }
    
    func sortPosts() {
        self.posts.sort(by: {$0.endDateValue < $1.endDateValue})
    }
    
    func getExpiredPosts() {
        let currentDate = Date()
        guard let lastDate = Calendar.current.date(byAdding: .day, value: -2, to: currentDate) else { return }
        let expiredPosts = self.posts.filter({$0.endDateValue < lastDate})
        print("ExpiredPosts: \(expiredPosts.compactMap({$0.location}))")
        
        //Delete posts from firebase
        if expiredPosts.count > 0 {
            self.posts.removeAll(where: {$0.endDateValue < lastDate})
            expiredPosts.forEach { post in
                FirebaseManager.shared.deletePost(post.postID, nil)
            }
            
        }
    }
}

class Post: NSObject {
    var userID: String = ""
    var startPrice: String = ""
    var descriptionForEstate: String = ""
    var bidders: [String: String] = ["userID":"price"]
    var postID: String = ""
    var state: String = ""
    var space: String = ""
    var type: String = ""
    var price: String = ""
    var startDate: String = ""
    var endDate: String = ""
    var lat: Double = 0.0
    var long: Double = 0.0
    var location: String = ""
    var image: [String] = Array()
    var createdAt :Double = 0.0
    var nigbh :String = ""
    var json: Dictionary<String, Any> {
        return ["startPrice": self.startPrice,"description":self.descriptionForEstate ,"state": self.state, "space": self.space, "type": self.type, "price": self.price, "startDate": self.startDate, "endDate": self.endDate, "lat": self.lat, "long": self.long, "image": self.image, "location": self.location, "userID": Auth.auth().currentUser!.uid, "postID": FirebaseManager.shared.ref.childByAutoId().key ?? "", "createdAt": ServerValue.timestamp(), "nigbh" : self.nigbh, "bidders": self.bidders]
    }
    var startDateValue: Date = Date()
    var endDateValue: Date = Date()
    
    init(withJson json: Dictionary<String, Any>) {
        self.userID = json["userID"] as? String ?? ""
        self.startPrice = json["startPrice"] as? String ?? ""
        self.descriptionForEstate = json["description"] as? String ?? ""
        self.postID = json["postID"] as? String ?? ""
        self.state = json["state"] as? String ?? ""
        self.space = json["space"] as? String ?? ""
        self.type = json["type"] as? String ?? ""
        self.price = json["price"] as? String ?? ""
        self.startDate = json["startDate"] as? String ?? ""
        self.endDate = json["endDate"] as? String ?? ""
        self.lat = json["lat"] as? Double ?? 0.0
        self.long = json["long"] as? Double ?? 0.0
        self.bidders = json["bidders"] as? [String : String] ?? ["userID":"price"]
        if let image = json["image"] as? String {
            self.image = [image]
        } else {
            self.image = json["image"] as? [String] ?? Array()
        }
        self.location = json["location"] as? String ?? ""
        self.createdAt = json["createdAt"] as? Double ?? 0.0
        self.nigbh = json["nigbh"] as? String ?? ""
        
        self.startDateValue = self.startDate.dateUsingFormate("HH:mm:ss-dd.MM.yyyy")
        self.endDateValue = self.endDate.dateUsingFormate("HH:mm:ss-dd.MM.yyyy")
    }
    
    func setPrice(newPrice: String) -> String{
        price = newPrice
        return price
    }
}
