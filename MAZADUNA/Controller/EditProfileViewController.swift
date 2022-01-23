//
//  EditProfileViewController.swift
//  MAZADUNA
//
//  Created by Tahani Alsubaie on 27/10/21.
//

import UIKit
import MBProgressHUD
import FirebaseAuth
import FirebaseFirestore

class EditProfileViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailStackView: UIStackView!
    @IBOutlet weak var phoneStackView: UIStackView!
    @IBOutlet weak var saveButton: UIButton!
    
    // start of UI localization
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var requiredFeildsLabel: UILabel!
    // saveButton
    
    // end of UI localization
    
    var verification_id : String? = nil
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        LocalizeVC()
        // Do any additional setup after loading the view.
    }
    
    func LocalizeVC(){
        emailLabel.text = NSLocalizedString("emailSignUp", comment: "")
        phoneLabel.text = NSLocalizedString("phoneSignUp", comment: "")
        requiredFeildsLabel.text = NSLocalizedString("requiredFieldsSignUp", comment: "")
        saveButton.setTitle(NSLocalizedString("saveButton", comment: ""), for: .normal)
        let attributedWithTextColorE: NSAttributedString =  emailLabel.text!.attributedStringWithColor(["*"], color: UIColor.red)
        emailLabel.attributedText = attributedWithTextColorE
        let attributedWithTextColorP: NSAttributedString = phoneLabel.text!.attributedStringWithColor(["*"], color: UIColor.red)
        phoneLabel.attributedText = attributedWithTextColorP
    }
    
    func setupUI() {
        let oldEmail = UserDefaults.standard.value(forKey: "Email") as? String ?? ""
        let phone = UserDefaults.standard.value(forKey: "PhoneNumber") as? String ?? ""
        if oldEmail.isEmpty {
            self.emailStackView.isHidden = true
        } else {
            self.emailTextField.text = oldEmail
        }
        self.phoneTextField.text = phone
        self.saveButton.layer.cornerRadius = 9
        self.saveButton.clipsToBounds = true
        self.backButton.addTarget(self, action: #selector(self.backButtonPressed(_:)), for: .touchUpInside)
        self.saveButton.addTarget(self, action: #selector(self.saveButtonPressed(_:)), for: .touchUpInside)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        self.save()
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func save() {
        let email = UserDefaults.standard.value(forKey: "Email") as? String ?? ""
        let phone = UserDefaults.standard.value(forKey: "PhoneNumber") as? String ?? ""
        let updatedEmail = self.emailTextField.text ?? ""
        let updatedPhone = self.phoneTextField.text ?? ""
        
        if updatedPhone != phone || email != updatedEmail {
            self.saveUserDetails(updatedPhone, updatedEmail)
        }
        
    }
    
    func saveUserDetails(_ phone: String, _ email: String) {
        let oldEmail = UserDefaults.standard.value(forKey: "Email") as? String ?? ""
        let oldPhone = UserDefaults.standard.value(forKey: "PhoneNumber") as? String ?? ""
        if oldEmail.isEmpty == false {
            guard email.isValidEmail else {
                self.showAlert(NSLocalizedString("manageValidEmail", comment: ""))
                return
            }
            if phone != oldPhone {
                if !self.isValidPhone(phone: phone) {
                    self.showAlert(NSLocalizedString("manageValidPhone", comment: ""))
                    return
                }
            }
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.label.text = NSLocalizedString("manageUpdate", comment: "")
            FirebaseManager.shared.updateEmail(email) { (error) in
                hud.hide(animated: true)
                if let error = error as NSError? {
                    if error.code == AuthErrorCode.requiresRecentLogin.rawValue {
                        self.presentReloginAlert(error.localizedDescription)
                    } else {
                        self.showAlert(error.localizedDescription)
                    }
                } else {
                    MZUser.shared.email = email
                    FirebaseManager.shared.updateUser(MZUser.shared.userID)
                    UserDefaults.standard.setValue(email, forKey: "Email")
                    if phone != oldPhone {
                        FirebaseManager.shared.savePhoneNumberOnFireStore(phone) { (isExists) in
                            if isExists {
                                self.showAlert(NSLocalizedString("managePhoneExist", comment: ""))
                            } else {
                                MZUser.shared.phoneNumber = phone
                                FirebaseManager.shared.updateUser(MZUser.shared.userID)
                                UserDefaults.standard.setValue(phone, forKey: "PhoneNumber")
                                let alert = UIAlertController(title: NSLocalizedString("manageConfirm", comment: ""), message: NSLocalizedString("manageProfileSuccessfully", comment: ""), preferredStyle: UIAlertController.Style.alert)
                                
                                alert.addAction(UIAlertAction(title: NSLocalizedString("errorAction", comment: ""), style: UIAlertAction.Style.default, handler: nil))
                                
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    } else {
                        MZUser.shared.phoneNumber = phone
                        FirebaseManager.shared.updateUser(MZUser.shared.userID)
                        UserDefaults.standard.setValue(phone, forKey: "PhoneNumber")
                        MZUser.shared.phoneNumber = phone
                        FirebaseManager.shared.updateUser(MZUser.shared.userID)
                        let alert = UIAlertController(title: NSLocalizedString("manageConfirm", comment: "") , message: NSLocalizedString("manageProfileSuccessfully", comment: ""), preferredStyle: UIAlertController.Style.alert)
                        
                        alert.addAction(UIAlertAction(title: NSLocalizedString("errorAction", comment: ""), style: UIAlertAction.Style.default, handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        } else {
            if self.isValidPhone(phone: phone) {
                self.savePhone(phone)
            } else {
                self.showAlert(NSLocalizedString("manageValidPhone", comment: ""))
            }
            
        }
    }
    
    func savePhone(_ phone: String) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("manageUpdate", comment: "")
        self.checkPhone(Phone: phone) { (status) in
            DispatchQueue.main.async {
                if status == true {
                    PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil, completion: {verificationID, error in
                        hud.hide(animated: true)
                        if(error != nil) {
                            self.showAlert(NSLocalizedString("manageWrongPhone", comment: ""))}
                        else {
                            print(verificationID)
                            self.verification_id = verificationID
                            self.openOTP(phone)
                        }
                    })
                } else {
                    hud.hide(animated: true)
                    self.showAlert(NSLocalizedString("managePhoneExist2", comment: ""))
                }
            }
        }
    }
    
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: NSLocalizedString("errorAction", comment: ""), style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }

    func openOTP(_ phone: String) {
        let alertController = UIAlertController(title: "", message: NSLocalizedString("enterOTP", comment: ""), preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "OTP"
            textField.tag = 0
        }
        let saveAction = UIAlertAction(title: NSLocalizedString("saveButton", comment: ""), style: .default, handler: { alert -> Void in
            if let textfields = alertController.textFields {
                
                if let otpTF = textfields[0].text {
                    self.checkOTP(otpTF, phone)
                }
            }
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancelAlert", comment: ""), style: .default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func checkOTP(_ otp: String, _ phone: String) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("manageCheck", comment: "")
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
                    MZUser.shared.phoneNumber = phone
                    FirebaseManager.shared.updateUser(MZUser.shared.userID)
                    UserDefaults.standard.setValue(phone, forKey: "PhoneNumber")
                    self.showAlert(NSLocalizedString("manageProfileSuccessfully", comment: ""))
                }
                
            })
        } else {
            hud.hide(animated: true)
            self.showAlert(NSLocalizedString("errorOTP", comment: ""))
        }
    }
    
    func presentReloginAlert(_ message: String) {
        let alert = UIAlertController(title: NSLocalizedString("errorTitle", comment: ""), message: message, preferredStyle: .alert)
        let login = UIAlertAction(title: NSLocalizedString("signInForSignUp", comment: ""), style: .default) { (action) in
            AppDelegate.shared.setAuthFlow(false)
        }
        let cancel = UIAlertAction(title: NSLocalizedString("cancelAlert", comment: ""), style: .cancel, handler: nil)
        alert.addAction(login)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    func checkPhone(Phone: String, _ closure: ((Bool) -> Void)?)
    {
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
    
    func validateEmail(enteredEmail:String) -> Bool {

        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)

    }
    func isValidPhone(phone: String) -> Bool {
        let phoneRegex = "^[+][9][6][6]\\d{9}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: phone)
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
