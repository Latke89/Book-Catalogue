//
//  ConfirmationViewController.swift
//  BookCatalogue
//
//  Created by Brett Gordon on 3/19/26.
//

import Foundation
import UIKit

class ConfirmationViewController: UIViewController {
    
    var viewModel: ConfirmationViewModel
    var contentStack = UIStackView()
    var isOwnedToggle = UISwitch()
    var isOwnedButton = UIButton(configuration: .plain())
    var statusButton = UIButton(configuration: .plain())
    var saveButton = UIButton()
    var cancelButton = UIButton()
    
    init(viewModel: ConfirmationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = viewModel.book.title
        
        isOwnedToggle.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
    }
    
    @objc func switchToggled(_ sender: UISwitch) {
        print("New Value: \(sender.isOn)")
        viewModel.book.owned = sender.isOn
    }
    
    func setupOwnedMenu() -> UIMenu {
        let actions = [
            UIAction(title: "Want to Own") { _ in
                self.viewModel.book.owned = false
                self.isOwnedButton.setTitle("Want", for: .normal)
            },
            UIAction(title: "Owned") { _ in
                self.viewModel.book.owned = true
                self.isOwnedButton.setTitle("Owned", for: .normal)
            }
        ]
        
        return UIMenu(children: actions)
    }
    
    func setupStatusMenu() -> UIMenu {
        let actions = [
            UIAction(title: "Did Not Finish") { _ in
                self.viewModel.book.status = .dnf
                self.statusButton.setTitle(self.viewModel.book.status.rawValue, for: .normal)
            },
            UIAction(title: "To Read") { _ in
                self.viewModel.book.status = .toRead
                self.statusButton.setTitle(self.viewModel.book.status.rawValue, for: .normal)
            },
            UIAction(title: "Read") { _ in
                self.viewModel.book.status = .read
                self.statusButton.setTitle(self.viewModel.book.status.rawValue, for: .normal)
            }
        ]
        return UIMenu(children: actions)
    }
    
    override func loadView() {
        let view = UIView()
        self.view = view
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = .white
        
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.spacing = 16
        view.addSubview(contentStack)
        
        let bookImage = UIImageView()
        bookImage.translatesAutoresizingMaskIntoConstraints = false
        bookImage.image = viewModel.book.image
        bookImage.contentMode = .scaleAspectFit
        contentStack.addArrangedSubview(bookImage)
        
        let authorLabel = UILabel()
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.text = viewModel.book.author
        contentStack.addArrangedSubview(authorLabel)
        
        let pageCountLabel = UILabel()
        pageCountLabel.translatesAutoresizingMaskIntoConstraints = false
        pageCountLabel.text = "Pages: \(viewModel.book.pageCount)"
        contentStack.addArrangedSubview(pageCountLabel)
        
        let isbnLabel = UILabel()
        isbnLabel.translatesAutoresizingMaskIntoConstraints = false
        isbnLabel.text = "ISBN: \(viewModel.book.isbn)"
        contentStack.addArrangedSubview(isbnLabel)
        
        isOwnedButton.translatesAutoresizingMaskIntoConstraints = false
        isOwnedButton.setTitle(viewModel.book.owned ? "Owned" : "Want", for: .normal)
        isOwnedButton.menu = setupOwnedMenu()
        isOwnedButton.showsMenuAsPrimaryAction = true
        contentStack.addArrangedSubview(isOwnedButton)
        
        statusButton.translatesAutoresizingMaskIntoConstraints = false
        statusButton.setTitle(viewModel.book.status.rawValue, for: .normal)
        statusButton.menu = setupStatusMenu()
        statusButton.showsMenuAsPrimaryAction = true
        contentStack.addArrangedSubview(statusButton)
        
        
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
