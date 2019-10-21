//
//  GateTableViewCell.swift
//  gatewait
//
//  Created by Danil on 16.10.2019.
//  Copyright © 2019 Danil Chernyshev. All rights reserved.
//

import UIKit

class GateTableViewCell: UITableViewCell {
    
    @IBOutlet weak var gateLabel: UILabel!
    
    @IBOutlet weak var flightsAmount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
