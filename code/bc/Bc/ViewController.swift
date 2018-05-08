//
//  ViewController.swift
//  bc
//
//  Created by Viki on 13/02/2018.
//  Copyright © 2018 Viki. All rights reserved.
//

import UIKit
import Accelerate

class Constants {
    public static let radius = 512
    public static let LogRadius = UInt(9)
    public static let FFTradix = FFTRadix(kFFTRadix2)
    public static let FFTsetup = vDSP_create_fftsetupD(vDSP_Length(Int(LogRadius)+Int(1)),FFTradix)!
    public static let backgroundcolor = 128
    public static let covercolor:UInt8 = 0
    public static let UncoverRadius = 300
    public static let BuffersUntilFullVolume = 4
    public static let AudioPlayer = FMSynthesizer.sharedSynth()
    public static let MultiplicativeTransparency = false //Sets the way transparency of fog adds up when windows overlap. False: maiximalistic, true:multiplicative
}

class DebugFlags{
    public static var randomNoise = true
    public static let crop = true
    public static let executeTests = false
    public static let actualGabor = true
    public static let cover = true
}

class State{
    public static var GaborX = 0
    public static var GaborY = 0
    public static var GaborSize = 50
    public static var GaborOpacity = 0.7
    public static var Uncovered = [UInt8]()
    public static var showmap = [Double]()
    public static var darkness = [UInt8](repeating:Constants.covercolor,count:Constants.radius*Constants.radius*4)
    public static var presses = 0
    public static var prevResults = [Int]()
    public static var showJustForShortTime = true
    public static var showFor = 200 //ms
    public static var LastPressX = -1
    public static var LastPressY = -1
    public static var BlankStored = false
    public static var Blank : UIImage? = nil
}

func getTopText() -> String {
    var s = ""
    for i in State.prevResults {
        if(s==""){
            s = s + String(i)
        } else {
            s = s + ", " + String(i)
        }
    }
    return """
        Presses: \(State.presses) Difficulty: \(State.GaborOpacity)
        Previous results: \(s)
        """
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
    
    
    override func viewDidLoad() {
        tests()
        super.viewDidLoad()
        TopText.text = ""
        print("first print")
        //let tap = UITapGestureRecognizer(target:self,action: #selector(ViewController.ImageTap))
        //MainImg.addGestureRecognizer(tap)
        //MainImg.isUserInteractionEnabled = true
        // Do any additional setup after loading the view, typically from a nib.
        MainImg.image = Img
        print("Print works")
        NewBackground()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touches began")
        if let touch = touches.first {
            let position=touch.location(in: MainImg)
            if position.y<0{
                DebugFlags.randomNoise = !(DebugFlags.randomNoise)
            }
            let ViewSize = MainImg.bounds.height
            let radius = Constants.radius
            let TouchDistanceX = Double(abs(CGFloat((State.GaborX+State.GaborSize/2)*Int(ViewSize)/(2*radius))-position.x))
            let TouchDistanceY = Double(abs(CGFloat((State.GaborY+State.GaborSize/2)*Int(ViewSize)/(2*radius))-position.y))
            let TouchDistance = distance(Xdiference: TouchDistanceX, Ydiference: TouchDistanceY)
          
            if TouchDistance < Double(State.GaborSize/2>20 ? State.GaborSize/2 :20) {
             //   State.GaborSize -= 1
                State.prevResults.append(State.presses)
                NewBackground()
                State.presses = 0
                
            } else {
                State.presses += 1
                print(TouchDistanceX," ",TouchDistanceY)
                let xInPx = Double(position.x)*Double(2*radius)/Double(ViewSize)
                let yInPx = Double(position.y)*Double(2*radius)/Double(ViewSize)
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
                Redraw()
                Constants.AudioPlayer.play(Float32(440*pow(2, Double(TouchDistance)/200)), modulatorFrequency: 600, modulatorAmplitude: 0, duration: 0.8)
            }
        }
        TopText.numberOfLines = 2
        TopText.text = getTopText()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func Redraw() {
        if (State.showJustForShortTime){
            if (!State.BlankStored) { //first call
                State.Blank = UIImageFromArray(source: combine(first: State.Uncovered, second:State.darkness, mask: State.showmap, length: Constants.radius*Constants.radius*4), height: Constants.radius*2, width: Constants.radius*2)
                MainImg.image! = State.Blank!
                State.BlankStored = true
            } else {
                if(State.LastPressY == -1 && State.LastPressX == -1){ //regenerating empty image
                    MainImg.image! = State.Blank!
                } else { //After an actual press
                    MainImg.image! = UIImageFromArray(source: State.Uncovered, height: Constants.radius*2, width: Constants.radius*2, transformation: SinglePressFilter)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(State.showFor)/1000, execute: {
                        self.MainImg.image! = State.Blank!
                    })
                }
            }
        } else {
        MainImg.image! = UIImageFromArray(source: combine(first: State.Uncovered, second:State.darkness, mask: State.showmap, length: Constants.radius*Constants.radius*4), height: Constants.radius*2, width: Constants.radius*2)
        }
    }
    
    @objc func NewBackground(){
        print("Touches: ",State.presses)
        State.Uncovered = GeneratePinkNoise()
        let gabor = MakeGabor(Size: State.GaborSize, rotation: 45, Contrast: 1, Period: State.GaborSize/3)
        let mask = MakeGaborMask(Size: State.GaborSize, peak: State.GaborOpacity)
        State.GaborX=Int(arc4random_uniform(UInt32(Constants.radius*2)))
        State.GaborY=Int(arc4random_uniform(UInt32(Constants.radius*2)))
        while (sqr(State.GaborX+State.GaborSize/2-Constants.radius)+sqr(State.GaborY-Constants.radius+State.GaborSize/2)>sqr(Constants.radius-State.GaborSize)){
            State.GaborX=Int(arc4random_uniform(UInt32(Constants.radius*2)))
            State.GaborY=Int(arc4random_uniform(UInt32(Constants.radius*2)))
        }
        ImagePaste(Background: &State.Uncovered, BackgroundWidth: Constants.radius*2, BackgroundHeight: Constants.radius*2, Image: gabor, Width: State.GaborSize, Height: State.GaborSize, Top: State.GaborY, Left: State.GaborX, Alpha: mask)
        //Background drawing finished!
        State.showmap = getStartingShowmap()
        State.LastPressX = -1
        State.LastPressY = -1
        Redraw()
    }
    
    

}


        
var Img = UIImage()
