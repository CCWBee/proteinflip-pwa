import SwiftUI

struct GoalsView: View {
    @EnvironmentObject var proteinStore: ProteinStore
    @Environment(\.dismiss) private var dismiss

    @State private var goal: Double = 130
    @State private var weight: String = ""
    @State private var unit: Unit = .kg

    enum Unit: String, CaseIterable, Identifiable {
        case kg, lb
        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("daily goal")) {
                    Stepper(value: $goal, in: 40...300, step: 1) {
                        Text("\(Int(goal)) g")
                    }
                    Button("Save") {
                        proteinStore.goalGrams = Int(goal)
                        dismiss()
                    }
                }

                Section(header: Text("I dont know, help me set it")) {
                    HStack {
                        TextField("Your weight", text: $weight)
                            .keyboardType(.decimalPad)
                        Picker("", selection: $unit) {
                            ForEach(Unit.allCases) { u in
                                Text(u.rawValue.uppercased()).tag(u)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 120)
                    }
                    Button("Calculate 1.7 g per kg") {
                        guard let w = Double(weight) else { return }
                        let kg = unit == .kg ? w : w * 0.45359237
                        let g = Int((kg * 1.7).rounded())
                        goal = Double(g)
                        proteinStore.goalGrams = g
                        Haptics.success()
                    }
                }

                Section(header: Text("about")) {
                    Text("Helper multiplies your weight in kilograms by 1.7.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Goals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear { goal = Double(proteinStore.goalGrams) }
        }
    }
}
