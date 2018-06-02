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
class logger{
    
    static func SaveLog(){
        NSKeyedArchiver.archiveRootObject(State.log, toFile: SavePath.path)
    }
    
    static func LoadLog(){
        if let log = NSKeyedUnarchiver.unarchiveObject(withFile: SavePath.path) as? [trial] {
            State.log = log
        }
    }
    
    private static let SavePath = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("log")
}

class trial:NSObject,NSCoding{
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(subject, forKey: propertyKey.subject)
        aCoder.encode(difficulty, forKey: propertyKey.difficulty)
        aCoder.encode(TargetDistance, forKey: propertyKey.TargetDistance)
        aCoder.encode(attempts, forKey: propertyKey.attempts)
        aCoder.encode(TrialNumber, forKey: propertyKey.TrialNumber)
        for i in 0..<attempts{
            aCoder.encode(fixations[i].x,forKey: propertyKey.point + "x" + String(i))
            aCoder.encode(fixations[i].y,forKey: propertyKey.point + "y" + String(i))
        }
        aCoder.encode(Gabor.x, forKey: propertyKey.Gabor + "x")
        aCoder.encode(Gabor.y, forKey: propertyKey.Gabor + "y")
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        self.subject = aDecoder.decodeObject(forKey: propertyKey.subject) as! String
        self.difficulty = aDecoder.decodeDouble(forKey: propertyKey.difficulty)
        self.TargetDistance = aDecoder.decodeInteger(forKey: propertyKey.TargetDistance)
        self.attempts = aDecoder.decodeInteger(forKey: propertyKey.attempts)
        self.TrialNumber = aDecoder.decodeInteger(forKey: propertyKey.TrialNumber)
        self.fixations = [point]()
        for i in 0..<attempts{
            fixations.append(point(aDecoder.decodeInteger(forKey: propertyKey.point + "x" + String(i)), aDecoder.decodeInteger(forKey: propertyKey.point + "y" + String(i))))
        }
        self.Gabor =  point(aDecoder.decodeInteger(forKey: propertyKey.Gabor + "x"), aDecoder.decodeInteger(forKey: propertyKey.Gabor + "y"))
        
    }
    
    public var difficulty = 0.0
    public var subject = ""
    public var TargetDistance = 0
    public var attempts = 0
    public var TrialNumber = 0
    public var Gabor = point(0,0)
    
    struct propertyKey {
        static let difficulty = "difficulty"
        static let subject = "subject"
        static let TargetDistance = "TargetDistance"
        static let attempts = "attempts"
        static let TrialNumber = "TrialNumber"
        static let fixations = "fixations"
        static let point = "point"
        static let Gabor = "Gabor"
    }
    
    override init() {
        subject = State.subject
        TrialNumber = 1 + findLastTrial(log: State.log, subject: State.subject)
        difficulty = State.GaborOpacity
    }
    
    public var fixations = [point]()
    public func ToString() -> String{
        var s = """
        Name: \(subject) Trial:\(TrialNumber) Difficulty:\(Int(1000*difficulty))
        Attempts:\(attempts) Accuracy:\(TargetDistance)
        Gabor location:\(Gabor.x) \(Gabor.y)
        
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
