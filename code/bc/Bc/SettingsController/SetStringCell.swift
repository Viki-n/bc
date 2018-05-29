//
//  SetStringCell.swift
//  Bc
//
//  Created by Viki on 21/05/2018.
//  Copyright © 2018 Viki. All rights reserved.
//

import UIKit

class SetStringCell: UITableViewCell {
    @IBOutlet weak var Label: UILabel!
    @IBOutlet weak var TextField: UITextField!
    public var action : (String)->String = {_ in return ""}
    
    @IBAction func OnEdit(_ sender: Any) {
        TextField.text = action(TextField.text!)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
