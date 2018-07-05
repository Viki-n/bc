//
//  PreviewViewController.swift
//  Bc
//
//  Created by Viki on 21/05/2018.
//  Copyright © 2018 Viki. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var Label: UILabel!
    
    var state = 0
    var noise = [UInt8]()
    var uncoveredCenter = UIImage()
    var img = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        InitApp()
        state = 0
        SetScreen(screen: "Preview")
        Redraw()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        state += 1
        Redraw()
    }
    
    func Redraw(){
        let diameter = Constants.radius*2
        switch state {
        case 0:
            noise = GeneratePinkNoise()
            img = UIImageFromArray(source: noise, height: Constants.radius*2, width: Constants.radius*2)
            self.Image.image = img
            Label.text = "This is pink noise."
        case 1:
            let gabor = MakeGabor(Size: State.GaborSize, rotation: 45, Contrast: 1, Period: State.GaborSize/3)
            let mask = MakeGaborMask(Size: State.GaborSize, peak: State.GaborOpacity)
            ImagePaste(Background: &noise, BackgroundWidth: Constants.radius*2, BackgroundHeight: Constants.radius*2, Image: gabor, Width: State.GaborSize, Height: State.GaborSize, Top: Constants.radius-(State.GaborSize/2), Left: Constants.radius-(State.GaborSize/2), Alpha: mask)
            let myimg = UIImageFromArray(source: noise, height: Constants.radius*2, width: Constants.radius*2)
            self.Image.image = myimg
            Label.text = "In the middle, there is a gabor patch."
        case 2:
            self.Image.image = getBlank()
            Label.text = "But the noise is covered."
        case 3:
            State.LastPressX = Constants.radius
            State.LastPressY = Constants.radius
            self.uncoveredCenter = UIImageFromArray(source: noise, height: diameter, width: diameter, transformation: State.MaskFunc)
            self.Image.image = uncoveredCenter
            Label.text = "You will only see small portion of the picture at a time."
            State.LastPressX = -1
            State.LastPressY = -1
        case 4:
            self.Image.image = getBlank()
            Label.text = "And only for a small amount of time (\(State.showFor) ms)"

        case 5:
            Image.image = uncoveredCenter
            Label.text = "Like this."
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(State.showFor)/1000, execute: {
                self.Image.image! = getBlank()
            })
        case 6:
            Image.image = img
            Label.text = "When you think you saw the gabor, press the button in bottom left corner. The noise will be uncovered (without the gabor). Try to press as close to the gabor location as possible."
        case 7:
            Label.text = "The gabor can't appear anywhere. These are all \(State.PossibleLocations.count) possible locations:"
            let gabor = MakeGabor(Size: State.GaborSize, rotation: 45, Contrast: 1, Period: State.GaborSize/3)
            let mask = MakeGaborMask(Size: State.GaborSize, peak: State.GaborOpacity)
            for p in State.PossibleLocations{
            ImagePaste(Background: &noise, BackgroundWidth: Constants.radius*2, BackgroundHeight: Constants.radius*2, Image: gabor, Width: State.GaborSize, Height: State.GaborSize, Top: p.y-(State.GaborSize/2), Left: p.x-(State.GaborSize/2), Alpha: mask)
            }
            let myimg = UIImageFromArray(source: noise, height: Constants.radius*2, width: Constants.radius*2)
            self.Image.image = myimg
        case 8:
            if (State.CurrentSubject.Feedback == .None){
                switch(State.PreviousScreen){
                case "Settings":
                    performSegue(withIdentifier: "BackToSettings", sender: nil)
                case "Menu":
                    performSegue(withIdentifier: "BackToMainMenu", sender: nil)
                default:
                    print("Unexhaustive switch at the end of preview!")
                    performSegue(withIdentifier: "BackToSettings", sender: nil)
                }
            }  else{
                Label.text = "You will get acoustic feedback about the locations you choose to fixate. This sound means you did as good as you could"
                MakeScaledSound(Tone: 0)
            }
        case 9:
            Label.text = "And this means you did as badly as you could"
            MakeScaledSound(Tone: 2)
        case 10:
            Label.text = "This is not the best, but still pretty good!"
            MakeScaledSound(Tone: 1)
        case 11:
            Label.text = "These are not all the sounds you can hear -- there is full scale from the worst to the best. The lower tone, the better!"
        default:
            switch(State.PreviousScreen){
            case "Settings":
                performSegue(withIdentifier: "BackToSettings", sender: nil)
            case "Menu":
                performSegue(withIdentifier: "BackToMainMenu", sender: nil)
            default:
                print("Unexhaustive switch at the end of preview!")
                performSegue(withIdentifier: "BackToSettings", sender: nil)
            }
        }
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
