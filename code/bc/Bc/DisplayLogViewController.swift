//
//  DisplayLogViewController.swift
//  Bc
//
//  Created by Viki on 02/06/2018.
//  Copyright © 2018 Viki. All rights reserved.
//

import UIKit
import Accelerate
import GameplayKit

class DisplayLogViewController: UIViewController {
    @IBOutlet weak var TextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var s = ""
        for i in State.log{
            s = s + i.ToString()
        }
        var p = [Double]()
        var im = [Double]()
        let r = GKRandomSource()
        let random = GKGaussianDistribution(randomSource: r, mean: 3, deviation: 1)
        
        for i in 0..<Constants.radius*2{
            p.append(Double(random.nextUniform()-0.5)/(Double(abs(i-Constants.radius))+0.1))
            im.append(Double(random.nextUniform()-0.5)/(Double(abs(i-Constants.radius))+0.1))
        }
        
        var fftdsp = DSPDoubleSplitComplex(realp: &p, imagp: &im)
        vDSP_fft_zipD(Constants.FFTsetup, &fftdsp, 1, Constants.LogRadius, FFTDirection(FFT_FORWARD))
        
        s=""
        for d in p{
            s = s+"\(d)\n"
        }
        
        TextView.text = s
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
