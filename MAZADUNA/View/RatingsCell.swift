//
//  RatingsCell.swift
//  MAZADUNA
//
//  Created by Lama 🌈🌱🍒 on 08/04/1443 AH.
//

import UIKit
import Cosmos
import Firebase
import MBProgressHUD

class RatingsCell: UITableViewCell{
    weak var viewController: UIViewController?
    @IBOutlet weak var rateSellerButton: UIButton!
    static let reuseableID = "RatingsCell"
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var star2: UIImageView!
    
    @IBOutlet weak var star5: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var viewContainer: UIView!
    // start of UI localization
    @IBOutlet weak var rateSellerLabel: UIButton!
    @IBOutlet weak var ratingsLabel: UILabel!
    
    // end of UI localization
    var totalRate = 0.0
    var count = 0.0
    var userID: String = ""
    var currentUserID: String = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupUI()
        ratingsLabel.text = NSLocalizedString("ratinges", comment: "")
        rateSellerLabel.setTitle(NSLocalizedString("rateSeller", comment: ""), for: .normal)
        guard !FirebaseManager.shared.isAnonymouse else {
            rateSellerButton.isHidden = true
                    return
                 }
        
    }
    @IBAction func ratePressed(_ sender: UIButton) {
        let alert = UIAlertController(title: NSLocalizedString("rateSeller", comment: "")+"\n\n", message: nil, preferredStyle: .actionSheet)
        
        let ratingView = CosmosView(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        
        ratingView.rating = 0.5
        ratingView.settings.starSize = 30
        //cosmosView.settings.fillMode = .Precise
        ratingView.settings.fillMode = .half
        ratingView.settings.emptyBorderColor = UIColor.black
        ratingView.settings.updateOnTouch = true
        ratingView.frame.origin.x = alert.view.frame.width/2 - 100
        ratingView.frame.origin.y = 40
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("rate", comment: ""), style: .default, handler: { (alert) in
           
            self.currentUserID = (Auth.auth().currentUser?.uid)!
            let ref = Database.database().reference().child("users").child(self.userID).child("rate").child(self.currentUserID)
            ref.setValue(ratingView.rating)
            var x = self.getRates(){ result in
                self.totalRate += result
                var y = self.getCount(){ result in
                    self.count += result
                    var rateAsDouble = self.starAsDouble(rate: self.totalRate/self.count)
                    var valueOfRate = String(format: "%.1f", rateAsDouble)
                    let refOfRate = Database.database().reference().child("users").child(self.userID).updateChildValues(["rateValue": valueOfRate])
                    self.rate.text = valueOfRate
                    self.starUI(rate: valueOfRate)
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancelAlert", comment: ""), style: .destructive, handler: nil))
        alert.view.addSubview(ratingView)
        viewController?.present(alert, animated: true, completion: nil)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func starUI(rate: String){
        let rate2 = Double(rate)
        switch rate2 ?? 0.0{
        case 0.0..<0.5:
            star1.image = UIImage(named: "star-unfill")
            star2.image = UIImage(named: "star-unfill")
            star3.image = UIImage(named: "star-unfill")
            star4.image = UIImage(named: "star-unfill")
            star5.image = UIImage(named: "star-unfill")
        case 0.5..<1.0:
            star1.image = UIImage(named: "star-halffill")
            star2.image = UIImage(named: "star-unfill")
            star3.image = UIImage(named: "star-unfill")
            star4.image = UIImage(named: "star-unfill")
            star5.image = UIImage(named: "star-unfill")
        case 1.0..<1.5:
            star1.image = UIImage(named: "star-fill")
            star2.image = UIImage(named: "star-unfill")
            star3.image = UIImage(named: "star-unfill")
            star4.image = UIImage(named: "star-unfill")
            star5.image = UIImage(named: "star-unfill")
        case 1.5..<2.0:
            star1.image = UIImage(named: "star-fill")
            star2.image = UIImage(named: "star-halffill")
            star3.image = UIImage(named: "star-unfill")
            star4.image = UIImage(named: "star-unfill")
            star5.image = UIImage(named: "star-unfill")
        case 2.0..<2.5:
            star1.image = UIImage(named: "star-fill")
            star2.image = UIImage(named: "star-fill")
            star3.image = UIImage(named: "star-unfill")
            star4.image = UIImage(named: "star-unfill")
            star5.image = UIImage(named: "star-unfill")
        case 2.5..<3.0:
            star1.image = UIImage(named: "star-fill")
            star2.image = UIImage(named: "star-fill")
            star3.image = UIImage(named: "star-halffill")
            star4.image = UIImage(named: "star-unfill")
            star5.image = UIImage(named: "star-unfill")
        case 3.0..<3.5:
            star1.image = UIImage(named: "star-fill")
            star2.image = UIImage(named: "star-fill")
            star3.image = UIImage(named: "star-fill")
            star4.image = UIImage(named: "star-unfill")
            star5.image = UIImage(named: "star-unfill")
        case 3.5..<4.00:
            star1.image = UIImage(named: "star-fill")
            star2.image = UIImage(named: "star-fill")
            star3.image = UIImage(named: "star-fill")
            star4.image = UIImage(named: "star-halffill")
            star5.image = UIImage(named: "star-unfill")
        case 4.0..<4.5:
            star1.image = UIImage(named: "star-fill")
            star2.image = UIImage(named: "star-fill")
            star3.image = UIImage(named: "star-fill")
            star4.image = UIImage(named: "star-fill")
            star5.image = UIImage(named: "star-unfill")
        case 4.5..<5.0:
            star1.image = UIImage(named: "star-fill")
            star2.image = UIImage(named: "star-fill")
            star3.image = UIImage(named: "star-fill")
            star4.image = UIImage(named: "star-fill")
            star5.image = UIImage(named: "star-halffill")
        case 5.0..<100.0:
            star1.image = UIImage(named: "star-fill")
            star2.image = UIImage(named: "star-fill")
            star3.image = UIImage(named: "star-fill")
            star4.image = UIImage(named: "star-fill")
            star5.image = UIImage(named: "star-fill")

        default:
            print("Error")
        }
    }
    func starAsDouble(rate: Double) -> Double{
        var rate2:Double = 0.0
        switch rate{
        case 0.0..<0.5:
            rate2 = 0.0
            return rate2
        case 0.5..<1.0:
            rate2 = 0.5
            return rate2
        case 1.0..<1.5:
            rate2 = 1.0
            return rate2
        case 1.5..<2.0:
            rate2 = 1.5
            return rate2
        case 2.0..<2.5:
            rate2 = 2.0
            return rate2
        case 2.5..<3.0:
            rate2 = 2.5
            return rate2
        case 3.0..<3.5:
            rate2 = 3.0
            return rate2
        case 3.5..<4.00:
            rate2 = 3.5
            return rate2
        case 4.0..<4.5:
            rate2 = 4.0
            return rate2
        case 4.5..<5.0:
            rate2 = 4.5
            return rate2
        case 5.0..<100.0:
            rate2 = 5.0
            return rate2
        default:
            return rate2
        }
    }
    func setupUI() {
        self.viewContainer.layer.cornerRadius = 8
        self.viewContainer.layer.shadowColor = UIColor.lightGray.cgColor
        self.viewContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.viewContainer.layer.shadowRadius = 6
        self.viewContainer.layer.shadowOpacity = 0.5
        rateSellerButton.layer.cornerRadius = 9
    }
    
    func getRates(completion: @escaping (_ result: Double) -> Void) -> Double{
        var result = 0.0
        let myRef = Database.database().reference().child("users").child(self.userID).child("rate")
        myRef.observeSingleEvent(of: .value, with: { (snapshot) in

            if !snapshot.exists() {
                print("Error")
                return
            }

            // data found
            let myData = snapshot.value as! [String: Any]    // the key is almost always a String
            
            for (uid, rates) in myData {
                result+=rates as! Double
            }
            print("Values in method: \(result)")
            completion(result)
        })
        return result
    }
    
    
    func getCount(completion: @escaping (_ result: Double) -> Void) -> Double{
        var result = 0.0
        let myRef = Database.database().reference().child("users").child(self.userID).child("rate")
        myRef.observeSingleEvent(of: .value, with: { (snapshot) in

            if !snapshot.exists() {
                print("Error")
                return
            }

            // data found
            let myData = snapshot.value as! [String: Any]    // the key is almost always a String
            
            for (uid, rates) in myData {
                result+=1.0
            }
            print("Count in method: \(result)")
            completion(result)

        })
        return result
    }

}
