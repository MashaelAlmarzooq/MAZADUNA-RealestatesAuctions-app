//
//  SettingViewController.swift
//  MAZADUNA
//
//  Created by Tahani Alsubaie on 14/10/21.
//

import UIKit
import MBProgressHUD
import FirebaseAuth
import FirebaseFirestore

class SettingViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    // start of UI localization
    
    @IBOutlet weak var myProfileLabel: UILabel!
    
    // end of UI localization
    
    var settings:[String] = ["",  NSLocalizedString("myPosts", comment: "")]
    var settingImages: [UIImage] = [UIImage(), #imageLiteral(resourceName: "post")]
    var verification_id : String? = nil
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTable()
        // Do any additional setup after loading the view.
        self.backButton.addTarget(self, action: #selector(self.backButtonPressed(_:)), for: .touchUpInside)
        myProfileLabel.text = NSLocalizedString("myProfile", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    func setupTable() {
        self.tableView.register(UINib(nibName: SettingCell.reuseableID, bundle: nil), forCellReuseIdentifier: SettingCell.reuseableID)
        self.tableView.register(UINib(nibName: EmailSettingCell.reuseableID, bundle: nil), forCellReuseIdentifier: EmailSettingCell.reuseableID)
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = self.tableView.dequeueReusableCell(withIdentifier: EmailSettingCell.reuseableID, for: indexPath) as? EmailSettingCell else { return UITableViewCell() }
            cell.editButton.addTarget(self, action: #selector(self.editUserButtonPressed(_:)), for: .touchUpInside)
            return cell
        } else {
            guard let cell = self.tableView.dequeueReusableCell(withIdentifier: SettingCell.reuseableID, for: indexPath) as? SettingCell else { return UITableViewCell() }
            cell.titleLabel.text = self.settings[indexPath.row]
            cell.settingImage.image = self.settingImages[indexPath.row]
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
        self.present(postVC, animated: true, completion: nil)
    }
    
    @IBAction func editUserButtonPressed(_ sender: UIButton) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController") as? EditProfileViewController else { return }
        self.present(vc, animated: true, completion: nil)
    }
    
    func editProfile() {
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        let email = UserDefaults.standard.value(forKey: "Email") as? String ?? ""
        let phone = UserDefaults.standard.value(forKey: "PhoneNumber") as? String ?? ""
        if email.isEmpty == false {
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Email"
                textField.tag = 0
                textField.text = email
            }
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Number"
            textField.tag = 1
            textField.text = phone
        }
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            if let textfields = alertController.textFields {
                var updatedEmail = ""
                var updatedPhone = ""
                if let emailTF = textfields.first(where: {$0.tag == 0}) {
                    updatedEmail = emailTF.text ?? ""
                }
                if let phoneTF = textfields.first(where: {$0.tag == 1}) {
                    updatedPhone = phoneTF.text ?? ""
                }
                
                if updatedPhone != phone || email != updatedEmail {
                    self.saveUserDetails(updatedPhone, updatedEmail)
                }
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func saveUserDetails(_ phone: String, _ email: String) {
        let oldEmail = UserDefaults.standard.value(forKey: "Email") as? String ?? ""
        if oldEmail.isEmpty == false {
            guard email.isValidEmail else {
                self.showAlert("Please enter valid email")
                return
            }
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.label.text = "Updating.."
            FirebaseManager.shared.updateEmail(email) { (error) in
                hud.hide(animated: true)
                if let error = error as NSError? {
                    if error.code == AuthErrorCode.requiresRecentLogin.rawValue {
                        self.presentReloginAlert(error.localizedDescription)
                    } else {
                        self.showAlert(error.localizedDescription)
                    }
                } else {
                    FirebaseManager.shared.savePhoneNumberOnFireStore(phone, nil)
                    UserDefaults.standard.setValue(email, forKey: "Email")
                    self.tableView.reloadData()
                }
            }
        } else {
            self.savePhone(phone)
        }
    }
    
    func savePhone(_ phone: String) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Updating.."
        self.checkPhone(Phone: phone) { (status) in
            DispatchQueue.main.async {
                if status == true {
                    PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil, completion: {verificationID, error in
                        hud.hide(animated: true)
                        if(error != nil) {
                            self.showAlert("Wrong phone number")}
                        else {
                            print(verificationID)
                            self.verification_id = verificationID
                            self.openOTP(phone)
                        }
                    })
                } else {
                    hud.hide(animated: true)
                    self.showAlert("Number already exists")
                }
            }
        }
    }
    
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }

    func openOTP(_ phone: String) {
        let alertController = UIAlertController(title: "", message: "Enter Verification Code", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "OTP"
            textField.tag = 0
        }
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            if let textfields = alertController.textFields {
                
                if let otpTF = textfields[0].text {
                    self.checkOTP(otpTF, phone)
                }
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func checkOTP(_ otp: String, _ phone: String) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Checking.."
        if verification_id != nil {
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verification_id!, verificationCode: otp)
            let user = Auth.auth().currentUser
            user?.updatePhoneNumber(credential, completion: { (error) in
                DispatchQueue.main.async {
                    hud.hide(animated: true)
                    if let error = error as NSError? {
                        if error.code == AuthErrorCode.requiresRecentLogin.rawValue {
                            self.presentReloginAlert(error.localizedDescription)
                        } else {
                            self.showAlert(error.localizedDescription)
                        }
                        
                        return
                    }
                    UserDefaults.standard.setValue(phone, forKey: "PhoneNumber")
                    self.tableView.reloadData()
                }
                
            })
        } else {
            hud.hide(animated: true)
            self.showAlert("Error getting verification id")
        }
    }
    
    func presentReloginAlert(_ message: String) {
        let alert = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
        let login = UIAlertAction(title: "Login", style: .default) { (action) in
            AppDelegate.shared.setAuthFlow(false)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(login)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    func checkPhone(Phone: String, _ closure: ((Bool) -> Void)?) {
        db.collection("phonenumbers").getDocuments {(querySnapshot,error) in
            if let e = error {
                print(e.localizedDescription)
                closure? (false)
            }else{
                if let snapshotDocuments = querySnapshot?.documents{
                    for doc in snapshotDocuments {
                        var str = String(describing: doc.get("phonenumber")!)
                        print(str)
                        if(str == Phone){
                            print("gotcha")
                            closure? (false)
                            return
                        }
                    }
                    closure? (true)
                } else {
                    closure? (true)
                }
            }
        }
    }
}
