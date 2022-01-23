//
//  ViewInfo.swift
//  MAZADUNA
//
//  Created by Meshael Hamad on 13/02/1443 AH.
//

import UIKit
import Firebase
import FirebaseFirestore
import UserNotifications
import Social

class ViewInfo: UIViewController {
    @IBOutlet weak var realEstateImage: UIImageView!
    @IBOutlet weak var realEstateName: UILabel!
    @IBOutlet weak var realEstateLocation: UILabel!
    @IBOutlet weak var realEstateType: UILabel!
    @IBOutlet weak var realEstateSpace: UILabel!
    @IBOutlet weak var realEstateStartTime: UILabel!
    @IBOutlet weak var realEstateEndTime: UILabel!
    @IBOutlet weak var realEstatePrice: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var mapButtonNav: UIButton!
    @IBOutlet weak var postRealEstate: UIButton!
    @IBOutlet weak var imagePager: CarouView!

    @IBOutlet weak var bidBtn: UIButton!
    @IBOutlet weak var plus: UIButton!
    @IBOutlet weak var minus: UIButton!
    @IBOutlet weak var sellerInfoButton: UIButton!
    
    @IBOutlet weak var startPriceRealEstate: UILabel!
    @IBOutlet weak var nighbrealestate: UILabel!
    @IBOutlet weak var bidButton: UIStepper!
    @IBOutlet weak var TwitterButton: UIButton!
    var post: Post!
    var price = ""
    let center = UNUserNotificationCenter.current()
    let db = Firestore.firestore()
    let userID : String = (Auth.auth().currentUser?.uid)!

   
    override func viewDidLoad() {
        super.viewDidLoad()
        bidButton.isHidden = true
        bidBtn.setTitle(NSLocalizedString("bidButton", comment: ""), for: .normal)
        center.requestAuthorization(options: [.alert,.sound]) { granted, error in
        }
        
        plus.isHidden = true
        minus.isHidden = true
        bidBtn.isHidden = true
        realEstatePrice.isHidden = true
        
        
        let currentDate = Date()
        let startDateString = post.startDate
        let endDateString = post.endDate
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss-dd.MM.yyyy"
        
        let startDate = dateFormatter.date(from: startDateString)!
        let endDate = dateFormatter.date(from: endDateString)!
        
        if startDate.compare(currentDate) == .orderedAscending && endDate.compare(currentDate) == .orderedDescending {
            
            plus.isHidden = false
            minus.isHidden = false
            bidBtn.isHidden = false
            realEstatePrice.isHidden = false
            
        }
        
        if  post.userID == userID {
            plus.isHidden = true
            minus.isHidden = true
            bidBtn.isHidden = true
         }
        
        if (checkTimeStamp(date:post.endDate) == false){
            plus.isHidden = true
            minus.isHidden = true
            bidBtn.isHidden = true
            realEstatePrice.isHidden = true
        }


        
        
        
        price = post.price
        // Do any additional setup after loading the view.
        postRealEstate.layer.cornerRadius=50
        self.mapButtonNav.layer.cornerRadius = 6
        self.mapButtonNav.clipsToBounds = true
        self.sellerInfoButton.layer.cornerRadius = 6
        self.sellerInfoButton.clipsToBounds = true
        let currentLang = Locale.current.languageCode
        plus.layer.cornerRadius = 9
        minus.layer.cornerRadius = 9
        bidBtn.layer.cornerRadius = 9
        let db = Firestore.firestore()
        self.realEstateName.text = self.post.state
        self.realEstateLocation.attributedText = self.getAttributedLabelText(NSLocalizedString("vLocation", comment: ""), self.post.location)//"City : " + self.post.location
        if(currentLang == "en"){
            self.realEstateType.attributedText = self.getAttributedLabelText(NSLocalizedString("vType", comment: ""), translateTypeToEN(type: self.post.type))

        }else{
            self.realEstateType.attributedText = self.getAttributedLabelText(NSLocalizedString("vType", comment: ""), translateTypeToAR(type: self.post.type))

        }
        //"Type : " + self.post.type
        self.realEstateSpace.attributedText = self.getAttributedLabelText(NSLocalizedString("vSpace", comment: ""), self.post.space  + " "+NSLocalizedString("realEstateMeter", comment: ""))//"Space : " + self.post.space + " m²"
        self.realEstateStartTime.attributedText = self.getAttributedLabelText(NSLocalizedString("vStartDate", comment: ""), self.post.startDate)//"Start Date : " + self.post.startDate
        self.realEstateEndTime.attributedText = self.getAttributedLabelText(NSLocalizedString("vEndDate", comment: ""), self.post.endDate)//"End Date : " + self.post.endDate
        self.realEstatePrice.attributedText = self.getAttributedLabelText(NSLocalizedString("vCurrentPrice", comment: ""), self.post.price+" "+NSLocalizedString("realEstateCurrency", comment: ""))
        self.startPriceRealEstate.attributedText = self.getAttributedLabelText(NSLocalizedString("vStartPrice", comment: ""), self.post.startPrice+" "+NSLocalizedString("realEstateCurrency", comment: ""))//"Start Price : "+self.post.startPrice+" SAR"
        self.realEstateImage.kf.setImage(with: URL(string: self.post.image[0] ?? ""))
        self.nighbrealestate.attributedText = self.getAttributedLinkText(NSLocalizedString("vNeighborhood", comment: ""), self.post.nigbh)//"Neighborhood : " + self.post.nigbh
        self.descriptionLabel.attributedText = self.getAttributedLabelText(NSLocalizedString("vDescription", comment: ""), self.post.descriptionForEstate)//"Description : " + self.post.descriptionForEstate
        self.mapButtonNav.addTarget(self, action: #selector(self.openMapPressed(_:)), for: .touchUpInside)
        self.sellerInfoButton.addTarget(self, action: #selector(self.sellerInfoButtonPressed(_:)), for: .touchUpInside)
        self.imagePager.images = self.post.image
//        self.imagePager.setupPager()
        minus.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.neighbourGestureTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.nighbrealestate.addGestureRecognizer(tapGesture)
        self.nighbrealestate.isUserInteractionEnabled = true
        
        guard !FirebaseManager.shared.isAnonymouse else {
                    plus.isHidden = true
                    minus.isHidden = true
                    bidBtn.isHidden = true
                //  sellerInfoButton.isHidden = true
                    return
                 }
        
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        }
        
    }
    @IBAction func TwitterPressed(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("shareTitle", comment: ""), message: NSLocalizedString("shareMsg", comment: ""), preferredStyle: .actionSheet)
        let actionoOne = UIAlertAction(title: NSLocalizedString("shareTwt", comment: ""), style: .default){ (ACTION) in
           
            var share : SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            
            let like = NSLocalizedString("like", comment: "")
            let locate = NSLocalizedString("locate", comment: "") + " " + self.post.nigbh
            let inText = NSLocalizedString("in", comment: "")+self.post.location
            let city = NSLocalizedString("city", comment: "")
            let describe = NSLocalizedString("describe", comment: "")+" "+self.post.descriptionForEstate
            let startWith = NSLocalizedString("startWith", comment: "")+" "+self.post.startPrice+" "+NSLocalizedString("realEstateCurrency", comment: "")
            let nowReaches = NSLocalizedString("nowReaches", comment: "")+" "+self.post.price+" "+NSLocalizedString("realEstateCurrency", comment: "")
           
            let x = like+locate
            
            let y = inText+city+describe
            
            let z = startWith+nowReaches

            let xyz = x+y+z
                    
        let imageUrlString = self.post.image[0]

        let imageUrl = URL(string: imageUrlString)!

        let imageData = try! Data(contentsOf: imageUrl)

        let image = UIImage(data: imageData)
               
                        
        share.setInitialText(xyz)
        share.add(image)
 
        self.present(share, animated: true)


        
    }
        let actionTOW = UIAlertAction(title: NSLocalizedString("cancelAlert", comment: ""), style: .destructive, handler: nil)
        
      
        alert.addAction(actionoOne)
        alert.addAction(actionTOW)
        self.present(alert, animated: true, completion: nil)
    }
    
    func getAttributedLabelText(_ title: String, _ message: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString.init(string: title, attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .bold)])
        let attributedMessage = NSAttributedString(string: message, attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .regular)])
        attributedTitle.append(attributedMessage)
        return attributedTitle
    }
    
    func getAttributedLinkText(_ title: String, _ message: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString.init(string: title, attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .bold)])
        let attributedMessage = NSAttributedString(string: message, attributes: [.link : "www.xyz.com" ,.font: UIFont.systemFont(ofSize: 17, weight: .regular)])
        attributedTitle.append(attributedMessage)
        return attributedTitle
    }
    
    @IBAction func plusPressed(_ sender: UIButton) {
        minus.isHidden = false
        var value = Int(price)
        if(value! < 2*Int(post.price)!){
            value = value! + 500
            price = String(value!)
            self.realEstatePrice.attributedText = self.getAttributedLabelText(NSLocalizedString("vCurrentPrice", comment: ""), String(value!) + " "+NSLocalizedString("realEstateCurrency", comment: ""))
        }else{
            let alert = UIAlertController(title: NSLocalizedString("errorTitle", comment: ""), message: NSLocalizedString("bidErrorHigh", comment: ""), preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("errorAction", comment: ""), style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func minusPressed(_ sender: UIButton) {
        var value = Int(price)
        if(value! > Int(post.price)!){
            value = value! - 500
            price = String(value!)
            self.realEstatePrice.attributedText = self.getAttributedLabelText(NSLocalizedString("vCurrentPrice", comment: ""), String(value!) + " "+NSLocalizedString("realEstateCurrency", comment: ""))
        }else{
            let alert = UIAlertController(title: NSLocalizedString("errorTitle", comment: ""), message: NSLocalizedString("bidErrorLow", comment: ""), preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("errorAction", comment: ""), style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }

    }
    
    func checkTimeStamp(date: String!) -> Bool {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss-dd.MM.yyyy"
            let datecomponents = dateFormatter.date(from: date)

            let now = Date()

            if (datecomponents! >= now) {
                return true
            } else {
                return false
            }
        }
    
    @IBAction func bidButtonPressed(_ sender: UIButton) {
        var value = Int(price)
        if(value == Int(post.price)) {
            let alert = UIAlertController(title: NSLocalizedString("errorTitle", comment: ""), message: NSLocalizedString("bidErrorSame", comment: ""), preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("errorAction", comment: ""), style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }else{
            let userID : String = (Auth.auth().currentUser?.uid)!
            let ref = Database.database().reference().child("posts").child(post.postID).child("bidders").child(userID)
            ref.setValue(price)
            
            let refOfPrice = Database.database().reference().child("posts").child(post.postID).updateChildValues(["price": price])
            post.setPrice(newPrice: price)
            
            let alert = UIAlertController(title: NSLocalizedString("bidConfirmationTitle", comment: ""), message: NSLocalizedString("bidConfirmationMsg", comment: ""), preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("errorAction", comment: ""), style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
            viewDidLoad()
            
            var ph = checkPhone { result in
                let end = self.post.endDate
                // HH:mm:ss-dd.MM.yyyy
                let hour = end.substring(with: 0..<2)
                let minute = end.substring(with: 3..<5)
                let second = end.substring(with: 6..<8)
                let day = end.substring(with: 9..<11)
                let month = end.substring(with: 12..<14)
                let year = end.substring(from: 15)
                let content = UNMutableNotificationContent()
                
                content.title = NSLocalizedString("auction", comment: "")+self.post.state+NSLocalizedString("ended", comment: "")
                content.subtitle = NSLocalizedString("closePrice", comment: "")+self.post.price+" "+NSLocalizedString("realEstateCurrency", comment: "")
                content.body = NSLocalizedString("bidder", comment: "")+result+NSLocalizedString("hasWon", comment: "")
                
                //step 3: Create the notification trigger
                
                var dateComponents = DateComponents()
                dateComponents.hour = Int(hour)
                dateComponents.minute = Int(minute)
                dateComponents.second = Int(second)
                dateComponents.day = Int(day)
                dateComponents.month = Int(month)
                dateComponents.year = Int(year)
                
                
               let trigger =  UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
                //step 4: Create the request
                
                let request = UNNotificationRequest(identifier: "end", content: content, trigger: trigger)
                
                //step 5: Register the request
                
                self.center.add(request) { error in
                    //Handle errors
                    print(error?.localizedDescription)
                }
            }
        }
    }
    @IBAction func BackButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func openMapPressed(_ sender: UIButton) {
        guard let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "LocationPickViewController") as? LocationPickViewController else { return }
        mapVC.post = self.post
        mapVC.fromPost = true
        mapVC.modalPresentationStyle = .fullScreen
        self.present(mapVC, animated: true, completion: nil)
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        guard !FirebaseManager.shared.isAnonymouse else {
            self.showAlertForAnonymouseUser()
            return
        }
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as? PostViewController else { return }
      
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func sellerInfoButtonPressed(_ sender: UIButton) {
        guard let sellerVC = self.storyboard?.instantiateViewController(withIdentifier: "SellerInfoViewController") as? SellerInfoViewController else { return }
        sellerVC.userID = self.post.userID
        sellerVC.modalPresentationStyle = .fullScreen
        self.present(sellerVC, animated: true, completion: nil)
    }
    
    @IBAction func neighbourGestureTapped(_ sender: UITapGestureRecognizer) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "NeighbourhoodCommentsViewController") as? NeighbourhoodCommentsViewController else { return }
        vc.selectedNeighbour = self.post.nigbh
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }
    
    func showAlertForAnonymouseUser() {
        let alert = UIAlertController(title: "", message: NSLocalizedString("postAlert", comment: ""), preferredStyle: .alert)
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
    
    @objc func willResignActive(_ notification: Notification) {
        print("Background task started.")
        Database.database().reference().child("posts").observe(.childChanged) { (snapshot, key) in
            print(snapshot.key)
            print("price updated")
            
            //step 2: Create the notification content
            
            let content = UNMutableNotificationContent()

            content.title = NSLocalizedString("auction", comment: "")+self.post.state+NSLocalizedString("priceUpdate", comment: "")

            content.body = NSLocalizedString("notificationBody", comment: "")

            //step 3: Create the notification trigger
            
            let date = Date().addingTimeInterval(15)

            let dateComponents = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)

           let trigger =  UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

            //step 4: Create the request
            
            let request = UNNotificationRequest(identifier: "update", content: content, trigger: trigger)

            //step 5: Register the request
            
            self.center.add(request) { error in
                //Handle errors
                print(error?.localizedDescription)
            }
        }
    }
    func checkPhone(completion: @escaping (_ result: String) -> Void) -> String
    {
        var result: String = ""
        db.collection("phonenumbers").getDocuments {(querySnapshot,error) in
            if let e = error {
                print(e.localizedDescription)
            }else{
                if let snapshotDocuments = querySnapshot?.documents{
                    for doc in snapshotDocuments{
                        let str = String(describing: doc.get("uid")!)
                        if(str == self.userID){
                            print("gotcha")
                            result = String(describing: doc.get("phonenumber")!)
                            print(result)
                            completion(result)
                            return
                        }
                    }
                }
            }
            
        }
        return result
    }
    
    
    func translateTypeToAR(type: String) -> String{
        var newType = ""
        switch type {
        case "Villa":
            newType = "فيلا"
        case "Land":
            newType = "أرض"
        case "Apartment":
            newType = "شقة"
        case "Duplex":
            newType = "دبلكس"
        case "Builiding":
            newType = "مبنى"
        case "فيلا":
            newType = "فيلا"
        case "أرض":
            newType = "أرض"
        case "شقة":
            newType = "شقة"
        case "دبلكس":
            newType = "دبلكس"
        case "مبنى":
            newType = "مبنى"
        default:
            ""
        }
        return newType
    }
    
    func translateTypeToEN(type: String) -> String{
       var newType = ""
        switch type {
        case "فيلا":
            newType = "Villa"
        case "أرض":
            return "Land"
        case "شقة":
            newType = "Apartment"
        case "دبلكس":
            newType = "Duplex"
        case "مبنى":
            newType = "Builiding"
        case "Villa":
            newType = "Villa"
        case "Land":
            return "Land"
        case "Apartment":
            newType = "Apartment"
        case "Duplex":
            newType = "Duplex"
        case "Builiding":
            newType = "Builiding"
        default:
            ""
        }
        return newType
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}
extension ViewInfo: UITextFieldDelegate{
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }}
