import AppModels
import SwiftUI

struct FrequencyPicker: View {
  // needs to include unit and count
  // should not be @State
  @State private var selection: String? = nil
  
  let allUnits: [FrequencyUnit] = [.day, .week, .month, .year]
  var body: some View {
    Picker("Recurs", systemImage: "repeat", selection: $selection) {
      Text("Never")
        .tag(nil as String?)
      ForEach(allUnits, id: \.self) { unit in
        Text(unit.rawValue)
          .tag(unit.rawValue)
      }
      Text("Custom")
        .tag("Custom")
    }
  }
}

#Preview {
  List {
    FrequencyPicker()
  }
}
