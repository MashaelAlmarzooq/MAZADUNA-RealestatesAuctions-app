//
//  NeighbourCommentTableCell.swift
//  MAZADUNA
//
//  Created by Macintosh HD on 03/12/21.
//

import UIKit

class NeighbourCommentTableCell: UITableViewCell {

    static let reuseableID = "NeighbourCommentTableCell"
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var viewContainer: UIView!
    var comment: NeighbourHoodComment? {
        didSet {
            guard let comment = self.comment else { return }
            self.commentLabel.text = comment.comment
            self.dateLabel.text = comment.date
            self.deleteButton.isHidden = comment.userID != MZUser.shared.userID || FirebaseManager.shared.isAnonymouse
        }
    }
    
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
        self.deleteButton.layer.cornerRadius = self.deleteButton.frame.height / 2
        self.deleteButton.clipsToBounds = true
        self.deleteButton.setTitle("", for: .normal)
        self.deleteButton.setTitle("", for: .highlighted)
        self.deleteButton.setImage(UIImage(named: "cancel"), for: .normal)
        self.deleteButton.setImage(UIImage(named: "cancel"), for: .highlighted)
    }
}
