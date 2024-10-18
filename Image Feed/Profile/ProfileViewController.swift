import UIKit

class ProfileViewController: UIViewController {
    
    private let userAvatar:UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "Avatar")
        view.backgroundColor = .lightGray
        let size:CGFloat = 70
        view.widthAnchor.constraint(equalToConstant: size).isActive = true
        view.heightAnchor.constraint(equalToConstant: size).isActive = true
        view.layer.cornerRadius = size / 2
        //
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let exitButton:UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(named: "Exit-icon"), for: .normal)
        let size:CGFloat = 24
        view.widthAnchor.constraint(equalToConstant: size).isActive = true
        view.heightAnchor.constraint(equalToConstant: size).isActive = true
        //
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let hStack:UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let vStack:UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .leading
        view.distribution = .fillProportionally
        view.spacing = 8
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let mainStack:UIStackView = { //main stack
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .leading
        view.spacing = 8
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let namePrimary:UILabel = {
        let view = UILabel()
        view.text = "Екатерина Новикова"
        view.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        view.textColor = .ypWhite_1
        return view
    }()
    
    private let nameSecondary:UILabel = {
        let view = UILabel()
        view.text = "@ekaterina_nov"
        view.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        view.textColor = .ypGray
        return view
    }()
    
    private let userMessage:UILabel = {
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
        // Do any additional setup after loading the view.
    }
    
    private func setupView() {
        view.addSubview(mainStack)
    }
    
    private func setupStackView() { //Кастыль с пустым вью. Делал так ещё с flex box в CSS
        [userAvatar,UIView(),exitButton].forEach({hStack.addArrangedSubview($0)})
        [namePrimary,nameSecondary,userMessage].forEach({vStack.addArrangedSubview($0)})
        [hStack,vStack].forEach({mainStack.addArrangedSubview($0)})
    }
}

extension ProfileViewController {
    private func addConstraints() {
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,constant: -16),
            //
            hStack.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor),
            hStack.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor),
            vStack.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor)
        ])
    }
}

