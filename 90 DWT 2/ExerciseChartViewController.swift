//
//  ExerciseChartViewController.swift
//  90 DWT 2
//
//  Created by Grant, Jared on 7/20/16.
//  Copyright © 2016 Grant, Jared. All rights reserved.
//

import UIKit
import CoreData
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ExerciseChartViewController: UIViewController, SChartDatasource {
    
    @IBOutlet weak var chartView: UIView!
    
    var session = ""
    var selectedWorkout = ""
    var exerciseName = ""
    var graphDataPoints = [String?]()
    var workoutIndex = 0
    var numberOfSeriesToShow = 0
    var seriesConfiguration = 0
    
    var workoutObjects = [Workout]()
    
    @IBAction func dismissButtonPressed(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        // Create the chart
        let chart = ShinobiChart(frame: chartView.bounds.insetBy(dx: 0, dy: 0))
        chart.title = exerciseName
        chart.titleLabel.textColor = UIColor (red: 203/255, green: 116/255, blue: 49/255, alpha: 1)
        chart.titleCentresOn = SChartTitleCentresOn.chart
        
        chart.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        // Add a pair of axes
        let xAxis = SChartCategoryAxis()
        xAxis.title = "Attempt at Workout"
        xAxis.style.titleStyle.font = UIFont(name: "HelveticaNeue-Light", size: 17)!
        //xAxis.rangePaddingLow = @(0.05);
        //xAxis.rangePaddingHigh = @(0.3);
        chart.xAxis = xAxis;
        
        let yAxis = SChartNumberAxis()
        if seriesConfiguration == 100000 ||
            seriesConfiguration == 101000 ||
            seriesConfiguration == 101010 {
            
            // This configuration only has data for Reps
            yAxis.title = "Reps"
        }
        else {
            
            yAxis.title = "Reps / Weight"
            yAxis.rangePaddingHigh = 1
        }
        yAxis.style.titleStyle.font = UIFont(name: "HelveticaNeue-Light", size: 17)!
        chart.yAxis = yAxis;

        // Add chart to the view
        chartView.addSubview(chart)

        // This view controller will provide data to the chart
        chart.datasource = self
        
        // Show the legend on all devices
        chart.legend.isHidden = false
        chart.legend.style.font = UIFont(name: "HelveticaNeue-Light", size: 17)
        chart.legend.placement = .outsidePlotArea
        chart.legend.position = .bottomMiddle
        
        // Enable gestures
        yAxis.enableGesturePanning = true;
        yAxis.enableGestureZooming = true;
        xAxis.enableGesturePanning = true;
        xAxis.enableGestureZooming = true;
        
        // Show the x and y axis gridlines
        xAxis.style.majorGridLineStyle.showMajorGridLines = true;
        yAxis.style.majorGridLineStyle.showMajorGridLines = true;
    }
    
    // MARK:- SChartDatasource Functions
    
    func numberOfSeries(in chart: ShinobiChart) -> Int {
        
        // 1 input fields = 1 series (Rep 1)
        // 2 input fields = 2 series (Rep 1 and Weight 1) or (Rep 1 and Rep 2)
        // 3 input fields = 3 series (Rep 1, Rep 2, Rep 3)
        // 4 input fields = 4 series (Rep 1, Rep 2, and Weight 1, Weight 2)
        // 6 input fields = 6 series (Rep 1, Rep 2, Rep 3, and Weight 1, Weight 2, Weight 3)
        return self.numberOfSeriesToShow
    }
    
    func sChart(_ chart: ShinobiChart, seriesAt index: Int) -> SChartSeries {
        
        // Reps
        // ColumnSeries
        let columnSeries = SChartColumnSeries()
        
        // Weight
        // LineSeries
        let lineSeries = SChartLineSeries()
        
        lineSeries.style().lineWidth = 5
        lineSeries.style().pointStyle().showPoints = true
        lineSeries.style().pointStyle().radius = 20
        lineSeries.style().pointStyle().innerRadius = 10
        lineSeries.style().pointStyle().innerColor = UIColor.white

        switch seriesConfiguration {
        case 111111:
            if index == 0 || index == 1 || index == 2 {
                
                switch index {
                case 0:
                    columnSeries.title = "1-R"
                    //columnSeries.style().areaColor = UIColor (red: 9/255, green: 74/255, blue: 191/255, alpha: 1)
                    //columnSeries.style().showAreaWithGradient = false
                    
                case 1:
                    columnSeries.title = "2-R"
                    //columnSeries.style().areaColor = UIColor (red: 218/255, green: 14/255, blue: 16/255, alpha: 1)
                    //columnSeries.style().showAreaWithGradient = false
                    
                default:
                    //case = 2
                    columnSeries.title = "3-R"
                    //columnSeries.style().areaColor = UIColor (red: 218/255, green: 14/255, blue: 16/255, alpha: 1)
                    //columnSeries.style().showAreaWithGradient = false
                }
                return columnSeries
            }
            else {
                
                switch index {
                case 3:
                    lineSeries.title = "1-W"
                    //lineSeries.style().lineColor = UIColor (red: 1/255, green: 133/255, blue: 214/255, alpha: 1)
                    //lineSeries.style().pointStyle().color = UIColor (red: 1/255, green: 133/255, blue: 214/255, alpha: 1)
                    
                case 4:
                    lineSeries.title = "2-W"
                    //lineSeries.style().lineColor = UIColor (red: 241/255, green: 3/255, blue: 125/255, alpha: 1)
                    //lineSeries.style().pointStyle().color = UIColor (red: 241/255, green: 3/255, blue: 125/255, alpha: 1)
                    
                default:
                    //case = 5
                    lineSeries.title = "3-W"
                    //lineSeries.style().lineColor = UIColor (red: 241/255, green: 3/255, blue: 125/255, alpha: 1)
                    //lineSeries.style().pointStyle().color = UIColor (red: 241/255, green: 3/255, blue: 125/255, alpha: 1)
                }
                
                return lineSeries
            }

        case 101010:
            switch index {
            case 0:
                columnSeries.title = "1-R"
                //columnSeries.style().areaColor = UIColor (red: 9/255, green: 74/255, blue: 191/255, alpha: 1)
                //columnSeries.style().showAreaWithGradient = false
                
            case 1:
                columnSeries.title = "2-R"
                //columnSeries.style().areaColor = UIColor (red: 218/255, green: 14/255, blue: 16/255, alpha: 1)
                //columnSeries.style().showAreaWithGradient = false
                
            default:
                // case 3:
                columnSeries.title = "3-R"
                //columnSeries.style().areaColor = UIColor (red: 218/255, green: 14/255, blue: 16/255, alpha: 1)
                //columnSeries.style().showAreaWithGradient = false
            }
            
            return columnSeries
            
        case 111100:
            if index == 0 || index == 1 {
                
                switch index {
                case 0:
                    columnSeries.title = "1-R"
                    //columnSeries.style().areaColor = UIColor (red: 9/255, green: 74/255, blue: 191/255, alpha: 1)
                    //columnSeries.style().showAreaWithGradient = false
                    
                default:
                    //case = 1
                    columnSeries.title = "2-R"
                    //columnSeries.style().areaColor = UIColor (red: 218/255, green: 14/255, blue: 16/255, alpha: 1)
                    //columnSeries.style().showAreaWithGradient = false
                }
                
                return columnSeries
            }
            else {
                
                switch index {
                case 2:
                    lineSeries.title = "1-W"
                    //lineSeries.style().lineColor = UIColor (red: 1/255, green: 133/255, blue: 214/255, alpha: 1)
                    //lineSeries.style().pointStyle().color = UIColor (red: 1/255, green: 133/255, blue: 214/255, alpha: 1)
                    
                default:
                    //case = 3
                    lineSeries.title = "2-W"
                    //lineSeries.style().lineColor = UIColor (red: 241/255, green: 3/255, blue: 125/255, alpha: 1)
                    //lineSeries.style().pointStyle().color = UIColor (red: 241/255, green: 3/255, blue: 125/255, alpha: 1)
                }
                
                return lineSeries
            }

        case 101000:
            switch index {
            case 0:
                columnSeries.title = "1-R"
                //columnSeries.style().areaColor = UIColor (red: 9/255, green: 74/255, blue: 191/255, alpha: 1)
                //columnSeries.style().showAreaWithGradient = false
                
            default:
                //case = 1
                columnSeries.title = "2-R"
                //columnSeries.style().areaColor = UIColor (red: 218/255, green: 14/255, blue: 16/255, alpha: 1)
                //columnSeries.style().showAreaWithGradient = false
            }
            
            return columnSeries

        case 110000:
            switch index {
            case 0:
                columnSeries.title = "1-R"
                //columnSeries.style().areaColor = UIColor (red: 9/255, green: 74/255, blue: 191/255, alpha: 1)
                //columnSeries.style().showAreaWithGradient = false
                
                return columnSeries
                
            default:
                // case 1:
                lineSeries.title = "1-W"
                //lineSeries.style().lineColor = UIColor (red: 1/255, green: 133/255, blue: 214/255, alpha: 1)
                //lineSeries.style().pointStyle().color = UIColor (red: 1/255, green: 133/255, blue: 214/255, alpha: 1)
                
                return lineSeries
            }
        default:
            // case 100000:
            columnSeries.title = "1-R"
            //columnSeries.style().areaColor = UIColor (red: 9/255, green: 74/255, blue: 191/255, alpha: 1)
            //columnSeries.style().showAreaWithGradient = false
            
            return columnSeries
        }
    }
    
    func sChart(_ chart: ShinobiChart, numberOfDataPointsForSeriesAt seriesIndex: Int) -> Int {
        
        // Number of data points for the X-Axis.
        // Get the max index for the workout.
        return self.findMaxIndexForWorkout()
    }
    
    func sChart(_ chart: ShinobiChart, dataPointAt dataIndex: Int, forSeriesAt seriesIndex: Int) -> SChartData {
    
        let dataPoint = SChartDataPoint()
        dataPoint.xValue = dataIndex + 1
        
        switch seriesConfiguration {
        case 111111:
            switch seriesIndex {
            case 0:
                // Reps 1
                dataPoint.yValue = Double(CDOperation.getRepsTextForExerciseRound(self.session, workout: self.selectedWorkout, exercise: self.exerciseName, round: "Round 1", index: (dataIndex + 1) as NSNumber)!)
                
            case 1:
                // Reps 2
                dataPoint.yValue = Double(CDOperation.getRepsTextForExerciseRound(self.session, workout: self.selectedWorkout, exercise: self.exerciseName, round: "Round 2", index: (dataIndex + 1) as NSNumber)!)
                
            case 2:
                // Reps 3
                dataPoint.yValue = Double(CDOperation.getRepsTextForExerciseRound(self.session, workout: self.selectedWorkout, exercise: self.exerciseName, round: "Round 3", index: (dataIndex + 1) as NSNumber)!)
                
            case 3:
                // Weight 1
                dataPoint.yValue = Double(CDOperation.getWeightTextForExerciseRound(self.session, workout: self.selectedWorkout, exercise: self.exerciseName, round: "Round 1", index: (dataIndex + 1) as NSNumber)!)
                
            case 4:
                // Weight 2
                dataPoint.yValue = Double(CDOperation.getWeightTextForExerciseRound(self.session, workout: self.selectedWorkout, exercise: self.exerciseName, round: "Round 2", index: (dataIndex + 1) as NSNumber)!)
                
            default:
                // seriesIndex = 5
                // Weight 3
                dataPoint.yValue = Double(CDOperation.getWeightTextForExerciseRound(self.session, workout: self.selectedWorkout, exercise: self.exerciseName, round: "Round 3", index: (dataIndex + 1) as NSNumber)!)
            }

        case 101010:
            switch seriesIndex {
            case 0:
                // Reps 1
                dataPoint.yValue = Double(CDOperation.getRepsTextForExerciseRound(self.session, workout: self.selectedWorkout, exercise: self.exerciseName, round: "Round 1", index: (dataIndex + 1) as NSNumber)!)
                
            case 1:
                // Reps 2
                dataPoint.yValue = Double(CDOperation.getRepsTextForExerciseRound(self.session, workout: self.selectedWorkout, exercise: self.exerciseName, round: "Round 2", index: (dataIndex + 1) as NSNumber)!)
                
            default:
                // case 2:
                // Reps 3
                dataPoint.yValue = Double(CDOperation.getRepsTextForExerciseRound(self.session, workout: self.selectedWorkout, exercise: self.exerciseName, round: "Round 3", index: (dataIndex + 1) as NSNumber)!)
            }

        case 111100:
            switch seriesIndex {
            case 0:
                // Reps 1
                dataPoint.yValue = Double(CDOperation.getRepsTextForExerciseRound(self.session, workout: self.selectedWorkout, exercise: self.exerciseName, round: "Round 1", index: (dataIndex + 1) as NSNumber)!)
                
            case 1:
                // Reps 2
                dataPoint.yValue = Double(CDOperation.getRepsTextForExerciseRound(self.session, workout: self.selectedWorkout, exercise: self.exerciseName, round: "Round 2", index: (dataIndex + 1) as NSNumber)!)
                
            case 2:
                // Weight 1
                dataPoint.yValue = Double(CDOperation.getWeightTextForExerciseRound(self.session, workout: self.selectedWorkout, exercise: self.exerciseName, round: "Round 1", index: (dataIndex + 1) as NSNumber)!)
                
            default:
                // case 3:
                // Weight 2
                dataPoint.yValue = Double(CDOperation.getWeightTextForExerciseRound(self.session, workout: self.selectedWorkout, exercise: self.exerciseName, round: "Round 2", index: (dataIndex + 1) as NSNumber)!)
            }

        case 101000:
            switch seriesIndex {
            case 0:
                // Reps 1
                dataPoint.yValue = Double(CDOperation.getRepsTextForExerciseRound(self.session, workout: self.selectedWorkout, exercise: self.exerciseName, round: "Round 1", index: (dataIndex + 1) as NSNumber)!)
                
            default:
                // case 1:
                // Reps 2
                dataPoint.yValue = Double(CDOperation.getRepsTextForExerciseRound(self.session, workout: self.selectedWorkout, exercise: self.exerciseName, round: "Round 2", index: (dataIndex + 1) as NSNumber)!)
            }

        case 110000:
            switch seriesIndex {
            case 0:
                // Reps 1
                dataPoint.yValue = Double(CDOperation.getRepsTextForExerciseRound(self.session, workout: self.selectedWorkout, exercise: self.exerciseName, round: "Round 1", index: (dataIndex + 1) as NSNumber)!)
                
            default:
                // case 1:
                // Weight 1
                dataPoint.yValue = Double(CDOperation.getWeightTextForExerciseRound(self.session, workout: self.selectedWorkout, exercise: self.exerciseName, round: "Round 1", index: (dataIndex + 1) as NSNumber)!)
            }
            
        default:
            // case 100000:
            // Reps 1
            dataPoint.yValue = Double(CDOperation.getRepsTextForExerciseRound(self.session, workout: self.selectedWorkout, exercise: self.exerciseName, round: "Round 1", index: (dataIndex + 1) as NSNumber)!)
        }
        
        return dataPoint
    }
    
    // MARK:- Utility Methods
    
    func findMaxIndexForWorkout() -> Int {
        
        // Normal
        switch self.selectedWorkout {
        case "Complete Fitness & Ab Workout":
            return 4
            
        case "Strength + Stability":
            return 4
            
        case "Chest + Back + Stability & Ab Workout":
            return 4
            
        case "Shoulder + Bi + Tri & Ab Workout":
            return 4
            
        case "Legs + Back & Ab Workout":
            return 4
            
        default:
            // Core Fitness
            return 4
        }
    }
}
