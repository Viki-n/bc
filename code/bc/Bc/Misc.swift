//
//  Misc.swift
//  Bc
//
//  Created by Viki on 30/05/2018.
//  Copyright © 2018 Viki. All rights reserved.
//

import Foundation
import Accelerate
import UIKit

class Constants {
    public static let radius = 512
    public static let LogRadius = UInt(9)
    public static let FFTradix = FFTRadix(kFFTRadix2)
    public static let FFTsetup = vDSP_create_fftsetupD(vDSP_Length(Int(LogRadius)+Int(1)),FFTradix)!
    public static let backgroundcolor = 128
    public static let covercolor:UInt8 = 0
    public static var UncoverRadius = 300
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
    public static var noise = [UInt8]()
    public static var Uncovered = [UInt8](repeating: UInt8(Constants.backgroundcolor),count:Constants.radius*Constants.radius * 4)
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
    public static var GenerateBackgroundOnEntry = true
    public static var GaborLocated = false
    public static var PreviousAccuracy = 0
    public static var RedrawOnClick = false
    public static var Screen = ""
    public static var PreviousScreen = ""
    public static var appInitialized = false
    //Info about user
    public static var subject = "unknown"
    public static var currentTrial = trial()
    public static var log = [trial]()
    
    public static var PossibleLocations = [point]()
    public static var PossibleLocationsDistance = 100
    
    public static var DataDeletionEnabled = false
    
}

func SetScreen(screen: String){
    State.PreviousScreen = State.Screen
    State.Screen = screen
}

func CalculatePossibleLocations(d: Int){
    State.PossibleLocations = [point]()
    func add(_ x: point, _ y: point)->point{
        return point(x.x+y.x, x.y+y.y)
    }
    let root = Int(Double(d)*sqrt(3)/2)
    let directions = [point(d,0), point(-d,0), point(d/2,root), point(-d/2,root), point(d/2,-root), point(-d/2,-root)]
    let center = point(Constants.radius, Constants.radius)
    var queue = [center]
    var i=0
    while(i<queue.count){
        if distance(center, queue[i])<Double(Constants.radius - State.GaborSize/2){
            var isOK = true
            for p in State.PossibleLocations{
                if distance(p,queue[i]) < Double(d/2){
                    isOK = false
                    break
                }
            }
            if isOK{
                State.PossibleLocations.append(queue[i])
                for p in directions{
                    queue.append(add(p,queue[i]))
                }
            }
        }
        i += 1
    }
    
}

func  InitApp(){
    if(!State.appInitialized){
        logger.LoadLog()
        CalculatePossibleLocations(d:State.PossibleLocationsDistance)
        State.appInitialized = true
    }
}
