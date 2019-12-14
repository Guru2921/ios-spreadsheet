//
//  RecordEditViewCell.swift
//  QuickstartApp
//
//  Created by PRAE on 3/3/19.
//  Copyright © 2019 Yevgeniy Vasylenko. All rights reserved.
//

import UIKit

class RecordEditViewCell: UITableViewCell {

    @IBOutlet weak var imageEditField: UIImageView!
    
    @IBOutlet weak var labelEditField: UILabel!
    
    @IBOutlet weak var textEditField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
