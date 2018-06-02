//
//  DisplayLogViewController.swift
//  Bc
//
//  Created by Viki on 02/06/2018.
//  Copyright © 2018 Viki. All rights reserved.
//

import UIKit

class DisplayLogViewController: UIViewController {
    @IBOutlet weak var TextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var s = ""
        for i in State.log{
            s = s + i.ToString()
        }
        TextView.text = s
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
