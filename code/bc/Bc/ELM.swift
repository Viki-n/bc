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
    public var posteriori = [Double]()
    private var AggregateResponses = [Double]()
    private var count = 0
    public var Values = [Double]()
    public var maxvalue = -Double.infinity
    public var minvalue = Double.infinity
    private var prior = 0.0
    
    public func Reset(){
        count = State.PossibleLocations.count
        prior = 1/Double(count)
        posteriori = [Double](repeating: prior, count: count)
        AggregateResponses = [Double](repeating: 0, count: count)
        Values = [Double](repeating: 0, count:count)
        UpdateValues()
    }
    
    public func Update(Fixated:point){
        let responses = GetResponses(Looking: Fixated, Target: State.PossibleLocations[State.GaborIndex])
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
        minvalue = Double.infinity
        maxvalue = -Double.infinity
        for i in 0..<count{
            var sum = 0.0
            for i1 in 0..<count {
                sum += posteriori[i1] * dSq_stat_fixd(CalculatingFor: State.PossibleLocations[i1], fixated: State.PossibleLocations[i])
            }
            Values[i] = sum
            if (sum>maxvalue){
                maxvalue = sum
            }
            if (sum<minvalue){
                minvalue = sum
            }
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
            sum += ExpResp[i]*prior
        }
        for i in 0..<count{
            posteriori[i] = ExpResp[i]*prior/sum
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
        return 3*dprime(fixated: fixated, measuring: CalculatingFor)//3 je d`_0
    }
    private func dSq_stat_fixd(CalculatingFor:point, fixated:point )->Double{
            return sqr(d_true_fixd(CalculatingFor: CalculatingFor, fixated: fixated))
    }
    
}
