import Foundation
import Combine

final class ProteinStore: ObservableObject {
    @Published var todayGrams: Int
    @Published var goalGrams: Int {
        didSet { defaults.set(goalGrams, forKey: Self.goalKey) }
    }

    private var daily: [String: Int]
    private let defaults = UserDefaults.standard

    private static let logKey = "protein.daily"
    private static let goalKey = "protein.goal"

    static let isoFormatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .iso8601)
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    init() {
        goalGrams = defaults.integer(forKey: Self.goalKey)
        daily = defaults.dictionary(forKey: Self.logKey) as? [String: Int] ?? [:]
        let todayIso = Self.isoFormatter.string(from: Date())
        todayGrams = daily[todayIso] ?? 0
    }

    func add(grams: Int) {
        handleRolloverIfNeeded()
        let todayIso = Self.isoFormatter.string(from: Date())
        todayGrams += grams
        daily[todayIso] = todayGrams
        defaults.set(daily, forKey: Self.logKey)
    }

    func set(for date: Date, grams: Int) {
        let iso = Self.isoFormatter.string(from: date)
        daily[iso] = grams
        if Calendar.current.isDateInToday(date) {
            todayGrams = grams
        }
        defaults.set(daily, forKey: Self.logKey)
    }

    func monthData(for date: Date) -> [(date: Date, iso: String, grams: Int)] {
        var comps = Calendar.current.dateComponents([.year, .month], from: date)
        comps.day = 1
        guard let start = Calendar.current.date(from: comps),
              let range = Calendar.current.range(of: .day, in: .month, for: start) else { return [] }
        return range.compactMap { day -> (Date, String, Int)? in
            comps.day = day
            guard let d = Calendar.current.date(from: comps) else { return nil }
            let iso = Self.isoFormatter.string(from: d)
            let grams = daily[iso] ?? 0
            return (d, iso, grams)
        }
    }

    func handleRolloverIfNeeded() {
        let todayIso = Self.isoFormatter.string(from: Date())
        if let stored = daily[todayIso] {
            todayGrams = stored
        } else {
            todayGrams = 0
            daily[todayIso] = 0
            defaults.set(daily, forKey: Self.logKey)
        }
    }
}

