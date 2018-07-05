//
//  dPrimeMeasuringViewController.swift
//  Bc
//
//  Created by Viki on 17/06/2018.
//  Copyright © 2018 Viki. All rights reserved.
//

class MeasuringState{//General state class is getting way too complex to be further enlarged
    public static var SignalPresent = false
    public static var contrast = 0.0
    public static var Visible = false
}


import UIKit

class dPrimeMeasuringViewController: UIViewController {
    @IBOutlet weak var YesButton: UIButton!
    @IBOutlet weak var NoButton: UIButton!
    @IBOutlet weak var TopText: UILabel!
    
    @IBOutlet weak var MainImg: UIImageView!
    
    private var FalsePositives = 0
    private var Hits = 0
    private var Misses = 0
    private var CorrectRejections = 0
    private var started = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MainImg.image = getBlank()
        MeasuringState.contrast = State.GaborOpacity
        State.LastPressX = Constants.radius
        State.LastPressY = Constants.radius
        FalsePositives = 0
        Hits = 0
        Misses = 0
        CorrectRejections = 0
        YesButton.setTitle("Start", for: .normal)
        NoButton.setTitle("Start", for: .normal)
        // Do any additional setup after loading the view.
    }
    @IBAction func YesPress(_ sender: Any) {
        if(!started){
            start()
            return
        }
        if(!MeasuringState.Visible){
            evaluateTrial(response: true)
            newTrial()
        }
    }
    @IBAction func NoPress(_ sender: Any) {
        if(!started){
            start()
            return
        }
        if(!MeasuringState.Visible){
            evaluateTrial(response: false)
            newTrial()
        }
    }
    
    func start(){
        YesButton.setTitle("Yes", for: .normal)
        NoButton.setTitle("No", for: .normal)
        started = true
        TopText.text = "Press yes if you saw the Gabor, no otherwise."
        newTrial()
        
    }
    
    func evaluateTrial(response:Bool){
        var s = ""
        if response == MeasuringState.SignalPresent { //correct response
            s = "correct"
            if(response){
                Hits += 1
            } else {
                CorrectRejections += 1
            }
        } else { //incorrect response
            s = "incorrect"
            if(response){
                FalsePositives += 1
            } else {
                Misses += 1
            }
        }
        TopText.text = "Last response was "+s+". Press yes if you saw the Gabor, no otherwise.\n Hits: \(Hits), Misses: \(Misses), False alarms: \(FalsePositives), Correct rejections:\(CorrectRejections)"
        MeasuringState.SignalPresent = arc4random()%2==0
    }
    
    ///Presence of signal needs to be set first via MeasuringState.SignalPresent!
    func newTrial(){
        MeasuringState.Visible = true
        var noise = GeneratePinkNoise()
        if(MeasuringState.SignalPresent){
            let gabor = MakeGabor(Size: State.GaborSize, rotation: 45, Contrast: 1, Period: State.GaborSize/3)
            let mask = MakeGaborMask(Size: State.GaborSize, peak: MeasuringState.contrast)
            ImagePaste(Background: &noise, BackgroundWidth: Constants.radius*2, BackgroundHeight: Constants.radius*2, Image: gabor, Width: State.GaborSize, Height: State.GaborSize, Top: Constants.radius-State.GaborSize/2, Left: Constants.radius-State.GaborSize/2, Alpha: mask)
        }
        
        MainImg.image! = UIImageFromArray(source: noise, height: Constants.radius*2, width: Constants.radius*2, transformation: State.MaskFunc)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(State.showFor)/1000, execute: {
            self.MainImg.image! = getBlank()
            MeasuringState.Visible = false
        })
    }
    
    @IBAction func MeasuringDone(_ sender: Any) {
        //TODO: saving what was measured
        performSegue(withIdentifier: "MeasuringToSettings", sender: nil)
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
