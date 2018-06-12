//
//  ViewController.swift
//  bc
//
//  Created by Viki on 13/02/2018.
//  Copyright © 2018 Viki. All rights reserved.
//

import UIKit
import Accelerate


func getTopText() -> String {
    if State.GaborLocated{
        return "Click at the location where you think you saw the Gabor."
    } else if State.RedrawOnClick{
        return "Gabor was located with an error of \(State.PreviousAccuracy) px. Now you can see where exactly was it. Click again anywhere within the noise to start a new game."
    } else {
        var s = ""
        for i in State.prevResults {
            if(s==""){
                s = s + String(i)
            } else {
                s = s + ", " + String(i)
            }
        }
        return """
            Presses: \(State.presses) Difficulty: \(Int(floor(State.GaborOpacity*1000))) Last accuracy: \(State.PreviousAccuracy)
            Previous results: \(s)
            """
    }
}

func getStartingShowmap()->[Double]{
    if(DebugFlags.cover){
    var output = [Double]()
    let radius=Constants.radius
    for i in 0..<radius*2{
        for i1 in 0..<radius*2{
            let distance = sqrt(Double(sqr(i-radius)+sqr(i1-radius)))
            output.append((distance>Double(radius)) ? 1 : 0)
        }
    }
    return output
    } else {
        return [Double](repeating:1,count:sqr(Constants.radius*2))
    }
}
        


func tests(){
if DebugFlags.executeTests {
    var a = [Double(1),2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10,11,12,13,14,15,16]
    var b = a
    let c = a
    a[2] = 18
    print(b[2])
    print(c[2])
    }
}




class ViewController: UIViewController {
    @IBOutlet weak var MainImg: UIImageView!
    @IBOutlet weak var TopText: UILabel!
    
    @IBAction func LocatedButton(_ sender: Any) {
        State.GaborLocated = true
        DrawNoise()
        TopText.text = getTopText()
    }
    
    override func viewDidLoad() {
        tests()
        super.viewDidLoad()
        TopText.text = getTopText()
        MainImg.image = getBlank()
        CalculatePossibleLocations(d: State.PossibleLocationsDistance)
        if(State.GenerateBackgroundOnEntry || State.RedrawOnClick){
            State.GenerateBackgroundOnEntry = false
            State.RedrawOnClick = false
            State.GaborLocated = false
            NewBackground()
            State.currentTrial = trial()
            State.presses = 0
        } else if State.GaborLocated {
            DrawNoise()
        } else {
            Redraw(ForcedBlank: true)
        }
        SetScreen(screen: "Game")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touches began")
        if let touch = touches.first {
            let position=touch.location(in: MainImg)
            let ViewSize = MainImg.bounds.height
            let radius = Constants.radius
            let TouchDistanceX = Double(abs(CGFloat((State.GaborX+State.GaborSize/2)*Int(ViewSize)/(2*radius))-position.x))
            let TouchDistanceY = Double(abs(CGFloat((State.GaborY+State.GaborSize/2)*Int(ViewSize)/(2*radius))-position.y))
            let TouchDistance = distance(Xdiference: TouchDistanceX, Ydiference: TouchDistanceY)
            let xInPx = Double(position.x)*Double(2*radius)/Double(ViewSize)
            let yInPx = Double(position.y)*Double(2*radius)/Double(ViewSize)
            if State.RedrawOnClick {
                State.RedrawOnClick = false
                State.presses = 0
                TopText.text = "New background is being generated..."
                NewBackground()
            } else if distance(X1: xInPx, Y1: yInPx, X2: Double(radius), Y2: Double(radius))>Double(radius) {
                //Do nothing, clicked outside the noise
            } else if State.GaborLocated {
             //   State.GaborSize -= 1
                State.PreviousAccuracy = Int(TouchDistance)
                State.GaborLocated = false
                State.prevResults.append(State.presses)
                State.currentTrial.attempts = State.presses
                State.currentTrial.TargetDistance = Int(TouchDistance)
                State.currentTrial.Gabor = point(State.GaborX,State.GaborY)
                State.log.append(State.currentTrial)
                logger.SaveLog()
                State.currentTrial = trial()
                DrawUncovered()
                State.RedrawOnClick = true
            } else {
                State.presses += 1
                print(TouchDistanceX," ",TouchDistanceY)

                State.currentTrial.fixations.append(point(Int(xInPx),Int(yInPx)))
                State.LastPressX = Int(xInPx)
                State.LastPressY = Int(yInPx)
                if(!State.showJustForShortTime){
                    for i in Int(xInPx)-Constants.UncoverRadius..<Int(xInPx)+Constants.UncoverRadius{
                        if(i<0){continue}
                        if(i>=Constants.radius*2){continue}
                        for i1 in Int(yInPx)-Constants.UncoverRadius..<Int(yInPx)+Constants.UncoverRadius{
                            if(i1<0){continue}
                            if(i1>=Constants.radius*2){continue}
                            let indexinarray = i+i1*Constants.radius*2
                            let distancefromtouch = sqrt(Double(sqr(i-Int(xInPx))+sqr(i1-Int(yInPx))))
                            if(distancefromtouch>Double(Constants.UncoverRadius)){continue}
                            if(Constants.MultiplicativeTransparency){
                                State.showmap[indexinarray] = 1-((1-State.showmap[indexinarray])*(0.5 - 0.5*cos(.pi*distancefromtouch/Double(Constants.UncoverRadius))))
                            } else {
                                State.showmap[indexinarray] = max(State.showmap[indexinarray],(0.5 +    0.5*cos(.pi*distancefromtouch/Double(Constants.UncoverRadius))))
                            }
                        }
                    }
                }
                Redraw(ForcedBlank: false)
                Constants.AudioPlayer.play(Float32(440*pow(2, Double(TouchDistance)/200)), modulatorFrequency: 600, modulatorAmplitude: 0, duration: 0.8)
            }
        }
        TopText.numberOfLines = 3
        TopText.text = getTopText()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func Redraw(ForcedBlank:Bool) {
        if (State.showJustForShortTime){
            if(ForcedBlank || (State.LastPressY == -1 && State.LastPressX == -1 )){ //regenerating empty image
                    MainImg.image! = getBlank()
                } else {
                    MainImg.image! = UIImageFromArray(source: State.Uncovered, height: Constants.radius*2, width: Constants.radius*2, transformation: State.MaskFunc)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(State.showFor)/1000, execute: {
                    self.MainImg.image! = getBlank()
                })
            }
            
        } else {
        MainImg.image! = UIImageFromArray(source: combine(first: State.Uncovered, second:State.darkness, mask: State.showmap, length: Constants.radius*Constants.radius*4), height: Constants.radius*2, width: Constants.radius*2)
        }
    }
    
    func DrawNoise(){
        MainImg.image! = UIImageFromArray(source: State.noise, height: Constants.radius*2, width: Constants.radius*2)
    }
    
    func DrawUncovered(){
        MainImg.image! = UIImageFromArray(source: State.Uncovered, height: Constants.radius*2, width: Constants.radius*2)
    }
    
    @objc func NewBackground(){
        print("Touches: ",State.presses)
        State.Uncovered = GeneratePinkNoise()
        State.noise = State.Uncovered
        let gabor = MakeGabor(Size: State.GaborSize, rotation: 45, Contrast: 1, Period: State.GaborSize/3)
        let mask = MakeGaborMask(Size: State.GaborSize, peak: State.GaborOpacity)
        let p = State.PossibleLocations[Int(arc4random_uniform(UInt32(State.PossibleLocations.count)))]
        State.GaborX=p.x-State.GaborSize/2
        State.GaborY=p.y-State.GaborSize/2
        ImagePaste(Background: &State.Uncovered, BackgroundWidth: Constants.radius*2, BackgroundHeight: Constants.radius*2, Image: gabor, Width: State.GaborSize, Height: State.GaborSize, Top: State.GaborY, Left: State.GaborX, Alpha: mask)
        //Background drawing finished!
        State.showmap = getStartingShowmap()
        State.LastPressX = -1
        State.LastPressY = -1
        Redraw(ForcedBlank: false)
    }
    
    

}
