//
//  SignIn.swift
//  MAZADUNA
//
//  Created by Lama 🌈🌱🍒 on 09/02/1443 AH.
//

import UIKit
import Firebase
import FirebaseFirestore

class SignIn: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMsg: UILabel!

    
    // Start of UI Localization
    
    @IBOutlet weak var signIn: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var password: UILabel!
    @IBOutlet weak var requiredFeilds: UILabel!
    @IBOutlet weak var signInBUTTON2: UIButton!
    @IBOutlet weak var signByPhoneButton: UIButton!
    @IBOutlet weak var newToMazaduna: UIButton!
    @IBOutlet weak var newUser: UILabel!
    var attrs = [NSAttributedString.Key.underlineStyle : 1]
    var attributedString = NSMutableAttributedString(string:"")
    var titleAlert = NSLocalizedString("errorTitle", comment: "")
    var actionAlert = NSLocalizedString("errorAction", comment: "")
    
    // End of UI Localization

    override func viewDidLoad() {
        super.viewDidLoad()
        signInBUTTON2.layer.cornerRadius=0
        signByPhoneButton.layer.cornerRadius=0
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
        LocalizeVC()
        let attributedWithTextColorE: NSAttributedString = email.text!.attributedStringWithColor(["*"], color: UIColor.red)
        email.attributedText = attributedWithTextColorE
        let attributedWithTextColorPa: NSAttributedString = password.text!.attributedStringWithColor(["*"], color: UIColor.red)
        password.attributedText = attributedWithTextColorPa
       
        let buttonTitleStr = NSMutableAttributedString(string:(newToMazaduna.titleLabel?.text)!, attributes:attrs)
        attributedString.append(buttonTitleStr)
        newToMazaduna.setAttributedTitle(attributedString, for: .normal)
    }

    @IBAction func logInPressed(_ sender: UIButton) {
        
        if (emailTextField.text!.count <= 0 || passwordTextField.text!.count <= 0 ) {
            let alert = UIAlertController(title: titleAlert, message:NSLocalizedString("fillAllFieldsError", comment: ""), preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: actionAlert, style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            if let email = emailTextField.text, let password = passwordTextField.text {
                Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                    if let e = error {
                        
                        if (e.localizedDescription == "There is no user record corresponding to this identifier. The user may have been deleted." )
                        {
                            let alert = UIAlertController(title: self.titleAlert, message: NSLocalizedString("emailNotExist", comment: ""), preferredStyle: UIAlertController.Style.alert)
                            
                            alert.addAction(UIAlertAction(title: self.actionAlert, style: UIAlertAction.Style.default, handler: nil))
                            
                            self.present(alert, animated: true, completion: nil)
                        }else{
                            let alert = UIAlertController(title: self.titleAlert, message: NSLocalizedString("invalidSignIn", comment: ""), preferredStyle: UIAlertController.Style.alert)
                        
                            alert.addAction(UIAlertAction(title: self.actionAlert, style: UIAlertAction.Style.default, handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)
                        }
                        
                    } else {
                        UserDefaults.standard.setValue(self.emailTextField.text, forKey: "Email")
                        self.getDetails()
                        self.performSegue(withIdentifier: "loginToHomescreen", sender: self)
                        self.emailTextField.text = ""
                        self.passwordTextField.text = ""
                        print("Logged")
                        
                       // self.transitionToHome()
                    }
                }
            }
        }
    }
    
    func getDetails() {
        let db = Firestore.firestore()
        guard let id = Auth.auth().currentUser?.uid else { return }
        db.collection("phonenumbers").whereField("uid", isEqualTo: id)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    let alert = UIAlertController(title: self.titleAlert, message: err.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: self.actionAlert, style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                } else {
                    guard querySnapshot?.documents.count ?? 0 > 0 else {
                        return
                    }
                    let phoneNumber = querySnapshot?.documents[0].data()["phonenumber"] as? String ?? ""
                    UserDefaults.standard.setValue(phoneNumber, forKey: "PhoneNumber")
                }
            }
    }
    
    @IBAction func logInPhonePressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toSignInPhone", sender: self)
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {

    }
    
    func transitionToHome(){
        let homeViewController=storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeviewcontroller) as? homeViewController
           view.window?.rootViewController = homeViewController
            view.window?.makeKeyAndVisible()
    }
    
    func LocalizeVC(){
        signIn.text = NSLocalizedString("signInForSignUp", comment: "")
        email.text = NSLocalizedString("emailSignUp", comment: "")
        password.text = NSLocalizedString("passwordSignUp", comment: "")
        requiredFeilds.text = NSLocalizedString("requiredFieldsSignUp", comment: "")
        signInBUTTON2.setTitle(NSLocalizedString("signInForSignUp", comment: ""), for: .normal)
        signByPhoneButton.setTitle(NSLocalizedString("signInByPhone", comment: ""), for: .normal)
        newUser.text = NSLocalizedString("newToMazaduna", comment: "")
        newToMazaduna.setTitle(NSLocalizedString("signUp", comment: ""), for: .normal)
    }
}
extension SignIn: UITextFieldDelegate{
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}
