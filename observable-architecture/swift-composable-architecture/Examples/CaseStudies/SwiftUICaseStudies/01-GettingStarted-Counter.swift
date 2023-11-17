import ComposableArchitecture
import SwiftUI

private let readMe = """
  This screen demonstrates the basics of the Composable Architecture in an archetypal counter \
  application.

  The domain of the application is modeled using simple data types that correspond to the mutable \
  state of the application and any actions that can affect that state or the outside world.
  """

// MARK: - Feature domain

@Reducer
struct Counter {
  @ObservableState
  struct State: Equatable {
    var count = 0
    var isDisplayingCount = true
  }

  enum Action {
    case decrementButtonTapped
    case incrementButtonTapped
    case toggleIsDisplayingCount
    case resetButtonTapped
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .decrementButtonTapped:
        state.count -= 1
        return .none
      case .incrementButtonTapped:
        state.count += 1
        return .none
      case .toggleIsDisplayingCount:
        state.isDisplayingCount.toggle()
        return .none
      case .resetButtonTapped:
        state = State()
        return .none
      }
    }
  }
}

// MARK: - Feature view

struct CounterView: View {
  let store: StoreOf<Counter>

  var body: some View {
    let _ = Self._printChanges()
    VStack {
      HStack {
        Button {
          self.store.send(.decrementButtonTapped)
        } label: {
          Image(systemName: "minus")
        }

        if self.store.isDisplayingCount {
          Text("\(self.store.count)")
            .monospacedDigit()
        }

        Button {
          self.store.send(.incrementButtonTapped)
        } label: {
          Image(systemName: "plus")
        }
      }
      .padding()

      Button("Toggle count display") {
        self.store.send(.toggleIsDisplayingCount)
      }
      Button("Reset") {
        self.store.send(.resetButtonTapped)
      }
    }
  }
}

struct CounterDemoView: View {
  @State var store = Store(initialState: Counter.State()) {
    Counter()
  }

  var body: some View {
    Form {
      Section {
        AboutView(readMe: readMe)
      }

      Section {
        CounterView(store: self.store)
          .frame(maxWidth: .infinity)
      }
    }
    .buttonStyle(.borderless)
    .navigationTitle("Counter demo")
  }
}

// MARK: - SwiftUI previews

struct CounterView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      CounterDemoView(
        store: Store(initialState: Counter.State()) {
          Counter()
        }
      )
    }
  }
}
