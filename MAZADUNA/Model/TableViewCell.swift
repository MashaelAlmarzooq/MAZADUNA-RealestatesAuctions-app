//
//  TableViewCell.swift
//  MAZADUNA
//
//  Created by Macintosh HD on 19/09/2021.
//

import UIKit
import Kingfisher

class TableViewCell: UITableViewCell {

 
    @IBOutlet weak var lab1: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var viewMoreButton: UIButton!
    @IBOutlet weak var deletePostButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    var post: Post? {
        didSet {
            viewMoreButton.layer.cornerRadius=9
            self.lab1.text = self.post?.state
            self.location.text = self.post?.location
            self.img.kf.setImage(with: URL(string: self.post?.image[0] ?? ""))
            let isLiked = MZUser.shared.favouritePosts.contains(self.post?.postID ?? "")
            self.likeButton.isHidden = FirebaseManager.shared.isAnonymouse
            self.likeButton.layer.borderColor = isLiked ? UIColor().hex("#E74C3C").cgColor :  UIColor().hex("#CCCCCC").cgColor
            self.likeButton.setImage(isLiked ? #imageLiteral(resourceName: "like") : #imageLiteral(resourceName: "unlike"), for: .normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.likeButton.layer.cornerRadius = self.likeButton.frame.height/2
        self.likeButton.layer.borderWidth = 1
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.likeButton.layer.borderColor = UIColor().hex("#CCCCCC").cgColor
        self.likeButton.setImage(#imageLiteral(resourceName: "unlike"), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
}
