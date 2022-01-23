//
//  ViewController.swift
//  MAZADUNA
//
//  Created by Tahani Alsubaie on 13/02/1443 AH.
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import MBProgressHUD

class SignUpViewController: UIViewController {
    // Start of UI Localization
    
    @IBOutlet weak var SignUp: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var password: UILabel!
    @IBOutlet weak var requiredFields: UILabel!
    @IBOutlet weak var SignUpButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var doYouHaveAcc: UILabel!
    @IBOutlet weak var signIn: UIButton!
    @IBOutlet weak var emailError: UILabel!
    @IBOutlet weak var phoneError: UILabel!
    @IBOutlet weak var passwordError: UILabel!
    var titleAlert = NSLocalizedString("errorTitle", comment: "")
    var actionAlert = NSLocalizedString("errorAction", comment: "")
    
    // End of UI Localization
        
    @IBOutlet weak var EmailField: UITextField!
    @IBOutlet weak var PhoneField: UITextField!
    @IBOutlet weak var PasswordField: UITextField!
    @IBOutlet var LogInButton: UIView!
    
    @IBOutlet weak var Logo: UIImageView!
    @IBOutlet weak var Frame: UIView!

 

    
    var attrs = [NSAttributedString.Key.underlineStyle : 1]
    var attributedString = NSMutableAttributedString(string:"")
    
    @objc func checkAndDisplayErrorEmail(textfield: UITextField){
        if(validateEmail(enteredEmail:textfield.text! ) == false ){
            emailError.text = NSLocalizedString("validEmail", comment: "")
        } else{
            emailError.text? = ""
        }
    }
    @objc func checkAndDisplayErrorPhone(textfield: UITextField){
        if(isValidPhone(phone: textfield.text!) == false ){
            phoneError.text = NSLocalizedString("validPhonenumber", comment: "")
        } else{
            phoneError.text? = ""
        }
    }
    @objc func checkAndDisplayErrorPassword(textfield: UITextField){
        if(isPasswordValid(password:textfield.text! ) == false){
            passwordError.text = NSLocalizedString("strongPassword", comment: "")
        } else{
            passwordError.text? = ""
        }
    }
    
    @IBAction func ButtonClicked(_ sender: Any) {
        if EmailField.text?.trimmingCharacters(in: .whitespacesAndNewlines)=="" ||
             PhoneField.text?.trimmingCharacters(in: .whitespacesAndNewlines)=="" ||
             PasswordField.text?.trimmingCharacters(in: .whitespacesAndNewlines)==""{
              
              let alert = UIAlertController(title: titleAlert, message: NSLocalizedString("fillAllFieldsError", comment: ""), preferredStyle: UIAlertController.Style.alert)
              alert.addAction(UIAlertAction(title: actionAlert, style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)}
        
        else if isValidPhone(phone: PhoneField.text!) == false && validateEmail(enteredEmail:EmailField.text! ) == false && isPasswordValid(password:PasswordField.text! ) == false {
            let alert = UIAlertController(title: titleAlert, message:  NSLocalizedString("validAllFields", comment: ""), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: actionAlert, style: UIAlertAction.Style.default, handler: nil))
          self.present(alert, animated: true, completion: nil)
        }
        else if isValidPhone(phone: PhoneField.text!) == false && validateEmail(enteredEmail:EmailField.text! ) == false   {
            let alert = UIAlertController(title: titleAlert, message: NSLocalizedString("validEmailAndPhone", comment: ""), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: actionAlert, style: UIAlertAction.Style.default, handler: nil))
          self.present(alert, animated: true, completion: nil)
        }
        else if isValidPhone(phone: PhoneField.text!) == false &&  isPasswordValid(password:PasswordField.text! ) == false {
            let alert = UIAlertController(title: titleAlert, message: NSLocalizedString("validPhoneAndPassword", comment: ""), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: actionAlert, style: UIAlertAction.Style.default, handler: nil))
          self.present(alert, animated: true, completion: nil)
        } else if  validateEmail(enteredEmail:EmailField.text! ) == false && isPasswordValid(password:PasswordField.text! ) == false {
            let alert = UIAlertController(title: titleAlert, message: NSLocalizedString("validEmailAndPassword", comment: ""), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: actionAlert, style: UIAlertAction.Style.default, handler: nil))
          self.present(alert, animated: true, completion: nil)
        }
        
        else if isValidPhone(phone: PhoneField.text!) == false {
             let alert = UIAlertController(title: titleAlert, message: NSLocalizedString("validPhone", comment: ""), preferredStyle: UIAlertController.Style.alert)
             alert.addAction(UIAlertAction(title: actionAlert, style: UIAlertAction.Style.default, handler: nil))
             self.present(alert, animated: true, completion: nil)
         }
        else if validateEmail(enteredEmail:EmailField.text! ) == false {
             
             let alert = UIAlertController(title: titleAlert, message: NSLocalizedString("validEmail", comment: ""), preferredStyle: UIAlertController.Style.alert)
             alert.addAction(UIAlertAction(title: actionAlert, style: UIAlertAction.Style.default, handler: nil))
             self.present(alert, animated: true, completion: nil)
         }
        else if isPasswordValid(password:PasswordField.text! ) == false {
             let alert = UIAlertController(title: titleAlert, message: NSLocalizedString("validPassword", comment: ""), preferredStyle: UIAlertController.Style.alert)
             alert.addAction(UIAlertAction(title: actionAlert, style: UIAlertAction.Style.default, handler: nil))
             self.present(alert, animated: true, completion: nil)
        }
        
        else {
        // create cleaned versions of the data
            let email = EmailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let phonenumber = PhoneField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = PasswordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            //Check Mobile Number
            let db = Firestore.firestore()
            db.collection("phonenumbers").whereField("phonenumber", isEqualTo: phonenumber)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        let alert = UIAlertController(title: self.titleAlert, message: err.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: self.actionAlert, style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        return
                    } else {
                        guard querySnapshot?.documents.count == 0 else {
                            let alert = UIAlertController(title: self.titleAlert, message:  NSLocalizedString("phoneExist", comment: ""), preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: self.actionAlert, style: UIAlertAction.Style.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            return
                        }
                        //create the userd
                        Auth.auth().createUser(withEmail: email, password: password) { (results, err) in
                            //check for errors
                            if err != nil {
                                    
                                // there was an error creating the user
                                let alert = UIAlertController(title: self.titleAlert, message: NSLocalizedString("validEmail", comment: ""), preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: self.actionAlert, style: UIAlertAction.Style.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                
                            } else {
                                //user was created successfully
                                UserDefaults.standard.setValue(email, forKey: "Email")
                                UserDefaults.standard.setValue(phonenumber, forKey: "PhoneNumber")
                                let db = Firestore.firestore()
                                db.collection("phonenumbers").addDocument(data: ["phonenumber":phonenumber, "uid": results!.user.uid]){ (error) in
                                    if error != nil {
                                        let alert = UIAlertController(title: self.titleAlert, message:  NSLocalizedString("phoneExist", comment: ""), preferredStyle: UIAlertController.Style.alert)
                                        alert.addAction(UIAlertAction(title: self.actionAlert, style: UIAlertAction.Style.default, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                }
                                //transition to the home screen
                                // self.transitionToHome()
                                self.performSegue(withIdentifier: "signUpToHome", sender: self)
                            }
                        }
                    }
                }
            }
    }
        
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        SignUpButton.layer.cornerRadius=0
        skipButton.layer.cornerRadius=0
        self.hideKeyboardWhenTappedAround()
        self.skipButton.addTarget(self, action: #selector(self.skipButtonPressed(_:)), for: .touchUpInside)
        self.checkPhoneNumber()
        EmailField.addTarget(self, action:#selector(checkAndDisplayErrorEmail(textfield:)), for: .editingChanged)
        PhoneField.addTarget(self, action:#selector(checkAndDisplayErrorPhone(textfield:)), for: .editingChanged)
        PasswordField.addTarget(self, action:#selector(checkAndDisplayErrorPassword(textfield:)), for: .editingChanged)
        LocalizeVC()
        let attributedWithTextColorE: NSAttributedString = email.text!.attributedStringWithColor(["*"], color: UIColor.red)
        email.attributedText = attributedWithTextColorE
        let attributedWithTextColorP: NSAttributedString = phone.text!.attributedStringWithColor(["*"], color: UIColor.red)
        phone.attributedText = attributedWithTextColorP
        let attributedWithTextColorPa: NSAttributedString = password.text!.attributedStringWithColor(["*"], color: UIColor.red)
        password.attributedText = attributedWithTextColorPa
       
        let buttonTitleStr = NSMutableAttributedString(string:(signIn.titleLabel?.text)!, attributes:attrs)
        attributedString.append(buttonTitleStr)
        signIn.setAttributedTitle(attributedString, for: .normal)

    }
    
    func checkPhoneNumber() {
        

    }
     
    func transitionToHome(){
        self.performSegue(withIdentifier: "signUpToHome", sender: self)
    }
  
    func validateEmail(enteredEmail:String) -> Bool {
        var emailNoWhitespace = enteredEmail.trimmingCharacters(in: .whitespaces)
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: emailNoWhitespace)

    }
    func isValidPhone(phone: String) -> Bool {
            var phoneNoWhitespace = phone.trimmingCharacters(in: .whitespaces)
            let phoneRegex = "^[+][9][6][6]\\d{9}$"
            let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
            return phoneTest.evaluate(with: phoneNoWhitespace)
        }
    
    func isPasswordValid( password : String) -> Bool{
        var passwordNoWhitespace = password.trimmingCharacters(in: .whitespaces)
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: passwordNoWhitespace)
    }
  
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Loading.."
        FirebaseManager.shared.getStarted { (user, error) in
            hud.hide(animated: true)
            guard let _ = user else {
                if let error = error {
                    self.showAlert(error.localizedDescription)
                }
                return
            }
            self.performSegue(withIdentifier: "signUpToHome", sender: self)
        }
    }
 
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func LocalizeVC(){
        SignUp.text = NSLocalizedString("signUp", comment: "")
        email.text = NSLocalizedString("emailSignUp", comment: "")
        phone.text = NSLocalizedString("phoneSignUp", comment: "")
        password.text = NSLocalizedString("passwordSignUp", comment: "")
        requiredFields.text = NSLocalizedString("requiredFieldsSignUp", comment: "")
        SignUpButton.setTitle(NSLocalizedString("SignUpButton", comment: ""), for: .normal)
        skipButton.setTitle(NSLocalizedString("skipButton", comment: ""), for: .normal)
        doYouHaveAcc.text = NSLocalizedString("doYouHaveAcc", comment: "")
        signIn.setTitle(NSLocalizedString("signInForSignUp", comment: ""), for: .normal)
    }
}
extension SignUpViewController: UITextFieldDelegate{
        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true;
        }
}
extension String {
    func attributedStringWithColor(_ strings: [String], color: UIColor, characterSpacing: UInt? = nil) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        for string in strings {
            let range = (self as NSString).range(of: string)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        }

        guard let characterSpacing = characterSpacing else {return attributedString}

        attributedString.addAttribute(NSAttributedString.Key.kern, value: characterSpacing, range: NSRange(location: 0, length: attributedString.length))

        return attributedString
    }
}


