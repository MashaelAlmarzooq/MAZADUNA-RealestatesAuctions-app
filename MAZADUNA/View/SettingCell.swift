//
//  SettingCell.swift
//  MAZADUNA
//
//  Created by Macintosh HD on 14/10/21.
//

import UIKit

class SettingCell: UITableViewCell {

    static let reuseableID = "SettingCell"
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var settingImage: UIImageView!
    @IBOutlet weak var viewContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupUI() {
        self.viewContainer.layer.cornerRadius = 8
        self.viewContainer.layer.shadowColor = UIColor.lightGray.cgColor
        self.viewContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.viewContainer.layer.shadowRadius = 6
        self.viewContainer.layer.shadowOpacity = 0.5
        
    }
}
