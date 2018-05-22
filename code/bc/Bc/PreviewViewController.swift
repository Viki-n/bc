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
        state = 0
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
            let img = UIImageFromArray(source: noise, height: Constants.radius*2, width: Constants.radius*2)
            self.Image.image = img
            Label.text = "In the middle, there is a gabor patch."
        case 2:
            self.Image.image = getBlank()
            Label.text = "But the noise is covered."
        case 3:
            State.LastPressX = Constants.radius
            State.LastPressY = Constants.radius
            self.uncoveredCenter = UIImageFromArray(source: noise, height: diameter, width: diameter, transformation: SinglePressFilter)
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
        default:
            performSegue(withIdentifier: "BackToSettings", sender: nil)
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
