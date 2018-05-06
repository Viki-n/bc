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
