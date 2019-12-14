//
//  RecordViewCell.swift
//  QuickstartApp
//
//  Created by PRAE on 3/1/19.
//  Copyright © 2019 Yevgeniy Vasylenko. All rights reserved.
//

import UIKit

class RecordViewCell: UITableViewCell {

    @IBOutlet weak var imageRecord: UIImageView!
    @IBOutlet weak var labelRecord: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
