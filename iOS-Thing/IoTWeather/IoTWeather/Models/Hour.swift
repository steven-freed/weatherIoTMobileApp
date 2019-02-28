//
//  Hour.swift
//  IoTWeather
//
//  Created by steven freed on 8/18/18.
//  Copyright © 2018 steven freed. All rights reserved.
//

import Foundation

// Hours in collection view of WeatherUpdatesViewController
class Hour {
    
    var hour: String?
    var image: String?
    var temp: Int?
    
    init(hour: String?, image: String?, temp: Int?) {
        self.hour = hour
        self.image = image
        self.temp = temp
    }
}
