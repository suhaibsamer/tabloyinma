import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), prayerTimes: [:], nextPrayer: "مەغریب", nextPrayerTime: Date(), dua: "دوعای کاتژمێر...")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), prayerTimes: [:], nextPrayer: "مەغریب", nextPrayerTime: Date(), dua: "دوعای کاتژمێر...")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.com.example.tabloy_iman")
        let prayerTimesJson = userDefaults?.string(forKey: "prayer_times") ?? "{}"
        let duaBatchJson = userDefaults?.string(forKey: "dua_batch") ?? "[]"
        
        let prayerMap = decodePrayerTimes(json: prayerTimesJson)
        let duaArray = decodeDuaBatch(json: duaBatchJson)
        
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        
        // Generate entries for each hour to rotate Dua
        for hourOffset in 0 ..< 24 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let duaIndex = Calendar.current.component(.hour, from: entryDate) % max(duaArray.count, 1)
            let dua = duaArray.isEmpty ? "Open app to sync" : duaArray[duaIndex]
            
            let (nextName, nextTime) = getNextPrayer(prayerMap: prayerMap, for: entryDate)
            
            let entry = SimpleEntry(
                date: entryDate,
                prayerTimes: prayerMap,
                nextPrayer: nextName,
                nextPrayerTime: nextTime,
                dua: dua
            )
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func decodePrayerTimes(json: String) -> [String: String] {
        guard let data = json.data(using: .utf8) else { return [:] }
        return (try? JSONSerialization.jsonObject(with: data) as? [String: String]) ?? [:]
    }
    
    private func decodeDuaBatch(json: String) -> [String] {
        guard let data = json.data(using: .utf8) else { return [] }
        return (try? JSONSerialization.jsonObject(with: data) as? [String]) ?? []
    }
    
    private func getNextPrayer(prayerMap: [String: String], for date: Date) -> (String, Date) {
        let prayerNames = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]
        let kurdishNames = ["بەیانی", "نیوەڕۆ", "عەسر", "شێوان", "خەوتنان"]
        
        let calendar = Calendar.current
        let currentComp = calendar.dateComponents([.year, .month, .day], from: date)
        
        for i in 0..<prayerNames.count {
            if let timeStr = prayerMap[prayerNames[i]] {
                let parts = timeStr.split(separator: ":")
                if parts.count >= 2, let hour = Int(parts[0]), let minute = Int(parts[1]) {
                    var comp = currentComp
                    comp.hour = hour
                    comp.minute = minute
                    comp.second = 0
                    
                    if let pDate = calendar.date(from: comp), pDate > date {
                        return (kurdishNames[i], pDate)
                    }
                }
            }
        }
        
        // Fallback to Fajr tomorrow
        if let timeStr = prayerMap["Fajr"] {
            let parts = timeStr.split(separator: ":")
            if parts.count >= 2, let hour = Int(parts[0]), let minute = Int(parts[1]) {
                var comp = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: 1, to: date)!)
                comp.hour = hour
                comp.minute = minute
                comp.second = 0
                if let pDate = calendar.date(from: comp) {
                    return ("بەیانی (بەیانی)", pDate)
                }
            }
        }
        
        return ("---", date)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let prayerTimes: [String: String]
    let nextPrayer: String
    let nextPrayerTime: Date
    let dua: String
}

struct TabloyImanWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("تابلۆی ئیمان")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack {
                Text(entry.nextPrayer)
                    .font(.subheadline.bold())
                    .foregroundColor(Color(red: 34/255, green: 211/255, blue: 238/255))
                Text(entry.nextPrayerTime, style: .timer)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            
            HStack {
                PrayerTimeSmall(name: "بەیانی", time: entry.prayerTimes["Fajr"] ?? "--:--")
                PrayerTimeSmall(name: "نیوەڕۆ", time: entry.prayerTimes["Dhuhr"] ?? "--:--")
                PrayerTimeSmall(name: "عەسر", time: entry.prayerTimes["Asr"] ?? "--:--")
                PrayerTimeSmall(name: "شێوان", time: entry.prayerTimes["Maghrib"] ?? "--:--")
                PrayerTimeSmall(name: "خەوتنان", time: entry.prayerTimes["Isha"] ?? "--:--")
            }
            
            Text(entry.dua)
                .font(.system(size: 10))
                .foregroundColor(Color(red: 232/255, green: 226/255, blue: 255/255))
                .padding(6)
                .frame(maxWidth: .infinity)
                .background(Color(red: 19/255, green: 24/255, blue: 41/255))
                .cornerRadius(8)
                .lineLimit(2)
        }
        .padding()
        .background(Color(red: 11/255, green: 15/255, blue: 30/255))
    }
}

struct PrayerTimeSmall: View {
    let name: String
    let time: String
    var body: some View {
        VStack {
            Text(time).font(.system(size: 8))
            Text(name).font(.system(size: 7))
        }
        .foregroundColor(Color(white: 0.8))
        .frame(maxWidth: .infinity)
    }
}

struct TabloyImanWidget: Widget {
    let kind: String = "TabloyImanWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TabloyImanWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Tabloy Iman")
        .description("Prayer times and Dua dashboard.")
        .supportedFamilies([.systemMedium])
    }
}
