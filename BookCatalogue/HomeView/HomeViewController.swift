//
//  HomeViewController.swift
//  BookCatalogue
//
//  Created by Brett Gordon on 3/2/26.
//

import UIKit
import VisionKit

class HomeViewController: UIViewController {
    
    private let dataScannerViewController = DataScannerViewController(recognizedDataTypes: [.barcode()],
                                                                      qualityLevel: .balanced,
                                                                      recognizesMultipleItems: false,
                                                                      isHighFrameRateTrackingEnabled: true,
                                                                      isPinchToZoomEnabled: true,
                                                                      isGuidanceEnabled: true,
                                                                      isHighlightingEnabled: true)
    
    private var scannerAvailable: Bool { DataScannerViewController.isSupported && DataScannerViewController.isAvailable }
    private var viewModel = HomeViewModel()

    var collectionButton = UIButton(type: .system)
    var scanButton = UIButton(type: .system)
    
    var lookupISBN: String?
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewModel.delegate = self
        dataScannerViewController.delegate = self
        collectionButton.addTarget(self, action: #selector(collectionButtonTapped), for: .touchUpInside)
        scanButton.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
    }
    
    @objc func collectionButtonTapped() {
        
    }
    
    @objc func scanButtonTapped() {
        present(dataScannerViewController, animated: true)
        try? dataScannerViewController.startScanning()
    }
    
    override func loadView() {
        let view = UIView()
        self.view = view
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        
        var collectionButtonConfiguration = UIButton.Configuration.filled()
        collectionButtonConfiguration.title = "View Collection"
        collectionButtonConfiguration.cornerStyle = .capsule
        collectionButtonConfiguration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        
        var scanButtonConfiguration = UIButton.Configuration.filled()
        scanButtonConfiguration.title = "Scan Barcode"
        scanButtonConfiguration.cornerStyle = .capsule
        scanButtonConfiguration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

        
        collectionButton.translatesAutoresizingMaskIntoConstraints = false
        collectionButton.configuration = collectionButtonConfiguration
        
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        scanButton.configuration = scanButtonConfiguration
        
        let buttonStack = UIStackView(arrangedSubviews: [collectionButton, scanButton])
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .vertical
        buttonStack.spacing = 16
        
        view.addSubview(buttonStack)
        
        NSLayoutConstraint.activate([
            buttonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            
        ])
    }


}

extension HomeViewController: DataScannerViewControllerDelegate {
    func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
        // handle here the sudden camera scanner unavaliability. Ex: camera permission revoked.
        print("The scanner became unavailable. Sorry.")
    }
    
    func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
        for item in addedItems {
            switch item {
            case .barcode(let barcode):
                if let barcodeString = barcode.payloadStringValue {
                    self.lookupISBN = barcodeString
                    process(data: barcodeString)
                }
            case .text(_):
                break
            @unknown default:
                print("Should not happen")
            }
        }
    }
    
    private func process(data: String) {
        
        dismiss(animated: true)
        self.viewModel.lookupBook(isbn: data) { book, networkError in
            DispatchQueue.main.async {
                self.finishedLookingUpBook(book: book, error: networkError)
            }
        }
    }
}

extension HomeViewController: HomeViewModelDelegate {
    func finishedLookingUpBook(book: GetISBNResponse?, error: Error?) {
        if let book {
            let alertViewController = UIAlertController(title: nil, message: "Is your book \(book.title)?", preferredStyle: .alert)
            let positiveAction = UIAlertAction(title: "Yes", style: .default) { _ in
                /// completion handler to add to memory later
            }
            let negativeAction = UIAlertAction(title: "No", style: .destructive)
            alertViewController.addAction(positiveAction)
            alertViewController.addAction(negativeAction)
            self.present(alertViewController, animated: true)
        }
        if let error {
            let alertViewContoller = UIAlertController(title: "Book not found", message: "We could not find your book", preferredStyle: .alert)
            alertViewContoller.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertViewContoller, animated: true)
        }
    }
}

