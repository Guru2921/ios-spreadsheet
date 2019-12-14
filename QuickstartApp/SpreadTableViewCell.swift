//
//  SpreadTableViewCell.swift
//  QuickstartApp
//
//  Created by PRAE on 2/28/19.
//  Copyright © 2019 Yevgeniy Vasylenko. All rights reserved.
//

import UIKit

class SpreadTableViewCell: UITableViewCell {

  
    @IBOutlet weak var imageSpread: UIImageView!
    @IBOutlet weak var labelSpread: UILabel!
    @IBOutlet weak var buttonFav: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
