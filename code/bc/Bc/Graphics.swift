//
//  Graphics.swift
//  HelloWorld2
//
//  Created by Viki on 02/05/2018.
//  Copyright © 2018 Viki. All rights reserved.
//

import Foundation
import UIKit

func combine(first: [UInt8], second: [UInt8], mask: [Double], length: Int)->[UInt8]{
    var output = [UInt8]()
    for i in 0..<length{
        output.append(UInt8(Double(first[i])*mask[i] + Double(second[i])*(1-mask[i])))
    }
    return output
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
