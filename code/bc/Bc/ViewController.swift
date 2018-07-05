//
//  ViewController.swift
//  bc
//
//  Created by Viki on 13/02/2018.
//  Copyright © 2018 Viki. All rights reserved.
//

import UIKit
//import Accelerate


func getTopText() -> String {
    if State.GaborLocated{
        return "Click at the location where you think you saw the Gabor."
    } else if State.RedrawOnClick || State.ShowScore{
        return "Gabor was located with an error of \(State.PreviousAccuracy) px. Now you can see where exactly was it. Click again anywhere within the noise or at the button in the bottom left to start a new game."
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
            Presses: \(State.presses) Difficulty: \(Int(floor(State.GaborOpacity*1000))) Last accuracy: \(State.PreviousAccuracy) Trial number:\(State.currentTrial.TrialNumber) \(State.CalculatingScore ? "Score: " + String(State.Score) : "" )
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
    @IBOutlet weak var BottomLeftButton: UIButton!
    @IBOutlet weak var CenterText: UILabel!
    
    @IBAction func LocatedButton(_ sender: Any) {
        if (State.ShowScore){
            ShowScore()
        } else if (!(State.RedrawOnClick||State.GaborLocated||State.presses == 0)){
            State.GaborLocated = true
            DrawNoise()
            TopText.text = getTopText()
        } else if (State.RedrawOnClick) {
            State.RedrawOnClick = false
            NewBackground()
            TopText.text = getTopText()
            CenterText.text = ""
            BottomLeftButton.setTitle("Gabor was located", for: UIControlState.normal)
        }
    }
    
    override func viewDidLoad() {
        if(State.ShowScore){
            State.RedrawOnClick = true
            State.ShowScore = false
        }
        CenterText.text = ""
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
            if State.ShowScore{
                ShowScore()
            } else if State.RedrawOnClick {//Genereating new background
                State.RedrawOnClick = false
                CenterText.text = ""
                NewBackground()
                BottomLeftButton.setTitle("Gabor was located", for: UIControlState.normal)
            } else if distance(X1: xInPx, Y1: yInPx, X2: Double(radius), Y2: Double(radius))>Double(radius) {
                //Do nothing, clicked outside the noise
            } else if State.GaborLocated { //Area was uncovered, subject guessed where gabor was
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
                if (!State.CalculatingScore){
                    State.RedrawOnClick = true
                } else {
                    State.ShowScore = true
                }
                BottomLeftButton.setTitle("Next trial", for: UIControlState.normal)
            } else {//Normal press
                let location = point(Int(xInPx),Int(yInPx))
                NormalPress(Location: location)
                Redraw(ForcedBlank: false)
            }
        }
        TopText.numberOfLines = 3
        TopText.text = getTopText()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func NormalPress(Location:point){
        let xInPx = Location.x
        let yInPx = Location.y
        State.presses += 1
        State.currentTrial.fixations.append(point(Int(xInPx),Int(yInPx)))
        State.LastPressX = Int(xInPx)
        State.LastPressY = Int(yInPx)
        MakeSound(Location: Location)
        State.elm.Update(Fixated: Location)
        
        //Rest of this procedure is here for debug purposes only
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
    }
    
    func ShowScore(){
        State.ShowScore = false
        State.RedrawOnClick = true
        let score = State.PreviousAccuracy <= State.AccuracyThreshold ? Int((1-State.GaborOpacity)*1000/Double(State.prevResults[State.prevResults.count-1])) : 0
        State.Score += score
        MainImg.image = GetGrey()
        CenterText.text = "Your score is \(score)."
    }
    
    func MakeSound(Location:point){
        var tone = 0.0
        let value = State.elm.GetValue(location: Location)
        switch(State.SoundMode){
        case 0://Only partially relative
            tone = 2-((value - State.elm.minvalue) / (State.elm.maxvalue - State.elm.minvalue) * 2)
            if(tone<0){tone = 0}
            if(tone>2){tone = 2}
        case 1://Fully relative
            var all = 0
            var better = 0
            for i in State.elm.Values{
                all += 1
                if(i>value){
                    better += 1
                }
            }
            tone = Double(better)/Double(all)*2
        default:
            break
        }
        MakeScaledSound(Tone: tone)
    }
    
    ///Zero means c1, difference by 1 is difference by an octave

    
    
    func Redraw(ForcedBlank:Bool) {
        if (State.showJustForShortTime){
            if(ForcedBlank || (State.LastPressY == -1 && State.LastPressX == -1 )){ //regenerating empty image
                    MainImg.image! = getBlank()
                } else {
                    MainImg.image! = UIImageFromArray(source: State.Uncovered, height: Constants.radius*2, width: Constants.radius*2, transformation: State.MaskFunc)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(State.showFor)/1000, execute: {
                        if(!(State.GaborLocated || State.RedrawOnClick)){
                            self.MainImg.image! = getBlank()
                        }
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
        GameController()
        State.Uncovered = GeneratePinkNoise()
        State.noise = State.Uncovered
        let gabor = MakeGabor(Size: State.GaborSize, rotation: 45, Contrast: 1, Period: State.GaborSize/3)
        let mask = MakeGaborMask(Size: State.GaborSize, peak: State.GaborOpacity)
        State.GaborIndex = Int(arc4random_uniform(UInt32(State.PossibleLocations.count)))
        let p = State.PossibleLocations[State.GaborIndex]
        State.GaborX=p.x-State.GaborSize/2
        State.GaborY=p.y-State.GaborSize/2
        ImagePaste(Background: &State.Uncovered, BackgroundWidth: Constants.radius*2, BackgroundHeight: Constants.radius*2, Image: gabor, Width: State.GaborSize, Height: State.GaborSize, Top: State.GaborY, Left: State.GaborX, Alpha: mask)
        //Background drawing finished!
        State.showmap = getStartingShowmap()
        State.LastPressX = -1
        State.LastPressY = -1
        State.elm.Reset()
        State.presses = 0
        Redraw(ForcedBlank: false)
    }
    
    func GameController(){
        let num = State.currentTrial.TrialNumber
        if (num==1||num == 1+State.FirstAndThirdTest||num==1+State.FirstAndThirdTest+State.SecondTest){
            State.GaborOpacity = State.DefaultGaborOpacity
            State.ResponseCounter = 0
            return
        }
        if (State.presses <= State.FixationLimit && State.PreviousAccuracy <= State.AccuracyThreshold){
            State.ResponseCounter = max(State.ResponseCounter,0)
            State.ResponseCounter += 1
            if(State.ResponseCounter == State.ReponsesBeforeChange){
                State.GaborOpacity -= Double(State.ChangeDifficultyBy)/1000
                State.GaborOpacity = max(State.GaborOpacity, 0)
                State.ResponseCounter = 0
            }
        } else {
            State.ResponseCounter = min(State.ResponseCounter,0)
            State.ResponseCounter -= 1
            if(State.ResponseCounter == -State.ReponsesBeforeChange){
                State.GaborOpacity += Double(State.ChangeDifficultyBy)/1000
                State.GaborOpacity = min(State.GaborOpacity, 1)
                State.ResponseCounter = 0
            }
        }
        State.currentTrial.difficulty = State.GaborOpacity
    }

}
