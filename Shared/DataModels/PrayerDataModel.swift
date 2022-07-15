//
//  PrayerDataModel.swift
//  PrayerUmmah
//
//  Created by Jawwaad Sabree on 7/7/22.
//

import Foundation
import SwiftUI

struct PrayerData: Codable {
    let code: Int
    let status: String
    let data: [Prayer]
}

struct Prayer: Hashable, Codable {
    let timings: [String: String]
    let date: DateClass
    let meta: Meta
}

struct DateClass: Hashable, Codable {
    let readable, timestamp: String
    let gregorian: Gregorian
    let hijri: Hijri
}

struct Gregorian: Hashable, Codable {
    let date: String
    let format: String
    let day: String
    let weekday: Weekday
    let month: Month
    let year: String
    let designation: Designation
}

struct Designation: Hashable, Codable {
    let abbreviated, expanded: String
}

struct Month: Hashable, Codable {
    let number: Int
    let en: String
    let ar: String?
}

struct Weekday: Hashable, Codable {
    let en: String
    let ar: String?
}

struct Hijri: Hashable, Codable {
    let date: String
    let format: String
    let day: String
    let weekday: Weekday
    let month: Month
    let year: String
    let designation: Designation
    let holidays: [String]
}

struct Meta: Hashable, Codable {
    let latitude, longitude: Double
    let timezone: String
    let method: Method
    let latitudeAdjustmentMethod: String
    let midnightMode, school: String
    let offset: [String: Int]
}

struct Method: Hashable, Codable {
    let id: Int
    let name: String
    let params: Params
    let location: Location
}

struct Location: Hashable, Codable {
    let latitude, longitude: Double
}

struct Params: Hashable, Codable {
    let Fajr, Isha: Int
}

class PrayerModel: ObservableObject {
    @Published var prayers: KeyValuePairs<String, String> = [:]
    @Published var currPrayer: String = "Fajr"
    @Published var selectedPrayer: String = "Fajr"
    
    func getCurrentPrayer() {
        let currTime = getCurrentTime()
        let fajrTime = prayers[0].value
        let dhuhrTime = prayers[1].value
        let asrTime = prayers[2].value
        let magrhibTime = prayers[3].value
        let ishaTime = prayers[4].value

        switch currTime {
        case fajrTime..<dhuhrTime:
            self.currPrayer = "Fajr"
            self.selectedPrayer = "Fajr"
        case dhuhrTime..<asrTime:
            self.currPrayer = "Dhuhr"
            self.selectedPrayer = "Dhuhr"
        case asrTime..<magrhibTime:
            self.currPrayer = "Asr"
            self.selectedPrayer = "Asr"
        case magrhibTime..<ishaTime:
            self.currPrayer = "Maghrib"
            self.selectedPrayer = "Maghrib"
        default:
            self.currPrayer = "Isha"
            self.selectedPrayer = "Isha"
        }
    }

    func fetch () {
        var components = URLComponents()
            components.scheme = "https"
            components.host = "api.aladhan.com"
            components.path = "/v1/calendarByCity"
            components.queryItems = [
                URLQueryItem(name: "city", value: "Atlanta"),
                URLQueryItem(name: "country", value: "United States"),
                URLQueryItem(name: "method", value: "2"),
                URLQueryItem(name: "month", value: "07"),
                URLQueryItem(name: "year", value: "2022")
            ]
        guard let url = components.url else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                return
            }

            do {
                let prayerData = try JSONDecoder().decode(PrayerData.self, from: data)
                let todayPrayers = prayerData.data.first(where: {$0.date.gregorian.date == getCurrentDate()})

                DispatchQueue.main.async {
                    self?.prayers = [
                        "Fajr": todayPrayers?.timings["Fajr"]?
                            .replacingOccurrences(of: "(EDT)", with: "") ?? "",
                        "Dhuhr": todayPrayers?.timings["Dhuhr"]?
                            .replacingOccurrences(of: "(EDT)", with: "") ?? "",
                        "Asr": todayPrayers?.timings["Asr"]?
                            .replacingOccurrences(of: "(EDT)", with: "") ?? "",
                        "Maghrib": todayPrayers?.timings["Maghrib"]?
                            .replacingOccurrences(of: "(EDT)", with: "") ?? "",
                        "Isha": todayPrayers?.timings["Isha"]?
                            .replacingOccurrences(of: "(EDT)", with: "") ?? ""
                    ]
                    self?.getCurrentPrayer()
                    NotificationManager.instance.schedulePrayerNotifications(prayers: self?.prayers ?? ["Fajr": "05:00"])
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
}
