//
//  HelperFunctions.swift
//  PrayerUmmah
//
//  Created by Jawwaad Sabree on 7/12/22.
//

import SwiftUI

func getCurrentDate() -> String {
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "dd-MM-yyyy"
    let stringDate = timeFormatter.string(from: Date())
    
    return stringDate
}

func getCurrentTime() -> String {
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "HH:mm"
    let stringDate = timeFormatter.string(from: Date())

    return stringDate
}

func to12hourString(time: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    guard let date = dateFormatter.date(from: time) else {
        print("error converting time")
        return ""
    }
    dateFormatter.dateFormat = "h:mm a"

    return dateFormatter.string(from: date)
}
