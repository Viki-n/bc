//
//  NoiseGen.swift
//  bc
//
//  Created by Viki on 02/05/2018.
//  Copyright © 2018 Viki. All rights reserved.
//

import Foundation
import Accelerate
import GameplayKit

func GenerateWhiteNoise(radius: Int) -> [UInt8]{
    var out = [UInt8]()
    for _ in 0..<2*radius{
        for _ in 0..<2*radius{
            out.append(UInt8(arc4random_uniform(255)))
        }
    }
    return out
}

func GeneratePinkNoise() -> [UInt8]{
    let radius = Constants.radius
    var real = [Double](repeating:0, count:radius*radius*4)
    var imag = [Double](repeating:0, count:radius*radius*4)
    let RandomSource = GKRandomSource()
    let random = GKGaussianDistribution(randomSource: RandomSource, lowestValue: 0, highestValue: 1)
    var FFTinput = DSPDoubleSplitComplex(realp:&real,imagp:&imag)
    for i in 0..<2*radius{
        for i1 in 0..<2*radius
        {
            let index = (i+radius)%(2*radius) + ((i1+radius)%(2*radius))*2*radius
            let XCenterDistance = abs(Double(i-radius))
            let YCenterDistance = abs(Double(i1-radius))
            let quocient = sqrt(XCenterDistance*XCenterDistance+YCenterDistance*YCenterDistance)//sum of squares of coordinates, except coordinates shifted by half
            let dist = Double(random.nextUniform())/(quocient==0 ? 0.1 : quocient)
            let deg = 2 * .pi * Double(arc4random())/Double(UINT32_MAX)
            FFTinput.realp[index] = dist*sin(deg)
            FFTinput.imagp[index] = dist*cos(deg)
        }
    }
    vDSP_fft2d_zipD(Constants.FFTsetup, &FFTinput, 1, 0, Constants.LogRadius+UInt(1), Constants.LogRadius+1, FFTDirection(FFT_INVERSE))
   
    var sum = 0.0
    var squaresum = 0.0
    for i in 0..<radius*radius*4  {
        let x = FFTinput.realp[i]
        sum += x
        squaresum += x*x
    }
    let mean = sum/Double(radius*radius*4)
    let std_dev = sqrt(squaresum/Double(radius*radius*4)-mean*mean)
    let upper_bound = mean+2*std_dev
    let lower_bound = mean-2*std_dev
    var output = [UInt8]()
    for i1 in 0..<radius*2{
        for i2 in 0..<radius*2{
            let i = i1+2*radius*i2
            if (FFTinput.realp[i]>upper_bound){FFTinput.realp[i]=upper_bound}//clipping 2 std devs above and below mean
            if (FFTinput.realp[i]<lower_bound){FFTinput.realp[i]=lower_bound}
            var scaled_value = (upper_bound-lower_bound == 0) ? 128 : ((FFTinput.realp[i]-lower_bound)/(upper_bound-lower_bound)*253 + 1)
            if DebugFlags.crop{
                if ((i1-radius)*(i1-radius)+(i2-radius)*(i2-radius)>radius*radius){scaled_value=Double(Constants.backgroundcolor)} //clipping square noise to circular area
            }
            output.append(UInt8(scaled_value))
        }
    }
    return output
}

func MakeGabor(Size:Int, rotation:Double, Contrast:Double, Period:Int)->[UInt8]{
    var out = [UInt8]()
    if DebugFlags.actualGabor {
        let phase = 0.25
        //let ppd = 256
        //let sigma = sqrt(log(4))/(12 * Double.pi)*(pow(2,Double(Bandwidth))+1) / (pow(2,Double(Bandwidth)-1)) * Double(ppd)
        let phaseRad = phase * .pi * 2
        let thetaRad = rotation / 360 * 2 * .pi
        let xEffect = cos(thetaRad)
        let yEffect = sin(thetaRad)
        for y in 0..<Size{
            for x in 0..<Size{
                let t = Double(y) * yEffect + Double(x) * xEffect
                let f = t * 2 * .pi / Double(Period)
                let value = Double(127) * (1+Double(Contrast) * sin(f + phaseRad))
                out.append(UInt8(value))
                
            }
        }
    } else {
        for i in 0..<Size {
            for i1 in 0..<Size {
                if i<i1 {out.append(0)} else {out.append(255)}
            }
        }
    }
    return out
}

func MakeGaborMask(Size:Int,peak:Double)->[Double]{
    var out = [Double]()
    let r=Size/2
    let divisor = .pi / (Double(Size) / 2)
    for i in 0..<Size{
        for i1 in 0..<Size{
            let x = i-r
            let y = i1-r
            let centerdistance = sqrt(Double(x * x + y * y))
            out.append((centerdistance>Double(r)) ? 0.0 : ((1+(cos(centerdistance * divisor)))*0.5*peak))
        }
    }
    return out
}
