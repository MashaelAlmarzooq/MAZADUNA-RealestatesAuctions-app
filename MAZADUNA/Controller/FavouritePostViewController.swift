//
//  FavouritePostViewController.swift
//  MAZADUNA
//
//  Created by Macintosh HD on 03/11/21.
//

import UIKit

class FavouritePostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var TableView: UITableView!
    
    var posts: [Post] = Array()
    
    //start of UI localization
    
    @IBOutlet weak var myFavoriteAuctions: UILabel!

    //end of UI localization

    override func viewDidLoad() {
        super.viewDidLoad()
        myFavoriteAuctions.text = NSLocalizedString("myFavorite", comment: "")
        TableView.delegate = self
        TableView.dataSource = self
        TableView.backgroundColor =  #colorLiteral(red: 0.8015722632, green: 0.8773888946, blue: 0.8409902453, alpha: 1)
        TableView.tableFooterView = UIView(frame: .zero)
     
        self.getAllPosts()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getAllPosts()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init("PostReload"), object: nil, queue: .main) { (notification) in
            self.getAllPosts()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("PostReload"), object: nil)
    }

    @IBAction func viewMoreButtonPressed(_ sender: UIButton) {
        let tag = sender.tag
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewInfo") as? ViewInfo else { return }
        vc.post = self.posts[tag]
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        let postID = self.posts[sender.tag].postID
        if let index = MZUser.shared.favouritePosts.firstIndex(of: postID) {
            MZUser.shared.favouritePosts.remove(at: index)
            self.posts.remove(at: sender.tag)
        } else {
            MZUser.shared.favouritePosts.append(postID)
        }
        self.TableView.reloadData()
        FirebaseManager.shared.updateFavouritePosts()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.post = self.posts[indexPath.row]
        cell.backgroundColor =  #colorLiteral(red: 0.8015722632, green: 0.8773888946, blue: 0.8409902453, alpha: 1)
        cell.viewMoreButton.tag = indexPath.row
        cell.viewMoreButton.addTarget(self, action: #selector(self.viewMoreButtonPressed(_:)), for: .touchUpInside)
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: #selector(self.likeButtonPressed(_:)), for: .touchUpInside)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // self.performSegue(withIdentifier: "viewDetails", sender: self)
        let tag = indexPath.row
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewInfo") as? ViewInfo else { return }
        vc.post = self.posts[tag]
        self.present(vc, animated: true, completion: nil)
    }
    
    func getAllPosts(_ showLoader: Bool = true) {
        self.posts = AllPosts.shared.posts.filter({MZUser.shared.favouritePosts.contains($0.postID)})
        self.TableView.reloadData()
    }
}



