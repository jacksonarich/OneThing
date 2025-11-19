import AppModels
import SQLiteData
import SwiftUI


public struct FrequencyPicker: View {
  @Binding var frequencySelection: FrequencySelection
  @Binding var customFrequency: Frequency
  let actualFrequency: Frequency?
  
  public init(
    frequencySelection: Binding<FrequencySelection>,
    customFrequency: Binding<Frequency>,
    actualFrequency: Frequency?
  ) {
    self._frequencySelection = frequencySelection
    self._customFrequency = customFrequency
    self.actualFrequency = actualFrequency
  }
  
  var footer: String {
    if let frequency = actualFrequency?.localizedString {
      return "This thing will repeat \(frequency)."
    } else {
      return "This thing will never repeat."
    }
  }
  
  public var body: some View {
    NavigationLink {
      FrequencyPickerView(
        frequencySelection: $frequencySelection,
        customFrequency: $customFrequency,
        footer: footer
      )
    } label: {
      LabeledContent {
        Text(actualFrequency?.localizedString.sentenceCased ?? "Never")
      } label: {
        Label("Repeats", systemImage: "repeat")
      }
    }
  }
}


private struct FrequencyPickerView: View {
  @Binding var frequencySelection: FrequencySelection
  @Binding var customFrequency: Frequency
  let footer: String
  
  public init(
    frequencySelection: Binding<FrequencySelection>,
    customFrequency: Binding<Frequency>,
    footer: String
  ) {
    self._frequencySelection = frequencySelection
    self._customFrequency = customFrequency
    self.footer = footer
  }
  
  public var body: some View {
    List {
      Picker(
        "",
        selection: Binding(
          get: { frequencySelection },
          set: { selection in
            withAnimation {
              frequencySelection = selection
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
      
      if frequencySelection == .custom {
        Section {
          Picker("Frequency", selection: $customFrequency.unit) {
            ForEach(FrequencyUnit.allCases, id: \.self) { unit in
              Text("\(unit.rawValue.capitalized)")
                .tag(unit)
            }
          }
          .pickerStyle(.menu)
          .tint(.secondary)
          
          LabeledContent("Every") {
            TextField("Count", value: $customFrequency.count, format: .number)
              .keyboardType(.decimalPad)
              .multilineTextAlignment(.trailing)
          }
        } footer: {
          Text(footer)
        }
      }
    }
    .navigationTitle("Repeats")
    .navigationBarTitleDisplayMode(.inline)
  }
}


#Preview {
  @Previewable @State var selection = FrequencySelection.daily
  @Previewable @State var custom = Frequency(unit: .day)
  NavigationStack {
    List {
      FrequencyPicker(
        frequencySelection: $selection,
        customFrequency: $custom,
        actualFrequency: Frequency(
          selection: selection,
          custom: custom
        )
      )
    }
  }
  .accentColor(.pink)
}
