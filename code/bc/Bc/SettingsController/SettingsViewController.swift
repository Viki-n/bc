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
    case title
}

class cellInfo {
    public var label = ""
    public var type = cellType.bool
    public var getStringValue : () -> String = {return ""}
    public var getBoolValue : () -> Bool = {return false}
    public var getNumericValue : () -> Int = {return 0}
    public var setStringValue : (String) -> String = {_ in return ""}
    public var setBoolValue : (Bool) -> () = {_ in }
    public var setNumericValue : (Int) ->Int = {_ in return 0}
    public var action : () -> () = {}
    
    init(text:String,get:@escaping ()->String,set:@escaping (String)->String){
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
    init(text:String,get:@escaping ()->Int,set:@escaping (Int)->Int){
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
    init(text:String) {
        type = cellType.title
        label = text
    }
}

class SettingsViewController: UITableViewController {
    var items = [cellInfo]()
    
    func FillCellInfo() {
        items.append(cellInfo(text: "General settings"))
        
        items.append(cellInfo(text: "Difficulty (0 = impossible, 1000 = easiest)", get: {return Int(State.GaborOpacity*1000)}, set: {v in let x = Double(min(1000,max(0,v)))/1000; State.GaborOpacity = x; State.DefaultGaborOpacity = x; return Int(x*1000)}))
        items.append(cellInfo(text: "Gabor patch diameter", get: {return State.GaborSize}, set:{v in State.GaborSize = max(1,v); return max(1,v)}))
        items.append(cellInfo(text: "Radius of uncovered area", get: {return Constants.UncoverRadius}, set: {v in Constants.UncoverRadius = max(1,v); return max(1,v)}))
        items.append(cellInfo(text: "Area uncovered for (ms)", get: {return State.showFor}, set: {v in State.showFor = max(1,v); return max(1,v)}))
        items.append(cellInfo(text: "Area uncovered for brief period only", get: {return State.showJustForShortTime}, set:{v in State.showJustForShortTime = v}))
        items.append(cellInfo(text: "Sound fully relative", get: {return State.SoundMode==1}, set:{v in State.SoundMode = v ? 1 : 0}))
        items.append(cellInfo(text: "Possible location distance", get: {return State.PossibleLocationsDistance}, set: {v in
            let h = max(v,60)
            State.PossibleLocationsDistance = h
            CalculatePossibleLocations(d: h)
            return h
        }))
    
        items.append(cellInfo(text: "Regenerate noise", get:{return State.GenerateBackgroundOnEntry}, set:{v in State.GenerateBackgroundOnEntry = v}))
        items.append(cellInfo(text: "Preview", press: {self.performSegue(withIdentifier: "ShowPreview", sender: nil)} ))
        items.append(cellInfo(text: "Start game", press: {self.performSegue(withIdentifier: "SettingsToGame", sender: nil)}))
        items.append(cellInfo(text: "Back to main menu", press:{self.performSegue(withIdentifier: "SettingsToMainMenu", sender: nil)}))
        
        
        
        
        items.append(cellInfo(text: "Gamification settings"))
        items.append(cellInfo(text: "Trials in first and third test", get: {return State.FirstAndThirdTest }, set: {v in let x=max(v,1); State.FirstAndThirdTest=x;return x}))
        items.append(cellInfo(text: "Trials in second test", get: {return State.SecondTest }, set: {v in let x=max(v,1); State.SecondTest=x;return x}))
        items.append(cellInfo(text: "Correct/wrong responses in row before difficulty changes", get: {return State.ReponsesBeforeChange }, set: {v in let x=max(v,1); State.ReponsesBeforeChange=x;return x}))
        items.append(cellInfo(text: "Difficulty changed by", get: {return State.ChangeDifficultyBy }, set: {v in let x=max(v,1); State.ChangeDifficultyBy=x;return x}))
        items.append(cellInfo(text: "Accuracy threshold", get: {return State.AccuracyThreshold }, set: {v in let x=max(v,1); State.AccuracyThreshold = x;return x}))
        items.append(cellInfo(text: "Maximal amount of fixations for succesful trial", get: {return State.FixationLimit }, set: {v in let x=max(v,1); State.FixationLimit = x;return x}))
        items.append(cellInfo(text: "Calculate score?", get: {return State.CalculatingScore}, set: {v in State.CalculatingScore = v;if(v){State.Score = 0}}))
        
        
        
        
        
        items.append(cellInfo(text: "d’ map constants settings"))
        items.append(cellInfo(text: "Foveal detectability (x100)", get: {return Int(100*State.dPrimeZero)}, set: {v in let u = v<1 ? 1 : v;State.dPrimeZero = Double(u)/100; return u}))
        items.append(cellInfo(text: "Left side visibility", get: {return Int(State.eLeft)}, set: {v in
            var param = v
            if (param<1){
                param = 1
            }
            State.eLeft = Double(param)
            State.dMapActual = false
            return param
        }))
        items.append(cellInfo(text: "Right side visibility", get: {return Int(State.eRight)}, set: {v in
            var param = v
            if (param<1){
                param = 1
            }
            State.eRight = Double(param)
            State.dMapActual = false
            return param
        }))
        items.append(cellInfo(text: "Upper visibility", get: {return Int(State.eUpwards)}, set: {v in
            var param = v
            if (param<1){
                param = 1
            }
            State.eUpwards = Double(param)
            State.dMapActual = false
            return param
        }))
        items.append(cellInfo(text: "Lower visibility", get: {return Int(State.eDownwards)}, set: {v in
            var param = v
            if (param<1){
                param = 1
            }
            State.eDownwards = Double(param)
            State.dMapActual = false
            return param
        }))
        items.append(cellInfo(text: "Function steepness (exponent times 100)", get: {return Int(State.FunctionSteepnes*100)}, set: {v in
            var param = v
            if (param<100){
                param = 100
            }
            State.FunctionSteepnes = Double(param)/100
            State.dMapActual = false
            return param
        }))
        items.append(cellInfo(text: "Recalculate d’ map", press: {MakeDMap()
            let ac = UIAlertController(title: "Done!", message: "d’ map was succesfully calculated!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)        }))
        items.append(cellInfo(text: "Use d’ map", get: {return State.dMapBeingUsed}, set:{v in
            State.dMapBeingUsed = v
            if v{
                State.MaskFunc = DPrimePressFilter
            } else {
                State.MaskFunc = SimpleCircularSinusoidPressFilter
            }
        }))
        items.append(cellInfo(text: "Subject settings"))
        items.append(cellInfo(text: "Name", get: {return State.SubjectName}, set:{ value in State.SubjectName = value
            State.currentTrial.subject = value
            State.currentTrial.TrialNumber = 1 + findLastTrial(log: State.log, subject: value)
            State.CurrentSubject = GetSubject(name:value)
            return value
        }))
        items.append(cellInfo(text: "Feedback", get: {return State.CurrentSubject.Feedback == FeedbackType.ELM}, set: {v in
            if v {
                State.CurrentSubject.Feedback = .ELM
            } else {
                State.CurrentSubject.Feedback = .None
            }
        }))
      
        items.append(cellInfo(text: "Measure detectability", press:{self.performSegue(withIdentifier: "SettingsToMeasuring", sender: nil)}))
        
        items.append(cellInfo.init(text: "Logging"))
        items.append(cellInfo.init(text: "See log", press: {self.performSegue(withIdentifier: "SettingsToLog", sender: nil)}))
        items.append(cellInfo.init(text: "Data deletion enabled", get: {State.DataDeletionEnabled = false; return false}, set: {v in State.DataDeletionEnabled = v}))
        items.append(cellInfo(text: "Delete all data", press: {
            if State.DataDeletionEnabled{
                State.log = [trial]()
                logger.SaveLog()
                let ac = UIAlertController(title: "Deleted!", message: "All your data was succesfully deleted!", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
            } else {
                let ac = UIAlertController(title: "Error!", message: "You have to enable data deletion first!", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
            }
        }))
        items.append(cellInfo(text: "Debug flags"))
        items.append(cellInfo(text: "Generate noise", get: {DebugFlags.randomNoise},set: {v in DebugFlags.randomNoise = v}))
        items.append(cellInfo(text: "Display locations", get: {return DebugFlags.ShowTargets}, set: {v in DebugFlags.ShowTargets = v}))
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (items.count == 0){
            FillCellInfo()
        }
        SetScreen(screen:"Settings")
        InitApp()
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
        case .title:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as! TitleCell
            cell.Label.text = info.label
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     if(State.dMapBeingUsed && !State.dMapActual){
     let ac = UIAlertController(title: "Warning!", message: "d’ map was not recalculated after editing its parameters. Do not leave settings before having it recalculated.", preferredStyle: .alert)
     ac.addAction(UIAlertAction(title: "OK", style: .default))
     self.present(ac, animated: true)}
     }
    

}
