//
//  SheetViewCell.swift
//  QuickstartApp
//
//  Created by PRAE on 3/1/19.
//  Copyright © 2019 Yevgeniy Vasylenko. All rights reserved.
//

import UIKit

class SheetViewCell: UITableViewCell {

    @IBOutlet weak var imageSheet: UIImageView!
    @IBOutlet weak var labelSheet: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
