import AppDatabase
import AppModels
import SQLiteData
import SwiftUI
import Utilities


struct FrequencyPickerView: View {
  @Bindable var model: NewTodoModel
  
  public init(model: NewTodoModel) {
    self.model = model
  }
  
  var body: some View {
    List {
      Picker(
        "Frequency Selection",
        selection: Binding(
          get: { model.frequencySelection },
          set: { selection in
            withAnimation {
              model.frequencySelection = selection
            }
          }
        )
      ) {
        Text("Never")
          .tag(FrequencySelection.never)
        Text("Daily")
          .tag(FrequencySelection.daily)
        Text("Weekly")
          .tag(FrequencySelection.weekly)
        Text("Monthly")
          .tag(FrequencySelection.monthly)
        Text("Yearly")
          .tag(FrequencySelection.yearly)
        Text("Custom")
          .tag(FrequencySelection.custom)
      }
      .pickerStyle(.inline)
      
      Section {
        if model.frequencySelection == .custom {
          Picker("Frequency", selection: $model.customFrequency.unit) {
            ForEach(FrequencyUnit.allCases, id: \.self) { fu in
              Text("\(fu.rawValue)\(model.customFrequency.count == 1 ? "" : "s")")
                .tag(fu)
            }
          }
          .pickerStyle(.menu)
          .tint(.secondary)
          
          LabeledContent("Every") {
            TextField("Every", value: $model.customFrequency.count, format: .number)
              .keyboardType(.decimalPad)
              .multilineTextAlignment(.trailing)
          }
        }
      }
    }
  }
}

#Preview {
  let _ = prepareDependencies {
    $0.defaultDatabase = try! appDatabase(
      lists: .preset(),
      todos: .preset()
    )
  }
  
  let model = NewTodoModel(
    frequencySelection: .custom,
    customFrequency: Frequency(unit: .day, count: 1),
    listID: 1
  )
  NavigationStack {
    FrequencyPickerView(model: model)
  }
}
