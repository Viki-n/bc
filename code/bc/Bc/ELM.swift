//
//  ELM.swift
//  Bc
//
//  Created by Viki on 01/07/2018.
//  Copyright © 2018 Viki. All rights reserved.
//

import Foundation
import GameplayKit

class ELM {
    private var Random = GKGaussianDistribution(randomSource: GKRandomSource(), mean: 0, deviation: 1)
    private var posteriori = [Double]()
    private var AggregateResponses = [Double]()
    private var count = 0
    public var Values = [Double]()
    
    public func Reset(){
        count = State.PossibleLocations.count
        posteriori = [Double](repeating: 1/Double(count), count: count)
        AggregateResponses = [Double](repeating: 0, count: count)
        Values = [Double](repeating: 0, count:count)
    }
    public func Update(Fixated:point){
        let responses = GetResponses(Looking: Fixated, Target: point(State.GaborX,State.GaborY))
        UpdateSum(responses: responses, Fixated: Fixated)
        UpdatePosteriors()
        UpdateValues()
    }
    public func GetValue(location: point) -> Double {
        var sum = 0.0
        for i1 in 0..<count {
            sum += posteriori[i1] * dSq_stat_fixd(CalculatingFor: State.PossibleLocations[i1], fixated: location)
        }
        return sum
    }
    
    
    private func UpdateValues() {
        for i in 0..<count{
            var sum = 0.0
            for i1 in 0..<count {
                sum += posteriori[i1] * dSq_stat_fixd(CalculatingFor: State.PossibleLocations[i1], fixated: State.PossibleLocations[i])
            }
            Values[i] = sum
        }
    }
    
    private func UpdateSum(responses:[Double], Fixated:point){
        for i in 0..<count{
            AggregateResponses[i] += responses[i] * dSq_stat_fixd(CalculatingFor: State.PossibleLocations[i], fixated: Fixated)
        }
    }
    
    private func UpdatePosteriors(){
        var ExpResp = AggregateResponses.map(exp)
        var sum = 0.0
        for i in 0..<count{
            sum += ExpResp[i]*posteriori[i]
        }
        for i in 0..<count{
            posteriori[i] = ExpResp[i]*posteriori[i]/sum
        }
        
    }
    
    private func GetResponses(Looking: point, Target: point) -> [Double]{
        var r = [Double]()
        for i in State.PossibleLocations{
            r.append(Double(Random.nextUniform())*3/d_true_fixd(CalculatingFor: i, fixated: Looking) + ((i.x == Target.x && i.y == Target.y) ? 0.5 : -0.5))
        }
        return r
    }
    private func d_true_fixd(CalculatingFor:point, fixated: point)->Double{
        
    }
    private func dSq_stat_fixd(CalculatingFor:point, fixated:point )->Double{
        
    }
    
}
