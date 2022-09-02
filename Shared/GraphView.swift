//
//  FriendsView.swift
//  PrayerUmmah
//
//  Created by Jawwaad Sabree on 7/7/22.
//

import SwiftUI
import Charts

struct GraphView: View {
    @ObservedObject var prayerModel: PrayerModel
    @ObservedObject var userModel: UserModel
    @State var data: [UserPrayerData] = []

    var body: some View {
        VStack {
            Text("Prayer Stats")
            if #available(iOS 16.0, *) {
                Chart(data) {
                    if($0.Fajr) {
                        BarMark(
                            x: .value("Date", $0.formattedDate()),
                            y: .value("MadePrayers", 1)
                        )
                            .foregroundStyle(.blue)
                    }
                    if($0.Dhuhr) {
                        BarMark(
                            x: .value("Date", $0.formattedDate()),
                            y: .value("MadePrayers", 1)
                        )
                            .foregroundStyle(.orange)
                    }
                    if($0.Asr) {
                        BarMark(
                            x: .value("Date", $0.formattedDate()),
                            y: .value("MadePrayers", 1)
                        )
                            .foregroundStyle(.yellow)
                    }
                    if($0.Maghrib) {
                        BarMark(
                            x: .value("Date", $0.formattedDate()),
                            y: .value("MadePrayers", 1)
                        )
                            .foregroundStyle(.green)
                    }
                    if($0.Isha) {
                        BarMark(
                            x: .value("Date", $0.formattedDate()),
                            y: .value("MadePrayers", 1)
                        )
                            .foregroundStyle(.red)
                    }
                }
                    .frame(height: 500)
                    .padding(10)
                    .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisGridLine()
                    }
                    AxisMarks(values: .stride(by: .month)) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.month(.wide))
                    }
                }
                    .chartYAxis {
                    AxisMarks(position: .leading, values: stride(from: 0, to: 6, by: 1).map { $0 }) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(String($0.as(Int.self)!))
                    }
                }
                    .task {
                    let prayerData = await userModel.getPrayerHistory()
                    let sortedData = prayerData.sorted(by: { $0.formattedDate().compare($1.formattedDate()) == .orderedAscending })
                    data = sortedData
                }
                HStack {
                    VStack {
                        Text("Fajr")
                        Color
                            .blue
                            .frame(width: 10, height: 10)
                    }
                    VStack {
                        Text("Dhuhr")
                        Color
                            .orange
                            .frame(width: 10, height: 10)
                    }
                    VStack {
                        Text("Asr")
                        Color
                            .yellow
                            .frame(width: 10, height: 10)
                    }
                    VStack {
                        Text("Maghrib")
                        Color
                            .green
                            .frame(width: 10, height: 10)
                    }
                    VStack {
                        Text("Isha")
                        Color
                            .red
                            .frame(width: 10, height: 10)
                    }
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

func getStartDate() -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd"
    return formatter.date(from: "2022/09/01")!
}
func getEndDate() -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd"
    return formatter.date(from: "2022/09/30")!
}

struct Graph_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView()
        }
    }
}

