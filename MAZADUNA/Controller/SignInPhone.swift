//
//  SignInPhone.swift
//  MAZADUNA
//
//  Created by Lama 🌈🌱🍒 on 09/02/1443 AH.
//

import UIKit
import Firebase
import FirebaseFirestore

class SignInPhone: UIViewController {
    var count = 0
    // Start of UI Localazation
    
    @IBOutlet weak var signIn: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var requiredFeilds: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var OTP: UITextField!
    @IBOutlet weak var otpUI: UILabel!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var newUser: UILabel!
    var attrs = [NSAttributedString.Key.underlineStyle : 1]
    var attributedString = NSMutableAttributedString(string:"")
    var titleAlert = NSLocalizedString("errorTitle", comment: "")
    var actionAlert = NSLocalizedString("errorAction", comment: "")
    // End of UI Localazation
    
    @IBOutlet weak var otpStackView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        OTP.isHidden = true
        otpStackView.isHidden = true
        signInButton.layer.cornerRadius=0
        // Do any additional setup after loading the view.
        LocalizeVC()
        let attributedWithTextColorE: NSAttributedString = phone.text!.attributedStringWithColor(["*"], color: UIColor.red)
        phone.attributedText = attributedWithTextColorE
        let attributedWithTextColorPa: NSAttributedString = otpUI.text!.attributedStringWithColor(["*"], color: UIColor.red)
        otpUI.attributedText = attributedWithTextColorPa
       
        let buttonTitleStr = NSMutableAttributedString(string:(signUpBtn.titleLabel?.text)!, attributes:attrs)
        attributedString.append(buttonTitleStr)
        signUpBtn.setAttributedTitle(attributedString, for: .normal)
    }
    
    
    let db = Firestore.firestore()


    func checkPhone(Phone: String) -> Bool
    {
        var result: Bool = true
        db.collection("phonenumbers").getDocuments {(querySnapshot,error) in
            if let e = error {
                print(e.localizedDescription)
            }else{
                if let snapshotDocuments = querySnapshot?.documents{
                    for doc in snapshotDocuments{
                        var str = String(describing: doc.get("phonenumber")!)
                        print(str)
                        if(str == Phone){
                            print("gotcha")
                            result = true
                            print(result)
                            return
                        }
                    }
                }
            }
            
        }
        result = false
        print(result)
        return result
    }
    
    func checkPhoneUN(Phone: String)
    {
        count = 0
        db.collection("phonenumbers").getDocuments { [self](querySnapshot,error) in
            if let e = error {
                print(e.localizedDescription)
            }else{
                if let snapshotDocuments = querySnapshot?.documents{
                    for doc in snapshotDocuments{
                        var str = String(describing: doc.get("phonenumber")!)
                        print(str)
                        if(str == Phone){
                            self.count+=1
                        }
                    }
                    if self.count > 0{
                        print("phone exist")
                    }else{
                        let alert = UIAlertController(title: self.titleAlert, message: NSLocalizedString("wrongPhone", comment: ""), preferredStyle: UIAlertController.Style.alert)
                        
                        alert.addAction(UIAlertAction(title: self.actionAlert, style: UIAlertAction.Style.default, handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    }
                }
            }
        }
    
    var verification_id : String? = nil
    @IBAction func logInPressed(_ sender: UIButton) {
        if (OTP.isHidden){
            checkPhoneUN(Phone: phoneNumber.text!)
            let flag = checkPhone(Phone: phoneNumber.text!)
            if (!phoneNumber.text!.isEmpty && !flag){
                PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber.text!, uiDelegate: nil, completion: {verificationID, error in
                    if(self.count==0||error != nil){
                        print("here")
                        print(error?.localizedDescription)
                        let alert = UIAlertController(title: self.titleAlert, message: NSLocalizedString("wrongPhone", comment: ""), preferredStyle: UIAlertController.Style.alert)
                        
                        alert.addAction(UIAlertAction(title: self.actionAlert, style: UIAlertAction.Style.default, handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)}
                    else{
                        print(verificationID)
                        UserDefaults.standard.setValue(self.phoneNumber.text, forKey: "PhoneNumber")
                        self.verification_id = verificationID
                        self.OTP.isHidden = false
                        self.otpStackView.isHidden = false
                    }
            })
            
            }else{
                let alert = UIAlertController(title: self.titleAlert, message: NSLocalizedString("fillAllFieldsError", comment: ""), preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: self.actionAlert, style: UIAlertAction.Style.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)

            }
        }else{
            if verification_id != nil {
                let credential = PhoneAuthProvider.provider().credential(withVerificationID: verification_id!, verificationCode: OTP.text!)
                Auth.auth().signIn(with: credential, completion: { authData, error in
                    if (error != nil){
                        let alert = UIAlertController(title: self.titleAlert, message: NSLocalizedString("wrongOTP", comment: ""), preferredStyle: UIAlertController.Style.alert)
                        
                        alert.addAction(UIAlertAction(title: self.actionAlert, style: UIAlertAction.Style.default, handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)
                    }else{
                        self.performSegue(withIdentifier: "toLogInPhone", sender: self)
                        UserDefaults.standard.setValue(self.phoneNumber.text, forKey: "PhoneNumber")
                        self.phoneNumber.text = ""
                        self.OTP.text = ""
                    }
                })
            }else{
                let alert = UIAlertController(title: self.titleAlert, message: NSLocalizedString("errorOTP", comment: ""), preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: self.actionAlert, style: UIAlertAction.Style.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func LocalizeVC(){
        signIn.text = NSLocalizedString("signInForSignUp", comment: "")
        phone.text = NSLocalizedString("phoneSignUp", comment: "")
        requiredFeilds.text = NSLocalizedString("requiredFieldsSignUp", comment: "")
        signInButton.setTitle(NSLocalizedString("signInForSignUp", comment: ""), for: .normal)
        otpUI.text = NSLocalizedString("OTP", comment: "")
        signUpBtn.setTitle(NSLocalizedString("signUp", comment: ""), for: .normal)
        newUser.text = NSLocalizedString("newToMazaduna", comment: "")
    }
}

