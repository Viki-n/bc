//
//  SetBoolCell.swift
//  Bc
//
//  Created by Viki on 21/05/2018.
//  Copyright © 2018 Viki. All rights reserved.
//

import UIKit

class SetBoolCell: UITableViewCell {
    @IBOutlet weak var Label: UILabel!
    @IBOutlet weak var Switch: UISwitch!
    public var action : (Bool)->() = {_ in }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func OnSwitch(_ sender: Any) {
        action(Switch.isOn)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
