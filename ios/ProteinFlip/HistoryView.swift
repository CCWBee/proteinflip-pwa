import SwiftUI
import UIKit

struct HistoryView: View {
    @EnvironmentObject var proteinStore: ProteinStore
    @Environment(\.dismiss) private var dismiss
    @State private var month: Date = Date()

    var body: some View {
        NavigationStack {
            VStack {
                monthHeader
                weekdayHeader
                calendarGrid
                Spacer()
            }
            .padding()
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var monthHeader: some View {
        HStack {
            Button(systemName: "chevron.left") { changeMonth(-1) }
            Spacer()
            Text(monthTitle(month)).font(.headline)
            Spacer()
            Button(systemName: "chevron.right") { changeMonth(1) }
        }
    }

    private func monthTitle(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f.string(from: d)
    }

    private var weekdayHeader: some View {
        let symbols = Calendar.current.shortWeekdaySymbols // starts with Sun by default
        let ordered = Array(symbols[1...6] + symbols[0...0]) // Monday first
        return HStack {
            ForEach(ordered, id: \.self) { s in
                Text(s).font(.caption).foregroundStyle(.secondary).frame(maxWidth: .infinity)
            }
        }.padding(.vertical, 4)
    }

    private var calendarGrid: some View {
        let cal = Calendar.current
        let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: month))!
        let firstWeekday = (cal.component(.weekday, from: startOfMonth) + 5) % 7 // Monday index 0
        let days = proteinStore.monthData(for: month)
        let blanks = Array(repeating: "", count: firstWeekday)

        let cells: [AnyView] =
            blanks.map { _ in AnyView(Color.clear.frame(height: 56)) } +
            days.map { day in AnyView(dayCell(day.date, iso: day.iso, grams: day.grams)) }

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
            ForEach(cells.indices, id: \.self) { idx in cells[idx] }
        }
    }

    private func dayCell(_ date: Date, iso: String, grams: Int) -> some View {
        let day = Calendar.current.component(.day, from: date)
        let status = goalStatus(grams: grams)
        return VStack(spacing: 4) {
            ZStack {
                Circle().fill(status.colour.opacity(0.12))
                Circle().stroke(status.colour, lineWidth: 2)
                Text("\(day)").font(.callout).bold()
            }
            .frame(width: 36, height: 36)

            Text("\(grams) g")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(height: 56)
        .onTapGesture { showEdit(for: date, current: grams) }
        .accessibilityLabel(Text("Day \(day), \(grams) grams"))
    }

    private func goalStatus(grams: Int) -> (colour: Color, text: String) {
        if grams >= proteinStore.goalGrams { return (.green, "Goal hit") }
        if grams >= Int(Double(proteinStore.goalGrams) * 0.6) { return (.orange, "Nearly there") }
        return (.red, "Low")
    }

    private func showEdit(for date: Date, current: Int) {
        var newVal = current
        let alert = UIAlertController(title: "Edit grams", message: isoString(date: date), preferredStyle: .alert)
        alert.addTextField { tf in
            tf.keyboardType = .numberPad
            tf.text = "\(current)"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            if let t = alert.textFields?.first?.text, let g = Int(t) {
                newVal = max(0, g)
                proteinStore.set(for: date, grams: newVal)
            }
        }))
        UIApplication.shared.topMost?.present(alert, animated: true)
    }

    private func isoString(date: Date) -> String {
        ProteinStore.isoFormatter.string(from: date)
    }

    private func changeMonth(_ delta: Int) {
        if let d = Calendar.current.date(byAdding: .month, value: delta, to: month) {
            month = d
        }
    }
}

private extension Button where Label == Image {
    init(systemName: String, action: @escaping () -> Void) {
        self.init(action: action) { Image(systemName: systemName) }
    }
}

extension UIApplication {
    var topMost: UIViewController? {
        guard let scene = connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else { return nil }
        var top = root
        while let presented = top.presentedViewController { top = presented }
        return top
    }
}
