import UIKit
import Kingfisher

class ProfileViewController: UIViewController {
    
    private let tokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private let placeholderImage = UIImage(named: "placeholder")
    
    private let userAvatar: UIImageView = {
        let view = UIImageView()
        let size: CGFloat = 70
        view.widthAnchor.constraint(equalToConstant: size).isActive = true
        view.heightAnchor.constraint(equalToConstant: size).isActive = true
        view.layer.cornerRadius = size / 2
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let exitButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(named: "Exit-icon"), for: .normal)
        let size: CGFloat = 24
        view.widthAnchor.constraint(equalToConstant: size).isActive = true
        view.heightAnchor.constraint(equalToConstant: size).isActive = true
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let hStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let vStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .leading
        view.distribution = .fillProportionally
        view.spacing = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let mainStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .leading
        view.spacing = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let namePrimary: UILabel = {
        let view = UILabel()
        view.text = "Екатерина Новикова"
        view.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        view.textColor = .ypWhite_1
        return view
    }()
    
    private let nameSecondary: UILabel = {
        let view = UILabel()
        view.text = "@ekaterina_nov"
        view.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        view.textColor = .ypGray
        return view
    }()
    
    private let userMessage: UILabel = {
        let view = UILabel()
        view.text = "Hello, world!"
        view.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        view.textColor = .ypWhite_1
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setupStackView()
        setupView()
        addConstraints()
        exitButton.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        loadProfileData() // Загружаем данные
        updateAvatar()
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
        
    }
    
    private func setupView() {
        view.addSubview(mainStack)
    }
    
    private func setupStackView() {
        [userAvatar, UIView(), exitButton].forEach { hStack.addArrangedSubview($0) }
        [namePrimary, nameSecondary, userMessage].forEach { vStack.addArrangedSubview($0) }
        [hStack, vStack].forEach { mainStack.addArrangedSubview($0) }
    }
    
    private func loadProfileData() {
        guard let token = tokenStorage.token else {
            print("Token not found!")
            return
        }
        
        profileService.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self?.updateUI(with: profile)
                case .failure(let error):
                    self?.showError(error)
                }
            }
        }
    }
 
    private func updateUI(with profile: Profile) {
        guard let profile = profileService.profile else {
            print("[updateUI]: No profile data found. Check your request.")
            return
        }
        print("[updateUI]: Profile data has been found. Updating UI...")
        
        // Обновляем текстовые элементы
        namePrimary.text = profile.firstName
        nameSecondary.text = "@\(profile.username)"
        userMessage.text = profile.bio
        
        // Загружаем картинку профиля
        if let avatarURL = ProfileImageService.shared.avatarURL {
            loadImage(from: avatarURL)
        } else {
            print("[updateUI]: No avatar URL found")
        }
    }

    // MARK: - Загрузка изображения
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("[loadImage]: Invalid URL for profile image")
            return
        }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async { [weak self] in
                    self?.userAvatar.image = UIImage(data: data)
                }
            } else {
                print("[loadImage]: Failed to load image from URL")
            }
        }
    }

    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to load profile: \(error.localizedDescription)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

//MARK: TODO
extension ProfileViewController {
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        print("[updateAvatar]: calling kinfisher")
        userAvatar.kf.setImage(with: url, placeholder: placeholderImage, options: [.keepCurrentImageWhileLoading])
        // TODO [Sprint 11] Обновить аватар, используя Kingfisher
    }
    
    @objc
    private func handleLogout() {
        let alert = UIAlertController(
            title: "Хочешь выйти?",
            message: "а не получится",
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: "Выйти", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            //MARK: Крашится, пока отключено
//            tokenStorage.removeToken()
//            
//            self.backToRoorController()
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @objc
    private func backToRoorController() {   //MARK: Second login crash, no window awaliable
        guard let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("[backToRoorController()]: Ошибка: нет сцены доступной для отображения.")
            return
        }
        
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
        window.makeKeyAndVisible()
    }


}
extension ProfileViewController {
    private func addConstraints() {
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            hStack.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor),
            hStack.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor),
            vStack.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor)
        ])
    }
}
