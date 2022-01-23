//
//  TabBarController.swift
//  MAZADUNA
//
//  Created by Macintosh HD on 22/10/21.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        let window = UIApplication.shared.windows.first
        let topPadding = window?.safeAreaInsets.top ?? 0
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0
        self.tabBar.unselectedItemTintColor = .white
        self.tabBar.selectionIndicatorImage = self.image(from: #colorLiteral(red: 0.8352941176, green: 0.8352941176, blue: 0.8352941176, alpha: 1), for: CGSize(width: UIScreen.main.bounds.width / 5, height: self.tabBar.frame.height + bottomPadding), withCornerRadius: 0)
        // Do any additional setup after loading the view.
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func image(from color: UIColor?, for size: CGSize, withCornerRadius radius: CGFloat) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        if let cg = color?.cgColor {
           context?.setFillColor(cg)
        }
        context!.fill(rect)
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIGraphicsBeginImageContext(size)
        UIBezierPath(roundedRect: rect, cornerRadius: radius).addClip()
        image?.draw(in: rect)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.isKind(of: PostViewController.self) {
            if let homeVC = self.viewControllers?.first(where: {$0.isKind(of: homeViewController.self)}) as? homeViewController {
                homeVC.PlsuButtonPressed(UIButton())
            }
            return false
        }
        
        if (viewController.isKind(of: SettingViewController.self) ) && FirebaseManager.shared.isAnonymouse {
            
                let alert = UIAlertController(title: "", message: NSLocalizedString("settingsAlert", comment: ""), preferredStyle: .alert)
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
            
            return false
        }
        if (viewController.isKind(of: FavouritePostViewController.self) ) && FirebaseManager.shared.isAnonymouse {
            
                let alert = UIAlertController(title: "", message: NSLocalizedString("favoriteAlert", comment: ""), preferredStyle: .alert)
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
            
            return false
        }
        return true
    }

}


