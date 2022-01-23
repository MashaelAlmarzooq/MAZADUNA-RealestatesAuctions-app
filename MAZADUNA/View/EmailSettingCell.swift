//
//  EmailSettingCell.swift
//  MAZADUNA
//
//  Created by Tahani Alsubaie on 14/10/21.
//

import UIKit

class EmailSettingCell: UITableViewCell {

    static let reuseableID = "EmailSettingCell"
    // start of UI localize
    @IBOutlet weak var emailTextLabel: UILabel!
    @IBOutlet weak var phoneTextLabel: UILabel!
    // end of UI localize
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var emailStackView: UIStackView!
    @IBOutlet weak var phoneStackView: UIStackView!
    
    var isLoggedUser: Bool = true {
        didSet {
            self.phoneStackView.isHidden = !self.isLoggedUser
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupUI()
        self.LocalizeVC()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func LocalizeVC(){
        emailTextLabel.text = NSLocalizedString("profileEmail", comment: "")
        phoneTextLabel.text = NSLocalizedString("profilePhone", comment: "")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        var email = UserDefaults.standard.value(forKey: "Email") as? String ?? ""
        var phone = UserDefaults.standard.value(forKey: "PhoneNumber") as? String ?? ""
        if !self.isLoggedUser {
            email = "N/A"
            phone = "N/A"
        }
        self.emailStackView.isHidden = email.isEmpty
        self.emailLabel.text = email
        self.mobileLabel.text = phone
    }
    
    func setupUI() {
        self.viewContainer.layer.cornerRadius = 8
        self.viewContainer.layer.shadowColor = UIColor.lightGray.cgColor
        self.viewContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.viewContainer.layer.shadowRadius = 6
        self.viewContainer.layer.shadowOpacity = 0.5
        var email = UserDefaults.standard.value(forKey: "Email") as? String ?? ""
        var phone = UserDefaults.standard.value(forKey: "PhoneNumber") as? String ?? ""
        if !self.isLoggedUser {
            email = "N/A"
            phone = "N/A"
        } else {
            self.phoneStackView.isHidden = false
        }
        self.emailStackView.isHidden = email.isEmpty
        self.emailLabel.text = email
        self.mobileLabel.text = phone
    }
    
}
