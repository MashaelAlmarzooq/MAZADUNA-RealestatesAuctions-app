//
//  MyPostsViewController.swift
//  MAZADUNA
//
//  Created by Macintosh HD on 18/10/21.
//

import UIKit
import MBProgressHUD

class MyPostsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    // start of UI localization
    
    @IBOutlet weak var auctionsLabel: UILabel!
    
    // end of UI localization
    
    var isSeller: Bool = false
    var posts: [Post] = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backButton.addTarget(self, action: #selector(self.backButtonPressed(_:)), for: .touchUpInside)
        TableView.delegate = self
        TableView.dataSource = self
        TableView.backgroundColor =  #colorLiteral(red: 0.8015722632, green: 0.8773888946, blue: 0.8409902453, alpha: 1)
        TableView.tableFooterView = UIView(frame: .zero)
        if self.isSeller == false {
            self.getAllPosts()
        } else {
            self.TableView.reloadData()
        }
        
        auctionsLabel.text = NSLocalizedString("auctions", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.TableView.reloadData()
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
        cell.deletePostButton.isHidden = self.isSeller
        cell.backgroundColor =  #colorLiteral(red: 0.8015722632, green: 0.8773888946, blue: 0.8409902453, alpha: 1)
        cell.viewMoreButton.tag = indexPath.row
        cell.deletePostButton.tag = indexPath.row
        cell.viewMoreButton.addTarget(self, action: #selector(self.viewMoreButtonPressed(_:)), for: .touchUpInside)
        cell.deletePostButton.addTarget(self, action: #selector(self.deletePostPressed(_:)), for: .touchUpInside)
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
        
        self.posts = AllPosts.shared.posts.filter({$0.userID == FirebaseManager.shared.user?.uid ?? ""})
        self.TableView.reloadData()
        /*var hud: MBProgressHUD?
        if showLoader {
            hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud?.label.text = "Loading.."
        }
        
        FirebaseManager.shared.getUserPosts { (posts, error) in
            if hud != nil {
                hud?.hide(animated: true)
            }
            
            guard  error == nil else {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.posts.append(contentsOf: posts)
            self.TableView.reloadData()
        }*/
    }
    
    @IBAction func deletePostPressed(_ sender: UIButton) {
    
        let tag = sender.tag
        let currentDate = Date()
        let startDate = self.posts[tag].startDateValue
        print("Current Date: \(currentDate)")
        print("Start Date: \(startDate)")
        if(currentDate < startDate){
            // you can delete
            let alert = UIAlertController(title: NSLocalizedString("deleteAlert", comment: ""), message: NSLocalizedString("deleteMsg", comment: ""), preferredStyle: .alert)
            let yes = UIAlertAction(title: NSLocalizedString("deleteYes", comment: ""), style: .default) { (action) in
                FirebaseManager.shared.deletePost(self.posts[tag].postID) { (error) in
                    if error != nil {
                        let errorAlert = UIAlertController(title: NSLocalizedString("errorTitle", comment: ""), message: error?.localizedDescription, preferredStyle: .alert)
                        let cancel = UIAlertAction(title: NSLocalizedString("errorAction", comment: ""), style: .cancel, handler: nil)
                        errorAlert.addAction(cancel)
                        self.present(errorAlert, animated: true, completion: nil)
                    } else {
                        AllPosts.shared.posts.removeAll(where: {$0.postID == self.posts[tag].postID})
                        NotificationCenter.default.post(name: NSNotification.Name.init("PostDeleted"), object: self.posts[tag].postID)
                        self.posts.remove(at: tag)
                        self.TableView.reloadData()
                    }
                }
            }
            let no = UIAlertAction(title: NSLocalizedString("deleteNo", comment: ""), style: .cancel, handler: nil)
            alert.addAction(yes)
            alert.addAction(no)
            self.present(alert, animated: true, completion: nil)
            
        }else{
            // you can NOT delete
         
            let alert = UIAlertController(title: NSLocalizedString("errorTitle", comment: ""), message: NSLocalizedString("youCantDelete", comment: ""), preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("errorAction", comment: "") , style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        

    }
}


