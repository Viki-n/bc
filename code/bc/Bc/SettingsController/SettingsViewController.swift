//
//  SettingsViewController.swift
//  Bc
//
//  Created by Viki on 21/05/2018.
//  Copyright © 2018 Viki. All rights reserved.
//

import UIKit

enum cellType {
    case bool
    case number
    case string
    case button
}

class cellInfo {
    public var label = ""
    public var type = cellType.bool
    public var getStringValue : () -> String = {return ""}
    public var getBoolValue : () -> Bool = {return false}
    public var getNumericValue : () -> Int = {return 0}
    public var setStringValue : (String) -> () = {_ in }
    public var setBoolValue : (Bool) -> () = {_ in }
    public var setNumericValue : (Int) -> () = {_ in }
    public var action : () -> () = {}
    
    init(text:String,get:@escaping ()->String,set:@escaping (String)->()){
        type = cellType.string
        label = text
        getStringValue = get
        setStringValue = set
    }
    init(text:String,get:@escaping ()->Bool,set:@escaping (Bool)->()){
        type = cellType.bool
        label = text
        getBoolValue = get
        setBoolValue = set
    }
    init(text:String,get:@escaping ()->Int,set:@escaping (Int)->()){
        type = cellType.number
        label = text
        getNumericValue = get
        setNumericValue = set
    }
    init(text:String,press:@escaping ()->()){
        type = cellType.button
        label = text
        action = press
    }
}

class SettingsViewController: UITableViewController {
    var items = [cellInfo]()
    
    func FillCellInfo() {
        items.append(cellInfo(text: "Subject", get: {return State.subject}, set:{ value in State.subject = value }))
        items.append(cellInfo(text: "Preview", press: {self.performSegue(withIdentifier: "ShowPreview", sender: nil)} ))
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (items.count == 0){
            FillCellInfo()
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let info = items[indexPath.row]
        var c : UITableViewCell? = nil
        switch (info.type){
        case cellType.bool:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BoolCell", for: indexPath) as! SetBoolCell
            cell.Label.text = info.label
            cell.Switch.isOn = info.getBoolValue()
            cell.action = info.setBoolValue
            c = cell
        case cellType.number:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NumberCell", for: indexPath) as! SetNumberCell
            cell.Label.text = info.label
            cell.TextField.text = String(info.getNumericValue())
            cell.action = info.setNumericValue
            c = cell
        case cellType.string:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StringCell", for: indexPath) as! SetStringCell
            cell.Label.text = info.label
            cell.TextField.text = info.getStringValue()
            cell.action = info.setStringValue
            c = cell
        case .button:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath) as! ButtonCell
            cell.action = info.action
            cell.Button.setTitle(info.label, for: UIControlState.normal)
            c = cell
        }
        
        

        // Configure the cell...

        return c!
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
