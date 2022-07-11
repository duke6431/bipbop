//
//  ViewController.swift
//  Example
//
//  Created by Duc IT. Nguyen Minh on 01/05/2022.
//

import UIKit

class ViewController: UIViewController {
    
    public lazy var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle("Tap me!", for: .normal)
        button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppDelegate.main?.mainGroup.execute()
    }
    
    func configureViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc func tapped() {
        let choice = Int.random(in: 0...1000) % 2
        if choice == 0 {
            navigationController?.pushViewController(ViewController(), animated: true)
        } else {
            navigationController?.present(UINavigationController(rootViewController: ViewController()), animated: true)
        }
    }
}

