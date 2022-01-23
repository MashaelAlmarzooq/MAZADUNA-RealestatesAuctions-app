//
//  SignOut.swift
//  MAZADUNA
//
//  Created by Lama 🌈🌱🍒 on 09/02/1443 AH.
//

import UIKit
import Firebase
class SignOut: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func logOutPressed(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            FirebaseManager.shared.resetClass()
            AppDelegate.shared.setAuthFlow(true)
//            self.performSegue(withIdentifier: "unwindToViewController1", sender: self)
            
        } catch let signOutError as NSError {
            let alert = UIAlertController(title: "Error", message: signOutError.localizedDescription, preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}
    

