//
//  MainMenuViewController.swift
//  Bc
//
//  Created by Viki on 28/05/2018.
//  Copyright © 2018 Viki. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {
    @IBOutlet weak var TextField: UITextField!
    @IBAction func NameSet(_ sender: Any) {
        State.subject = TextField.text!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TextField.text = State.subject
        SetScreen(screen: "Menu")
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
