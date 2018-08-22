//
//  Day.swift
//  IoTWeather
//
//  Created by steven freed on 8/18/18.
//  Copyright © 2018 steven freed. All rights reserved.
//

import Foundation
import UIKit

// Days in table view of WeatherUpdatesViewController
class Day {
    var day: String?
    var image: String?
    var high: Int?
    var low: Int?
    
    init(day: String?, image: String?, high: Int?, low: Int?) {
        self.day = day
        self.image = image
        self.high = high
        self.low = low
    }
    
    
}
