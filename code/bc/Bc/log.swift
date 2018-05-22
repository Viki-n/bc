//
//  log.swift
//  Bc
//
//  Created by Viki on 21/05/2018.
//  Copyright © 2018 Viki. All rights reserved.
//

import Foundation

class point{
    public var x = 0
    public var y = 0
    public init(_ x:Int,_ y: Int){
        self.x = x
        self.y = y
    }
    public func ToString() -> String {
        return String(x) + " " + String(y)
    }
}

class trial{
    public var difficulty = 0.0
    public var subject = ""
    public var TargetDistance = 0
    public var attempts = 0
    public var TrialNumber = 0
    
    init() {
        subject = State.subject
        TrialNumber = State.TrialNumber
        difficulty = State.GaborOpacity
    }
    
    public var fixations = [point]()
    public func ToString() -> String{
        var s = """
        \(subject) \(TrialNumber) \(Int(1000*difficulty))
        \(attempts) \(TargetDistance)
        """
        for f in fixations{
            s = s + f.ToString() + "\n"
        }
        return s + "\n"
    }
}

func findLastTrial(log: [trial], subject: String)->Int{
    var maximum = 0
    for t in log{
        if t.subject == subject{
            maximum = max(maximum,t.TrialNumber)
        }
    }
    return maximum
}
