//
//  FirebaseManager.swift
//  MAZADUNA
//
//  Created by Tahani Alsubaie on 24/09/21.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore

class FirebaseManager: NSObject {
    static let shared: FirebaseManager = FirebaseManager()
    
    var user: User? {
        return Auth.auth().currentUser
    }
    
    var isAnonymouse: Bool {
        return Auth.auth().currentUser?.isAnonymous ?? false
    }
    
    var ref: DatabaseReference {
        let auth = Auth.auth()
        let db = Database.database()
        let tempRef = db.reference()
        return tempRef
    }
    var timestamp : Double = 0.0
    let postCountsPerPage: UInt = 50
    var verificationID = ""
    // Get a non-default Cloud Storage bucket
    let storage = Storage.storage(url:"gs://mazaduna.appspot.com/")
    
    func getStarted(block:AuthResultCallback?) {
        Auth.auth().signInAnonymously { (user_, error) in
            DispatchQueue.main.async(execute: {
                if let err = error {
                    block?(nil,err)
                }else if let usr = user_ {
                    block?(usr.user,nil)
                }
            })
        }
    }
    
    func updateEmail(_ email: String, _ clouser:((Error?)->Void)?) {
        let currentUser = Auth.auth().currentUser
        currentUser?.updateEmail(to: email) { error in
           if let error = error {
                print(error)
           } else {
                print("CHANGED")
                UserDefaults.standard.setValue(email, forKey: "Email")
           }
            clouser?(error)
        }
    }
    
    func savePhoneNumberOnFireStore(_ number: String, _ completion: ((Bool) -> Void)?) {
        let db = Firestore.firestore()
        db.collection("phonenumbers").whereField("phonenumber", isEqualTo: number)
            .getDocuments() { (querySnapshot, err) in
                DispatchQueue.main.async {
                    if let err = err {
                        return
                    } else {
                        guard querySnapshot?.documents.count == 0 else {
                            completion?(true)
                            return
                        }
                        let db = Firestore.firestore()
                        db.collection("phonenumbers").addDocument(data: ["phonenumber":number, "uid": Auth.auth().currentUser?.uid ?? "N/A"]){ (error) in
                            if error != nil {
                                
                            }
                        }
                        completion?(false)
                    }
                }
            }
    }
    
    func uploadImageToFireStore(_ image: UIImage, _ clouser:((String?, Error?)->Void)?) {
        // Data in memory
        guard let data = image.jpegData(compressionQuality: 1) else { return }
        let storageRef = self.storage.reference()
        // Create a reference to the file you want to upload
        let folderRef = storageRef.child("images/\(UUID().uuidString).jpg")
        
        // Upload the file to the path "images/rivers.jpg"
        _ = folderRef.putData(data, metadata: nil) { (metadata, error) in
            DispatchQueue.main.async {
                guard metadata != nil else {
                    // Uh-oh, an error occurred!
                    clouser?(nil, error)
                    return
                }
                // You can also access to download URL after upload.
                folderRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                      // Uh-oh, an error occurred!
                        clouser?(nil, error)
                      return
                    }
                    clouser?(downloadURL.absoluteString, nil)
                }
            }
        }
    }
    
    func addPostToFirebase(_ data: [String: Any], _ clouser:((Dictionary<String,Any>?, Error?)->Void)?) {
        let postID = data["postID"] as? String ?? self.ref.childByAutoId().key ?? ""
        self.ref.child("posts").child(postID).setValue(data) { (error, ref) in
            DispatchQueue.main.async {
                clouser?(nil, error)
            }
        }
    }
    
    func getAllPosts(_ clouser:(([Post], Error?)->Void)?) {
        var query = DatabaseQuery()
        if self.timestamp == 0.0 {
            query = self.ref.child("posts").queryOrderedByKey().queryLimited(toLast: self.postCountsPerPage)
        } else {
            query = self.ref.child("posts").queryOrdered(byChild: "createdAt").queryEnding(atValue: self.timestamp).queryLimited(toLast: self.postCountsPerPage)
        }
        query.observeSingleEvent(of: .value) { (snapshot) in
            DispatchQueue.main.async {
                guard let value = snapshot.value as? Dictionary<String, Any> else {
                    clouser?([Post](), nil)
                    return
                }
                var modelPosts = Array<Post>()
                if let posts = Array(value.values) as? Array<Dictionary<String,Any>> {
                    posts.forEach { (post) in
                        modelPosts.append(Post(withJson: post))
                    }
                    modelPosts.sort(by: {$0.createdAt > $1.createdAt})
                    let isFirstTime = self.timestamp == 0.0
                    self.timestamp = modelPosts.last?.createdAt ?? 0.0
                    if !isFirstTime {
                        modelPosts.remove(at: 0)
                    }
                }
                clouser?(modelPosts, nil)
            }
        } withCancel: { (error) in
            clouser?([Post](), error)
        }

        /*query.getData { (error, snapshot) in
            DispatchQueue.main.async {
                guard let value = snapshot.value as? Dictionary<String, Any> else {
                    clouser?([Post](), error)
                    return
                }
                var modelPosts = Array<Post>()
                if let posts = Array(value.values) as? Array<Dictionary<String,Any>> {
                    posts.forEach { (post) in
                        modelPosts.append(Post(withJson: post))
                    }
                    modelPosts.sort(by: {$0.createdAt > $1.createdAt})
                    let isFirstTime = self.timestamp == 0.0
                    self.timestamp = modelPosts.last?.createdAt ?? 0.0
                    if !isFirstTime {
                        modelPosts.remove(at: 0)
                    }
                }
                clouser?(modelPosts, error)
            }
        }*/
    }
    
    func getUserPosts(_ userID: String? = nil, _ clouser:(([Post], Error?)->Void)?) {
        var query = DatabaseQuery()
        let id = userID != nil ? userID : Auth.auth().currentUser?.uid ?? ""
        query = self.ref.child("posts").queryOrdered(byChild: "userID").queryEqual(toValue: id)
        query.observeSingleEvent(of: .value) { (snapshot) in
            DispatchQueue.main.async {
                guard let value = snapshot.value as? Dictionary<String, Any> else {
                    clouser?([Post](), nil)
                    return
                }
                var modelPosts = Array<Post>()
                if let posts = Array(value.values) as? Array<Dictionary<String,Any>> {
                    posts.forEach { (post) in
                        modelPosts.append(Post(withJson: post))
                    }
                    modelPosts.sort(by: {$0.createdAt > $1.createdAt})
                }
                clouser?(modelPosts, nil)
            }
        } withCancel: { (error) in
            clouser?([Post](), error)
        }
    }
    
    func getSerchedPosts(_ text: String, _ clouser:(([Post], Error?)->Void)?) {
        var gotOneResult = false
        var allPosts = Array<Post>()
        var query1 = DatabaseQuery()
        query1 = self.ref.child("posts").queryOrdered(byChild: "state").queryStarting(atValue: text).queryEnding(atValue: "\(String(describing: text))\\uf8ff")
        query1.observeSingleEvent(of: .value) { (snapshot) in
            DispatchQueue.main.async {
                guard let value = snapshot.value as? Dictionary<String, Any> else {
                    if gotOneResult == true {
                        clouser?(allPosts, nil)
                    } else {
                        gotOneResult = true
                    }
                    return
                }
                var modelPosts = Array<Post>()
                if let posts = Array(value.values) as? Array<Dictionary<String,Any>> {
                    posts.forEach { (post) in
                        modelPosts.append(Post(withJson: post))
                    }
                    modelPosts.sort(by: {$0.createdAt > $1.createdAt})
                }
                modelPosts.forEach { (post) in
                    if !allPosts.contains(where: {$0.postID == post.postID}) {
                        allPosts.append(post)
                    }
                }
                if gotOneResult == true {
                    clouser?(allPosts, nil)
                } else {
                    gotOneResult = true
                }
                
            }
        } withCancel: { (error) in
            if gotOneResult == true {
                clouser?(allPosts, nil)
            } else {
                gotOneResult = true
            }
        }
        
        var query2 = DatabaseQuery()
        query2 = self.ref.child("posts").queryOrdered(byChild: "type").queryStarting(atValue: text).queryEnding(atValue: "\(String(describing: text))\\uf8ff")
        query2.observeSingleEvent(of: .value) { (snapshot) in
            DispatchQueue.main.async {
                guard let value = snapshot.value as? Dictionary<String, Any> else {
                    if gotOneResult == true {
                        clouser?(allPosts, nil)
                    } else {
                        gotOneResult = true
                    }
                    return
                }
                var modelPosts = Array<Post>()
                if let posts = Array(value.values) as? Array<Dictionary<String,Any>> {
                    posts.forEach { (post) in
                        modelPosts.append(Post(withJson: post))
                    }
                    modelPosts.sort(by: {$0.createdAt > $1.createdAt})
                }
                modelPosts.forEach { (post) in
                    if !allPosts.contains(where: {$0.postID == post.postID}) {
                        allPosts.append(post)
                    }
                }
                if gotOneResult == true {
                    clouser?(allPosts, nil)
                } else {
                    gotOneResult = true
                }
            }
        } withCancel: { (error) in
            if gotOneResult == true {
                clouser?(allPosts, nil)
            } else {
                gotOneResult = true
            }
        }
        var query3 = DatabaseQuery()
        query3 = self.ref.child("posts").queryOrdered(byChild: "location").queryStarting(atValue: text).queryEnding(atValue: "\(String(describing: text))\\uf8ff")
        query3.observeSingleEvent(of: .value) { (snapshot) in
            DispatchQueue.main.async {
                guard let value = snapshot.value as? Dictionary<String, Any> else {
                    if gotOneResult == true {
                        clouser?(allPosts, nil)
                    } else {
                        gotOneResult = true
                    }
                    return
                }
                var modelPosts = Array<Post>()
                if let posts = Array(value.values) as? Array<Dictionary<String,Any>> {
                    posts.forEach { (post) in
                        modelPosts.append(Post(withJson: post))
                    }
                    modelPosts.sort(by: {$0.createdAt > $1.createdAt})
                }
                modelPosts.forEach { (post) in
                    if !allPosts.contains(where: {$0.postID == post.postID}) {
                        allPosts.append(post)
                    }
                }
                if gotOneResult == true {
                    clouser?(allPosts, nil)
                } else {
                    gotOneResult = true
                }
                
            }
        } withCancel: { (error) in
            if gotOneResult == true {
                clouser?(allPosts, nil)
            } else {
                gotOneResult = true
            }
        }
        var query4 = DatabaseQuery()
        query4 = self.ref.child("posts").queryOrdered(byChild: "nigbh").queryStarting(atValue: text).queryEnding(atValue: "\(String(describing: text))\\uf8ff")
        query4.observeSingleEvent(of: .value) { (snapshot) in
            DispatchQueue.main.async {
                guard let value = snapshot.value as? Dictionary<String, Any> else {
                    if gotOneResult == true {
                        clouser?(allPosts, nil)
                    } else {
                        gotOneResult = true
                    }
                    return
                }
                var modelPosts = Array<Post>()
                if let posts = Array(value.values) as? Array<Dictionary<String,Any>> {
                    posts.forEach { (post) in
                        modelPosts.append(Post(withJson: post))
                    }
                    modelPosts.sort(by: {$0.createdAt > $1.createdAt})
                }
                modelPosts.forEach { (post) in
                    if !allPosts.contains(where: {$0.postID == post.postID}) {
                        allPosts.append(post)
                    }
                }
                if gotOneResult == true {
                    clouser?(allPosts, nil)
                } else {
                    gotOneResult = true
                }
                
            }
        } withCancel: { (error) in
            if gotOneResult == true {
                clouser?(allPosts, nil)
            } else {
                gotOneResult = true
            }
        }
        var query5 = DatabaseQuery()
        query5 = self.ref.child("posts").queryOrdered(byChild: "description:").queryStarting(atValue: text).queryEnding(atValue: "\(String(describing: text))\\uf8ff")
        query5.observeSingleEvent(of: .value) { (snapshot) in
            DispatchQueue.main.async {
                guard let value = snapshot.value as? Dictionary<String, Any> else {
                    if gotOneResult == true {
                        clouser?(allPosts, nil)
                    } else {
                        gotOneResult = true
                    }
                    return
                }
                var modelPosts = Array<Post>()
                if let posts = Array(value.values) as? Array<Dictionary<String,Any>> {
                    posts.forEach { (post) in
                        modelPosts.append(Post(withJson: post))
                    }
                    modelPosts.sort(by: {$0.createdAt > $1.createdAt})
                }
                modelPosts.forEach { (post) in
                    if !allPosts.contains(where: {$0.postID == post.postID}) {
                        allPosts.append(post)
                    }
                }
                if gotOneResult == true {
                    clouser?(allPosts, nil)
                } else {
                    gotOneResult = true
                }
                
            }
        } withCancel: { (error) in
            if gotOneResult == true {
                clouser?(allPosts, nil)
            } else {
                gotOneResult = true
            }
        }
    }
    
    func deletePost(_ postID: String, _ clouser:((Error?)->Void)?) {
        self.ref.child("posts").child(postID).removeValue { (error, refrance) in
            DispatchQueue.main.async {
                clouser?(error)
            }
        }
    }
    
    func resetClass() {
        FirebaseManager.shared.timestamp = 0.0
    }
    
    //Neighbourhood Comments
    func addCommentToFirebase(_ data: [String: Any], _ clouser:((Dictionary<String,Any>?, Error?)->Void)?) {
        let neighbourHood = data["neighbourHood"] as? String ?? ""
        let commentID = data["commentID"] as? String ?? self.ref.childByAutoId().key ?? ""
        self.ref.child("NeighbourhoodComments").child(neighbourHood).child(commentID).setValue(data) { (error, ref) in
            DispatchQueue.main.async {
                clouser?(nil, error)
            }
        }
    }
    
    func deleteComment(_ commentID: String, _ neighbour: String, _ clouser:((Error?)->Void)?) {
        self.ref.child("NeighbourhoodComments").child(neighbour).child(commentID).removeValue { (error, refrance) in
            DispatchQueue.main.async {
                clouser?(error)
            }
        }
    }
    
    func loadComments(neighbour: String, _ clouser:(([NeighbourHoodComment], Error?)->Void)?) {
        let query = self.ref.child("NeighbourhoodComments").child(neighbour)
        query.observeSingleEvent(of: .value) { (snapshot) in
            DispatchQueue.main.async {
                guard let value = snapshot.value as? Dictionary<String, Any> else {
                    clouser?([NeighbourHoodComment](), nil)
                    return
                }
                var modelComments = Array<NeighbourHoodComment>()
                if let comments = Array(value.values) as? Array<Dictionary<String,Any>> {
                    comments.forEach { (comment) in
                        modelComments.append(NeighbourHoodComment(with: comment))
                    }
                    modelComments.sort(by: {$0.commentDate > $1.commentDate})
                }
                clouser?(modelComments, nil)
            }
        } withCancel: { (error) in
            clouser?([NeighbourHoodComment](), error)
        }
    }
}

extension FirebaseManager {
    func getUser(_ completionHandler: (() -> Void)?) {
        self.ref.child("users").child(self.user?.uid ?? "").getData { (error, snapshot) in
            DispatchQueue.main.async {
                let value = snapshot.value as? Dictionary<String, Any>
                MZUser.shared = MZUser.init(with: value)
                let email = UserDefaults.standard.value(forKey: "Email") as? String ?? ""
                let phone = UserDefaults.standard.value(forKey: "PhoneNumber") as? String ?? ""
                MZUser.shared.email = email
                MZUser.shared.phoneNumber = phone
                MZUser.shared.userID = self.user?.uid ?? ""
                self.updateUser(MZUser.shared.userID)
                completionHandler?()
            }
        }
    }
    
    func getUser(_ userID: String, _ completionHandler: ((MZUser?) -> Void)?) {
        self.ref.child("users").child(userID).getData { (error, snapshot) in
            DispatchQueue.main.async {
                guard let value = snapshot.value as? Dictionary<String, Any> else {
                    completionHandler?(nil)
                    return
                }
                let user = MZUser.init(with: value)
                completionHandler?(user)
            }
        }
    }
    
    func updateFavouritePosts() {
        self.ref.child("users").child(self.user?.uid ?? "").child("favouritePosts").setValue(MZUser.shared.favouritePosts)
    }
    
    func updateUser(_ userID: String) {
        self.ref.child("users").child(userID).updateChildValues(MZUser.shared.getJson())
    }
}
