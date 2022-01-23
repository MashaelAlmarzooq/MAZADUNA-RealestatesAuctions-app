//
//  PickedImageCell.swift
//  MAZADUNA
//
//  Created by Tahani Alsubaie on 22/10/21.
//

import UIKit

class PickedImageCell: UICollectionViewCell {

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var pickedImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.deleteButton.layer.cornerRadius = self.deleteButton.frame.height / 2
        self.pickedImage.layer.cornerRadius = 5
    }

}
