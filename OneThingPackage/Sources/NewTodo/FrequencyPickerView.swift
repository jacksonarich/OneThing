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
        "",
        selection: Binding(
          get: { model.frequencySelection },
          set: { selection in
            withAnimation {
              model.frequencySelection = selection
            }
          }
        )
      ) {
        ForEach(FrequencySelection.allCases, id: \.self) { selection in
          Text(selection.rawValue.capitalized)
            .tag(selection)
        }
      }
      .pickerStyle(.inline)
      
      if model.frequencySelection == .custom {
        Section {
          Picker("Frequency", selection: $model.customFrequency.unit) {
            ForEach(FrequencyUnit.allCases, id: \.self) { unit in
              Text("\(unit.rawValue.capitalized)")
                .tag(unit)
            }
          }
          .pickerStyle(.menu)
          .tint(.secondary)
          
          LabeledContent("Every") {
            TextField("Count", value: $model.customFrequency.count, format: .number)
              .keyboardType(.decimalPad)
              .multilineTextAlignment(.trailing)
          }
        } footer: {
          if let frequency = model.frequency?.localizedString {
            Text("This thing will repeat \(frequency).")
          } else {
            Text("This thing will never repeat.")
          }
        }
      }
    }
    .navigationTitle("Repeats")
    .navigationBarTitleDisplayMode(.inline)
  }
}


#Preview {
  let _ = prepareDependencies {
    $0.defaultDatabase = try! appDatabase(data: .previewSeed)
  }
  
  let model = NewTodoModel(
    frequencySelection: .custom,
    customFrequency: Frequency(unit: .day, count: 1),
    listID: 1
  )
  NavigationStack {
    FrequencyPickerView(model: model)
  }
  .accentColor(.pink)
}
