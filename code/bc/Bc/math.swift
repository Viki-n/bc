//
//  math.swift
//  bc
//
//  Created by Viki on 02/05/2018.
//  Copyright © 2018 Viki. All rights reserved.
//

import Foundation

func sqr(_ x:Int)->Int{
    return x*x
}

func sqr(_ x:Double)->Double{
    return x*x
}

func sqr(_ x:Float)->Float{
    return x*x
}

func distance(Xdiference:Double,Ydiference:Double)->Double{
    return sqrt(Xdiference*Xdiference+Ydiference*Ydiference)
}

func distance(Xdiference:Int,Ydiference:Int)->Double{
    return sqrt(Double(Xdiference*Xdiference+Ydiference*Ydiference))
}

func distance(X1: Int, Y1:Int,X2:Int,Y2:Int)->Double{
    return sqrt(Double((X1-X2)*(X1-X2) + (Y1-Y2)*(Y1-Y2)))
}

func distance(X1: Double, Y1:Double,X2:Double,Y2:Double)->Double{
    return sqrt(Double((X1-X2)*(X1-X2) + (Y1-Y2)*(Y1-Y2)))
}

func distance(_ x: point, _ y: point) -> Double {
    return sqrt(Double((x.x-y.x)*(x.x-y.x)+(x.y-y.y)*(x.y-y.y)))
}

///Cumulative distribution function of normalized normal distribution
func Phi(_ x: Double)->Double{
    return erf(-x/sqrt(2))/2
}

///Returns d' value based on hitrate and false alarm rate
func dprime(HitRate:Double, FalseAlarmRate:Double) -> Double{
    return (-erf(-FalseAlarmRate/sqrt(2))+erf(-HitRate/sqrt(2)))/2
}

///Returns dprime on a point based on constants in State
func dprime(fixated: point, measuring:point) -> Double {
    let x = -fixated.x + measuring.x
    let y = -fixated.y + measuring.y
    let ev = y>0 ? State.eDownwards : State.eUpwards
    let eh = x>0 ? State.eRight : State.eLeft
    return State.dPrimeZero/(1+pow((Double(x*x)/(eh*eh))+(Double(y*y)/(ev*ev)),State.FunctionSteepnes))
}
