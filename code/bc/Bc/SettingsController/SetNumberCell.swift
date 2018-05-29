//
//  SetNumberCell.swift
//  Bc
//
//  Created by Viki on 21/05/2018.
//  Copyright © 2018 Viki. All rights reserved.
//

import UIKit

class SetNumberCell: UITableViewCell {
    @IBAction func OnEdit(_ sender: Any) {
        let num = Int(TextField.text!)
        if num == nil {
            TextField.text = String(action(0))
        } else {
            TextField.text = String(action(num!))
        }
    }
    public var action : (Int)->Int = {_ in return 0}
    @IBOutlet weak var TextField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var Label: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
