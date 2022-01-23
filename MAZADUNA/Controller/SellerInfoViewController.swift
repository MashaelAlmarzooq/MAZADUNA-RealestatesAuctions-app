//
//  SellerInfoViewController.swift
//  MAZADUNA
//
//  Created by Tahani Alsubaie on 01/11/21.
//

import UIKit
import MBProgressHUD
import Firebase

class SellerInfoViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var whatsAppButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    
    @IBOutlet weak var sellerInformationLabel: UILabel!
    var user: MZUser?
    var userID: String = ""
    var posts: [Post] = Array()
    var settings:[String] = ["", NSLocalizedString("sellerPosts", comment: ""),"Ratings"]
    var settingImages: [UIImage] = [UIImage(), #imageLiteral(resourceName: "post")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupUI()
        sellerInformationLabel.text = NSLocalizedString("sellerInformation", comment: "")
        self.setupTable()
        self.getUser()
        self.getUserPosts()
    }
    
    func setupTable() {
        self.tableView.register(UINib(nibName: SettingCell.reuseableID, bundle: nil), forCellReuseIdentifier: SettingCell.reuseableID)
        self.tableView.register(UINib(nibName: EmailSettingCell.reuseableID, bundle: nil), forCellReuseIdentifier: EmailSettingCell.reuseableID)
        self.tableView.register(UINib(nibName: RatingsCell.reuseableID, bundle: nil), forCellReuseIdentifier: RatingsCell.reuseableID)
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor =  #colorLiteral(red: 0.8015722632, green: 0.8773888946, blue: 0.8409902453, alpha: 1)
        self.tableView.tableFooterView = UIView(frame: .zero)
        
    }
    
    func setupUI() {
        self.whatsAppButton.setTitle("", for: .normal)
        self.callButton.setTitle("", for: .normal)
        self.backButton.addTarget(self, action: #selector(self.backButtonPressed(_:)), for: .touchUpInside)
        self.whatsAppButton.addTarget(self, action: #selector(self.whatsAppButtonPressed(_:)), for: .touchUpInside)
        self.callButton.addTarget(self, action: #selector(self.callButtonPressed(_:)), for: .touchUpInside)
    }
    
    func getUser() {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Fetching.."
        hud.show(animated: true)
        FirebaseManager.shared.getUser(self.userID) { (user) in
            hud.hide(animated: true)
            self.user = user
            self.tableView.reloadData()
        }
    }
    
    func getUserPosts() {
        self.posts = AllPosts.shared.posts.filter({$0.userID == self.userID})
        self.tableView.reloadData()
    }
    
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        let postID = self.posts[sender.tag].postID
        if let index = MZUser.shared.favouritePosts.firstIndex(of: postID) {
            MZUser.shared.favouritePosts.remove(at: index)
        } else {
            MZUser.shared.favouritePosts.append(postID)
        }
        self.tableView.reloadData()
        FirebaseManager.shared.updateFavouritePosts()
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func whatsAppButtonPressed(_ sender: UIButton) {
        let phoneNumber =  self.user?.phoneNumber ?? ""
        let appURL = URL(string: "https://api.whatsapp.com/send?phone=\(phoneNumber)")!
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appURL)
            }
        }
    }
    
    @IBAction func callButtonPressed(_ sender: UIButton) {
        let phone = self.user?.phoneNumber ?? ""
        if let callUrl = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(callUrl) {
             UIApplication.shared.open(callUrl)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SellerInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = self.tableView.dequeueReusableCell(withIdentifier: EmailSettingCell.reuseableID, for: indexPath) as? EmailSettingCell else { return UITableViewCell() }
            cell.isLoggedUser = false
            cell.editButton.isHidden = true
            if self.user != nil {
                cell.emailLabel.text = self.user?.email
                cell.mobileLabel.text = self.user?.phoneNumber
            }
            
            return cell
        } else if indexPath.row == 1{
            guard let cell = self.tableView.dequeueReusableCell(withIdentifier: SettingCell.reuseableID, for: indexPath) as? SettingCell else { return UITableViewCell() }
            cell.titleLabel.text = self.settings[indexPath.row]
            cell.settingImage.image = self.settingImages[indexPath.row]
            return cell
        } else{
            guard let cell = self.tableView.dequeueReusableCell(withIdentifier: RatingsCell.reuseableID, for: indexPath) as? RatingsCell else { return UITableViewCell() }
            cell.userID = self.userID
            cell.viewController = self
            let ref = Database.database().reference(withPath: "users").child(self.userID)
                ref.observeSingleEvent(of: .value, with: { snapshot in
                    if !snapshot.exists() { return }
                    let rate = snapshot.childSnapshot(forPath: "rateValue").value
                    print(rate!)
                    cell.rate.text = rate as? String
                    cell.starUI(rate: rate as? String ?? "0.0")
                })
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            self.openMyPosts()
        }
    }
    
    func openMyPosts() {
        guard let postVC = self.storyboard?.instantiateViewController(withIdentifier: "MyPostsViewController") as? MyPostsViewController else { return }
        postVC.isSeller = true
        postVC.posts = self.posts
        self.present(postVC, animated: true, completion: nil)
    }
}
extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}
