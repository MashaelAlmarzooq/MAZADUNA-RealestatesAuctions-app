//
//  ViewController.swift
//  MAZADUNA
//
//  Created by Meshael Hamad on 06/02/1443 AH.
//

import UIKit
import MBProgressHUD
import Firebase
import UserNotifications
import FirebaseDatabase

class homeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var changeLanguageBtn: UIButton!
    @IBOutlet weak var PostButton: UIButton!
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var logOut: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    let center = UNUserNotificationCenter.current()
    var name = ""
    
    var posts: [Post] {
        var posts = AllPosts.shared.posts
        posts.removeAll(where: {$0.userID == MZUser.shared.userID})
        return posts
    }
    var searchedPosts: [Post] = Array()
    var isPageDataAvailable: Bool = true
    var isSearch: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        center.requestAuthorization(options: [.alert,.sound]) { granted, error in}
        self.settingButton.addTarget(self, action: #selector(self.settingButtonPressed(_:)), for: .touchUpInside)
        PostButton.layer.cornerRadius = 50
        TableView.delegate = self
        TableView.dataSource = self
        TableView.backgroundColor =  #colorLiteral(red: 0.8015722632, green: 0.8773888946, blue: 0.8409902453, alpha: 1)
        TableView.tableFooterView = UIView(frame: .zero)
        AllPosts.shared.getAllPosts()
//        self.getAllPosts()
        
        if FirebaseManager.shared.isAnonymouse {
            logOut.isHidden = true
        } else {
            FirebaseManager.shared.getUser {
                self.TableView.reloadData()
            }
        }
        
        self.searchBar.showsCancelButton = false
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        self.searchBar.delegate = self
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init("PostDeleted"), object: nil, queue: .main) { (notification) in
            if let id = notification.object as? String {
//                self.posts.removeAll(where: {$0.postID == id})
                self.searchedPosts.removeAll(where: {$0.postID == id})
                self.TableView.reloadData()
            }
        }
        
        print("TimeZone: \(Calendar.current.timeZone)")
        self.changeLanguageBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        LocalizeVC()
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        }
    
    }
    func LocalizeVC(){
        changeLanguageBtn.setTitle(NSLocalizedString("changeLang", comment: ""), for: .normal)
    }
    
    @IBAction func ChangeLanguageButtonPressed(_ sender: Any) {
        let currentLang = Locale.current.languageCode
        print("current language: \(currentLang ?? "")")
        let newLang = currentLang == "en" ? "ar" : "en"
        UserDefaults.standard.set([newLang], forKey: "AppleLanguages")
        
        let alert = UIAlertController(title: NSLocalizedString("warning", comment: ""), message: NSLocalizedString("bodyMsg", comment: ""), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            exit(0)
        }))
      self.present(alert, animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.TableView.reloadData()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init("PostReload"), object: nil, queue: .main) { (notification) in
            self.TableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("PostReload"), object: nil)
    }
    @IBAction func PlsuButtonPressed(_ sender: UIButton) {
        guard !FirebaseManager.shared.isAnonymouse else {
            self.showAlertForAnonymouseUser()
            return
        }
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as? PostViewController else { return }
        vc.dismissClosure = { post in
//            if self.posts.count > 0 {
//                self.posts.insert(post, at: 0)
//            } else {
//                self.posts.append(post)
//            }
            self.TableView.reloadData()
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func settingButtonPressed(_ sender: UIButton) {
        guard !FirebaseManager.shared.isAnonymouse else {
            self.showAlertForAnonymouseUser()
            return
        }
        guard let settingVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController else { return }
        self.present(settingVC, animated: true, completion: nil)
    }
    
    @IBAction func LogoutButtonPressed(_ sender: UIButton) {
        UserDefaults.standard.setValue("", forKey: "PhoneNumber")
        UserDefaults.standard.setValue("", forKey: "Email")
        AppDelegate.shared.setAuthFlow(true)
    }

    @IBAction func viewMoreButtonPressed(_ sender: UIButton) {
        let tag = sender.tag
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewInfo") as? ViewInfo else { return }
        vc.post = self.posts[tag]
        vc.modalPresentationStyle = .currentContext
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        let postID = (self.isSearch ? self.searchedPosts[sender.tag] : self.posts[sender.tag]).postID
        if let index = MZUser.shared.favouritePosts.firstIndex(of: postID) {
            MZUser.shared.favouritePosts.remove(at: index)
        } else {
            MZUser.shared.favouritePosts.append(postID)
        }
        self.TableView.reloadData()
        FirebaseManager.shared.updateFavouritePosts()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isSearch ? self.searchedPosts.count : self.posts.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.post = self.isSearch ? self.searchedPosts[indexPath.row] : self.posts[indexPath.row]
        cell.backgroundColor =  #colorLiteral(red: 0.8015722632, green: 0.8773888946, blue: 0.8409902453, alpha: 1)
        cell.viewMoreButton.tag = indexPath.row
        cell.viewMoreButton.addTarget(self, action: #selector(self.viewMoreButtonPressed(_:)), for: .touchUpInside)
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: #selector(self.likeButtonPressed(_:)), for: .touchUpInside)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        guard self.isPageDataAvailable == true, self.isSearch == false else { return }
//        if (self.posts.count - 1) == indexPath.row {
//            self.getAllPosts(false)
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // self.performSegue(withIdentifier: "viewDetails", sender: self)
        let tag = indexPath.row
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewInfo") as? ViewInfo else { return }
        vc.post = self.isSearch ? self.searchedPosts[tag] : self.posts[tag]
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
   /* func getAllPosts(_ showLoader: Bool = true) {
        var hud: MBProgressHUD?
        if showLoader {
            hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud?.label.text = "Loading.."
        }
        
        FirebaseManager.shared.getAllPosts { (posts, error) in
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
            self.isPageDataAvailable = posts.count >= (FirebaseManager.shared.postCountsPerPage - 1)
            self.posts.append(contentsOf: posts)
            self.TableView.reloadData()
        }
    } */
    
    func getSearchedPosts(_ text: String) {
        var hud: MBProgressHUD?
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud?.label.text = "Searching.."
        
        FirebaseManager.shared.getSerchedPosts(text) { (posts, error) in
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
            
            self.searchedPosts = posts
            self.TableView.reloadData()
        }
    }
    
    func showAlertForAnonymouseUser() {
        let alert = UIAlertController(title: "", message:  NSLocalizedString("postAlert", comment: ""), preferredStyle: .alert)
        let register = UIAlertAction(title: NSLocalizedString("signUp", comment: ""), style: .default) { (action) in
            AppDelegate.shared.setAuthFlow(true)
        }
        let login = UIAlertAction(title: NSLocalizedString("signInForSignUp", comment: ""), style: .default) { (action) in
            AppDelegate.shared.setAuthFlow(false)
        }
        let cancel = UIAlertAction(title: NSLocalizedString("cancelAlert", comment: ""), style: .destructive, handler: nil)
        alert.addAction(register)
        alert.addAction(login)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Search Pressed")
        self.searchBar.showsCancelButton = false
        if let text = self.searchBar.text, text.count > 0 {
            self.isSearch = true
            self.searchedPosts = Array()
            self.searchBar.resignFirstResponder()
            self.TableView.reloadData()
            self.getSearchedPosts(text)
        } else {
            self.searchBar.text = ""
            self.isSearch = false
            self.TableView.reloadData()
            self.searchBar.resignFirstResponder()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("Search Cancelled")
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        self.isSearch = false
        self.TableView.reloadData()
        self.searchBar.resignFirstResponder()
    }
    
    @objc func willResignActive(_ notification: Notification) {
        let ref = Database.database().reference().child("posts")
        var handle: DatabaseHandle?
        print("Background task started.")
        ref.observe(.childChanged) { (snapshot, key) in
            print(snapshot.key)
            print("price updated")
            
            //step 2: Create the notification content
            
            var content = UNMutableNotificationContent()
            content.title = NSLocalizedString("auction", comment: "")

            content.body = NSLocalizedString("notificationBody", comment: "")
            
            var au = self.checkAuction(postID: snapshot.key) { result in
                content.title = content.title+result+NSLocalizedString("priceUpdate", comment: "")
                
            }

            //step 3: Create the notification trigger
            
            let date = Date().addingTimeInterval(10)
            let dateComponents = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
           let trigger =  UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

            //step 4: Create the request
            
            let request = UNNotificationRequest(identifier: "update", content: content, trigger: trigger)

            //step 5: Register the request
            
            self.center.add(request) { error in
                //Handle errors
                print(error?.localizedDescription)
            }
        } // obsereve database changes
    }// end willResignActive method
    
    func checkAuction(postID: String,completion: @escaping (_ result: String) -> Void) -> String
    {
        var result: String = ""
        let ref = Database.database().reference().child("posts")
        ref.child(postID).child("state").observeSingleEvent(of: .value, with: { (snapshot) in
            if let item = snapshot.value as? String{
                result = item
                completion(result)
            }
        })
        return result
    }
    
}

