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
        switch state {
        case 0:
            var noise = GeneratePinkNoise()
            let gabor = MakeGabor(Size: State.GaborSize, rotation: 45, Contrast: 1, Period: State.GaborSize/3)
            let mask = MakeGaborMask(Size: State.GaborSize, peak: State.GaborOpacity)
            ImagePaste(Background: &noise, BackgroundWidth: Constants.radius*2, BackgroundHeight: Constants.radius*2, Image: gabor, Width: State.GaborSize, Height: State.GaborSize, Top: Constants.radius-(State.GaborSize/2), Left: Constants.radius-(State.GaborSize/2), Alpha: mask)
            let img = UIImageFromArray(source: noise, height: Constants.radius*2, width: Constants.radius*2)
            self.Image.image = img
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
