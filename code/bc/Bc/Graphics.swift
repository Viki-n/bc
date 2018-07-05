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
    if(DebugFlags.ShowTargets){
        var darkness = combine(first: State.Uncovered, second:State.darkness, mask: getStartingShowmap(), length: Constants.radius*Constants.radius*4)
        let size = State.GaborSize/2
        var count = -1
        for i in State.PossibleLocations {
            count += 1
            let color = 1+UInt8(((State.elm.Values[count] - State.elm.minvalue) / (State.elm.maxvalue - State.elm.minvalue) * 254))
            let inside = State.elm.Values[count] == State.elm.maxvalue
            let color2 = 1 + UInt8(State.elm.posteriori[count]*254)
            for x in i.x-size..<i.x+size{
                for y in i.y-size..<i.y+size{
                    let coordinate = y*Constants.radius*2 + x
                    if distance(X1: x, Y1: y, X2: i.x, Y2: i.y)<Double(size){
                        if(inside && distance(X1: x, Y1: y, X2: i.x, Y2: i.y)<Double(size)/3){
                            darkness[coordinate]=0
                        } else  if (x-y < i.x-i.y) {
                            darkness[coordinate] = color
                            
                        } else {
                            darkness[coordinate] = color2
                        }
                    }
                }
            }
        }
        return UIImageFromArray(source: darkness, height: Constants.radius*2, width: Constants.radius*2)
    } else if (!State.BlankStored) { //first call
        State.Blank = UIImageFromArray(source: combine(first: State.Uncovered, second:State.darkness, mask: getStartingShowmap(), length: Constants.radius*Constants.radius*4), height: Constants.radius*2, width: Constants.radius*2)
        State.BlankStored = true
    }
    return State.Blank!
}

func GetGrey()->UIImage{
    return UIImageFromArray(source: [UInt8](repeating: 128, count:Constants.radius*Constants.radius*4), height: Constants.radius*2, width: Constants.radius*2)
}

func combine(first: [UInt8], second: [UInt8], mask: [Double], length: Int)->[UInt8]{
    var output = [UInt8]()
    for i in 0..<length{
        output.append(UInt8(Double(first[i])*mask[i] + Double(second[i])*(1-mask[i])))
    }
    return output
}

func SimpleCircularSinusoidPressFilter(_ x:Int, _ y:Int, _ prevValue:UInt8)->UInt8{
    let dist  = distance(X1: x, Y1: y, X2: State.LastPressX, Y2: State.LastPressY)
    if dist > Double(Constants.UncoverRadius){
        return 0
    }
    return UInt8(Double(prevValue)*(cos(dist/Double(Constants.UncoverRadius) * .pi) * 0.5 + 0.5))
}

func DPrimePressFilter(_ x:Int, _ y:Int, _ prevValue:UInt8)->UInt8{
    let XDif = x - State.LastPressX + Constants.radius*2
    let YDif = y - State.LastPressY + Constants.radius*2
    let Relevantvalue = State.dMap[XDif + YDif*(Constants.radius*4+1)]
    
    return UInt8(Double(prevValue)*Relevantvalue)
}

func MakeDMap(){
    if(State.dMapActual){
        return
    }
    State.dMap = [Double]()
    for y in (-Constants.radius*2)..<Constants.radius*2+1{
        for x in (-Constants.radius*2)..<Constants.radius*2+1{
            let ev = y>0 ? State.eDownwards : State.eUpwards
            let eh = x>0 ? State.eRight : State.eLeft
            State.dMap.append(1/(1+pow((Double(x*x)/(eh*eh))+(Double(y*y)/(ev*ev)),State.FunctionSteepnes)))
        }
    }
    State.dMapActual = true
    
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
    let dataPointer = UnsafeMutablePointer<UInt8>(OpaquePointer(BitmapContext!.data))
    var actualcoordinate : Int = 0
    for y in 0..<height {
        for x in 0..<width{
            if(distance(X1: x, Y1: y, X2: Constants.radius, Y2: Constants.radius)>Double(Constants.radius)){
                dataPointer![actualcoordinate] = source[actualcoordinate]
            } else {
                dataPointer![actualcoordinate] = transformation(x,y,source[actualcoordinate])
            }
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
