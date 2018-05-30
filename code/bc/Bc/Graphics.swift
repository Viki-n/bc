//
//  Graphics.swift
//  bc
//
//  Created by Viki on 02/05/2018.
//  Copyright © 2018 Viki. All rights reserved.
//

import Foundation
import UIKit

func getBlank() ->UIImage {
    if (!State.BlankStored) { //first call
        State.Blank = UIImageFromArray(source: combine(first: State.Uncovered, second:State.darkness, mask: getStartingShowmap(), length: Constants.radius*Constants.radius*4), height: Constants.radius*2, width: Constants.radius*2)
        State.BlankStored = true
    }
    return State.Blank!
}
func combine(first: [UInt8], second: [UInt8], mask: [Double], length: Int)->[UInt8]{
    var output = [UInt8]()
    for i in 0..<length{
        output.append(UInt8(Double(first[i])*mask[i] + Double(second[i])*(1-mask[i])))
    }
    return output
}

func SinglePressFilter(_ x:Int, _ y:Int, _ prevValue:UInt8)->UInt8{
    if distance(X1: x, Y1: y, X2: Constants.radius, Y2: Constants.radius) > Double(Constants.radius){
        return prevValue
    }
    let dist  = distance(X1: x, Y1: y, X2: State.LastPressX, Y2: State.LastPressY)
    if dist > Double(Constants.UncoverRadius){
        return 0
    }
    return UInt8(Double(prevValue)*(cos(dist/Double(Constants.UncoverRadius) * .pi) * 0.5 + 0.5))
}

func UIImageFromArray(source: [UInt8], height: Int, width:Int)->UIImage{
    let cs = CGColorSpaceCreateDeviceGray()
    let BitmapContext = CGContext.init(data:nil, width:width, height:height, bitsPerComponent:8, bytesPerRow:width, space:cs, bitmapInfo:CGImageAlphaInfo.none.rawValue)
    let dataPoiner = UnsafeMutablePointer<UInt8>(OpaquePointer(BitmapContext!.data))
    for i in 0..<source.count {
        dataPoiner![i] = source[i]
    }
    return UIImage(cgImage:BitmapContext!.makeImage()!)
}

func UIImageFromArray(source: [UInt8], height: Int, width:Int, transformation: (Int,Int,UInt8)->UInt8)->UIImage{
    let cs = CGColorSpaceCreateDeviceGray()
    let BitmapContext = CGContext.init(data:nil, width:width, height:height, bitsPerComponent:8, bytesPerRow:width, space:cs, bitmapInfo:CGImageAlphaInfo.none.rawValue)
    let dataPoiner = UnsafeMutablePointer<UInt8>(OpaquePointer(BitmapContext!.data))
    var actualcoordinate : Int = 0
    for y in 0..<height {
        for x in 0..<width{
            dataPoiner![actualcoordinate] = transformation(x,y,source[actualcoordinate])
            actualcoordinate += 1
        }
    }
    return UIImage(cgImage:BitmapContext!.makeImage()!)
}

func ImagePaste( Background: inout [UInt8],BackgroundWidth:Int,BackgroundHeight:Int,Image:[UInt8],Width:Int,Height:Int,Top:Int,Left:Int,Alpha:[Double]){
    for i in 0..<Width {
        if(i+Left >= BackgroundWidth){break}
        for i1 in 0..<Height{
            if(i1+Top >= BackgroundHeight){
                break
            }
            let indexInImage = i+Width*i1
            let indexInOriginal = Left + i + (Top + i1)*BackgroundWidth
            Background[indexInOriginal] = UInt8(Double(Background[indexInOriginal])*(1-Alpha[indexInImage])+Double(Image[indexInImage])*Alpha[indexInImage])
        }
    }
}
