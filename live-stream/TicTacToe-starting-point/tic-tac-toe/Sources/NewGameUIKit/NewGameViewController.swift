import Combine
import ComposableArchitecture
import GameUIKit
import NewGameCore
import UIKit

public class NewGameViewController: UIViewController {
  let store: StoreOf<NewGame>
  private var cancellables: Set<AnyCancellable> = []

  public init(store: StoreOf<NewGame>) {
    self.store = store
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.title = "New Game"

    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Logout",
      style: .done,
      target: self,
      action: #selector(logoutButtonTapped)
    )

    let playerXLabel = UILabel()
    playerXLabel.text = "Player X"
    playerXLabel.setContentHuggingPriority(.required, for: .horizontal)

    let playerXTextField = UITextField()
    playerXTextField.borderStyle = .roundedRect
    playerXTextField.placeholder = "Blob Sr."
    playerXTextField.setContentCompressionResistancePriority(.required, for: .horizontal)
    playerXTextField.addTarget(
      self, action: #selector(playerXTextChanged(sender:)), for: .editingChanged
    )

    let playerXRow = UIStackView(arrangedSubviews: [
      playerXLabel,
      playerXTextField,
    ])
    playerXRow.spacing = 24

    let playerOLabel = UILabel()
    playerOLabel.text = "Player O"
    playerOLabel.setContentHuggingPriority(.required, for: .horizontal)

    let playerOTextField = UITextField()
    playerOTextField.borderStyle = .roundedRect
    playerOTextField.placeholder = "Blob Jr."
    playerOTextField.setContentCompressionResistancePriority(.required, for: .horizontal)
    playerOTextField.addTarget(
      self, action: #selector(playerOTextChanged(sender:)), for: .editingChanged
    )

    let playerORow = UIStackView(arrangedSubviews: [
      playerOLabel,
      playerOTextField,
    ])
    playerORow.spacing = 24

    let letsPlayButton = UIButton(type: .system)
    letsPlayButton.setTitle("Let’s Play!", for: .normal)
    letsPlayButton.addTarget(self, action: #selector(letsPlayTapped), for: .touchUpInside)

    let rootStackView = UIStackView(arrangedSubviews: [
      playerXRow,
      playerORow,
      letsPlayButton,
    ])
    rootStackView.isLayoutMarginsRelativeArrangement = true
    rootStackView.layoutMargins = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
    rootStackView.translatesAutoresizingMaskIntoConstraints = false
    rootStackView.axis = .vertical
    rootStackView.spacing = 24

    view.addSubview(rootStackView)

    NSLayoutConstraint.activate([
      rootStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      rootStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      rootStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])

    store.publisher.isLetsPlayButtonEnabled
      .assign(to: \.isEnabled, on: letsPlayButton)
      .store(in: &cancellables)

    store.publisher.oPlayerName
      .map(Optional.some)
      .assign(to: \.text, on: playerOTextField)
      .store(in: &cancellables)

    store.publisher.xPlayerName
      .map(Optional.some)
      .assign(to: \.text, on: playerXTextField)
      .store(in: &cancellables)

    var gameController: GameViewController?

    store
      .scope(state: \.game, action: \.game.presented)
      .ifLet(
        then: { [weak self] gameStore in
          guard gameController == nil else { return }
          gameController = GameViewController(store: gameStore)
          self?.navigationController?.pushViewController(gameController!, animated: true)
        },
        else: { [weak self] in
          guard let self else { return }
          navigationController?.popToViewController(self, animated: true)
          gameController = nil
        }
      )
      .store(in: &cancellables)
  }

  @objc private func logoutButtonTapped() {
    store.send(.logoutButtonTapped)
  }

  @objc private func playerXTextChanged(sender: UITextField) {
    store.xPlayerName = sender.text ?? ""
  }

  @objc private func playerOTextChanged(sender: UITextField) {
    store.oPlayerName = sender.text ?? ""
  }

  @objc private func letsPlayTapped() {
    store.send(.letsPlayButtonTapped)
  }
}

extension NewGame.State {
  fileprivate var isLetsPlayButtonEnabled: Bool {
    !oPlayerName.isEmpty && !xPlayerName.isEmpty
  }
}