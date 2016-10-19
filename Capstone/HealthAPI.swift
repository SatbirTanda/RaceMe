//
//  HealthAPI.swift
//  Capstone
//
//  Created by Satbir Tanda on 6/18/16.
//  Copyright © 2016 Satbir Tanda. All rights reserved.
//

import Foundation
import HealthKit

protocol HealthAPIDelegate {
    func healthDataDidGetQueried()
}

class HealthAPI {
    
    let AMOUNT_OF_QUERIES = 9
    let healthKitStore: HKHealthStore!
    var delegate: HealthAPIDelegate?
    
    init() {
        healthKitStore = {
            if HKHealthStore.isHealthDataAvailable() {
                return HKHealthStore()
            } else {
                return nil
            }
        }()
    }
    

    func authorizeHealthKit(completion: (() -> Void)?) {
        if healthKitStore != nil {
            // 1. Set the types you want to read from HK Store
            let healthKitTypesToRead: Set<HKObjectType> = [
                HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBloodType)!,
                HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex)!,
                HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)!,
                HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)!,
                HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!,
                HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)!,
                HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!]
            
            healthKitStore.requestAuthorizationToShareTypes(nil, readTypes: healthKitTypesToRead) { (success, error) -> Void in
                if success {
                    // print("healthkit authorized")
                    completion?()
                }
            }

        }
    }
    
    var bloodType: String {
        do {
            let bT = try healthKitStore.bloodType()
            switch bT.bloodType {
            case .APositive:
                return "A+"
            case .ANegative:
                return "A-"
            case .BPositive:
                return "B+"
            case .BNegative:
                return "B-"
            case .ABPositive:
                return "AB+"
            case .ABNegative:
                return "AB-"
            case .OPositive:
                return "O+"
            case .ONegative:
                return "O-"
            case .NotSet:
                return "None"
            }
        } catch {
            return "None"
        }
    }

    var biologicalSex: String {
        do {
            let biologicalSex = try healthKitStore.biologicalSex()
            switch biologicalSex.biologicalSex {
            case .Female:
                return "Female"
            case .Male:
                return "Male"
            case .NotSet:
                return "None"
            default:
                return "None"
            }
        } catch {
            return "None"
        }
    }

    var totalSteps: Int = 0
    var incrementsOfStepsForEachDay: [String] = []
    var totalStepsForEachDayOfYear: [String] = []
    

    var totalFlights: Int = 0
    var incrementsOfFlightsForEachDay: [String] = []
    var totalFlightsForEachDayOfYear: [String] = []

    var totalWalkRunDistance: Int = 0
    var incrementsOfWalkRunDistanceForEachDay: [String] = []
    var totalWalkRunDistanceForEachDayOfYear: [String] = []
    
    var height: Int = 0
    var weight: Int = 0
    
    private var count = 0 {
        didSet {
            if count == AMOUNT_OF_QUERIES {
                self.delegate?.healthDataDidGetQueried()
                count = 0
            }
        }
    }
    
    func update() {
        setTotalSteps()
        setTotalFlights()
        setWalkRunDistance()
        setTotalStepsForEachDayOfYear()
        setTotalFlightsForEachDayOfYear()
        setTotalWalkRunDistanceForEachDayOfYear()
        setIncrementsOfStepsForEachDay()
        setIncrementsOfFlightsForEachDay()
        setIncrementsOfWalkRunDistanceForEachDay()
    }
    
    private func setTotalSteps() {
        self.totalSteps = 0
        getAbsoluteTotal(withQuantity: HKQuantityTypeIdentifierStepCount) { (result) in
            self.totalSteps = result
        }
    }
    
    private func setTotalFlights() {
        self.totalFlights = 0
        getAbsoluteTotal(withQuantity: HKQuantityTypeIdentifierFlightsClimbed) { (result) in
            self.totalFlights = result
        }
    }
    
    private func setWalkRunDistance() {
        self.totalWalkRunDistance = 0
        getAbsoluteTotal(withQuantity: HKQuantityTypeIdentifierDistanceWalkingRunning) { (result) in
            self.totalWalkRunDistance = result
        }
    }
    
    private func setIncrementsOfStepsForEachDay() {
        self.incrementsOfStepsForEachDay = []
        getIncrementsForEachDay(withQuantity: HKQuantityTypeIdentifierStepCount) { (resultArray) in
            self.incrementsOfStepsForEachDay = resultArray
        }
    }
    
    private func setIncrementsOfFlightsForEachDay() {
        self.incrementsOfFlightsForEachDay = []
        getIncrementsForEachDay(withQuantity: HKQuantityTypeIdentifierFlightsClimbed) { (resultArray) in
            self.incrementsOfFlightsForEachDay = resultArray
        }
    }
    
    private func setIncrementsOfWalkRunDistanceForEachDay() {
        self.incrementsOfWalkRunDistanceForEachDay = []
        getIncrementsForEachDay(withQuantity: HKQuantityTypeIdentifierDistanceWalkingRunning) { (resultArray) in
            self.incrementsOfWalkRunDistanceForEachDay = resultArray
        }
    }
    
    private func setTotalStepsForEachDayOfYear() {
        self.totalStepsForEachDayOfYear = []
        getTotalForEachDayOfYear(withQuantity: HKQuantityTypeIdentifierStepCount) { (result) in
            self.totalStepsForEachDayOfYear = result
        }
    }
    
    private func setTotalFlightsForEachDayOfYear() {
        self.totalFlightsForEachDayOfYear = []
        getTotalForEachDayOfYear(withQuantity: HKQuantityTypeIdentifierFlightsClimbed) { (result) in
            self.totalFlightsForEachDayOfYear = result
        }
    }
    
    private func setTotalWalkRunDistanceForEachDayOfYear() {
        self.totalWalkRunDistanceForEachDayOfYear = []
        getTotalForEachDayOfYear(withQuantity: HKQuantityTypeIdentifierDistanceWalkingRunning) { (result) in
            self.totalWalkRunDistanceForEachDayOfYear = result
        }
    }
    
    
    private func getTotalForEachDayOfYear(withQuantity identifier: String, completion: (([String]) -> Void)?) {
            if healthKitStore != nil {
                let type = HKSampleType.quantityTypeForIdentifier(identifier)
                let startDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: -365, toDate: NSDate(), options: [])
                let interval = NSDateComponents()
                interval.day = 1
                
                let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: NSDate(), options: .StrictStartDate)
                let query = HKStatisticsCollectionQuery(quantityType: type!, quantitySamplePredicate: predicate, options: [.CumulativeSum], anchorDate: NSDate(), intervalComponents:interval)
                
                query.initialResultsHandler = { query, results, error in
                    
                    var resultArray: [String] = []
                    let endDate =  NSDate()
                    let startDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: -365, toDate: NSDate(), options: [])
                    if let myResults = results{
                        myResults.enumerateStatisticsFromDate(startDate!, toDate: endDate) {
                            statistics, stop in
                            
                            if let quantity = statistics.sumQuantity() {
                                let dateFormatter = NSDateFormatter()
                                dateFormatter.dateStyle = .MediumStyle
                                var steps = 0
                                let date = dateFormatter.stringFromDate(statistics.endDate)
                                if identifier == HKQuantityTypeIdentifierDistanceWalkingRunning { steps = Int(quantity.doubleValueForUnit(HKUnit.meterUnit())) }
                                else { steps = Int(quantity.doubleValueForUnit(HKUnit.countUnit())) }
                                // print("\(identifier): \(date): count = \(steps)")
                                // valueToSet.append("\(date):\(steps)")
                                resultArray.append("\(date)-\(steps)")
                             }
                        }
                    }
                    completion?(resultArray)
                    self.count += 1
                }
                
                healthKitStore.executeQuery(query)
            }
    }
    
    private func getIncrementsForEachDay(withQuantity identifier: String, completion: (([String]) -> Void)?) {
            if healthKitStore != nil {
                
                let stepsCount = HKQuantityType.quantityTypeForIdentifier(
                    identifier)!
                
                let stepsSampleQuery = HKSampleQuery(sampleType: stepsCount,
                    predicate: nil,
                    limit: HKObjectQueryNoLimit,
                    sortDescriptors: nil)
                { (query, results, error) in
                    if let results = results as? [HKQuantitySample] {
                        var resultArray: [String] = []
                        for i in 0 ..< results.count {
                            let dateFormatter = NSDateFormatter()
                            dateFormatter.dateStyle = .MediumStyle
                            let date = dateFormatter.stringFromDate(results[i].endDate)
                            
                            let timeFormatter = NSDateFormatter()
                            timeFormatter.dateFormat = "HH:mm"
                            let time = timeFormatter.stringFromDate(results[i].endDate)

                            
                            if identifier == HKQuantityTypeIdentifierDistanceWalkingRunning {
                                let count = (Int(results[i].quantity.doubleValueForUnit(HKUnit.meterUnit())))
                                resultArray.append("\(date)-\(time)-\(count)")
                            }
                            else {
                                let count = (Int(results[i].quantity.doubleValueForUnit(HKUnit.countUnit())))
                                resultArray.append("\(date)-\(time)-\(count)")
                            }
                        }
                        // print("Result for \(identifier): \(resultArray)")
                        completion?(resultArray)
                    }
                    self.count+=1
                }
                
                healthKitStore.executeQuery(stepsSampleQuery)
            }
    }
    
    private func getAbsoluteTotal(withQuantity identifier: String, completion: ((Int) -> Void)?) {
            if healthKitStore != nil {
                let stepsCount = HKQuantityType.quantityTypeForIdentifier(
                    identifier)!
                
                let sumOption = HKStatisticsOptions.CumulativeSum
                
                let statisticsSumQuery = HKStatisticsQuery(quantityType: stepsCount, quantitySamplePredicate: nil,
                    options: sumOption)
                { (query, result, error) in
                    var sum = 0
                    if let sumQuantity = result?.sumQuantity() {
                        if identifier == HKQuantityTypeIdentifierDistanceWalkingRunning { sum = Int(sumQuantity.doubleValueForUnit(HKUnit.meterUnit())) }
                        else { sum = Int(sumQuantity.doubleValueForUnit(HKUnit.countUnit())) }
                    }
                    completion?(sum)
                    self.count+=1
                }
                
                // Don't forget to execute the query!
                healthKitStore.executeQuery(statisticsSumQuery)
            }
    }
    
}