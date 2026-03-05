//
//  ViewController.swift
//  BookCatalogue
//
//  Created by Brett Gordon on 3/2/26.
//

import UIKit
import VisionKit

class ViewController: UIViewController {
    
    private let dataScannerViewController = DataScannerViewController(recognizedDataTypes: [.barcode()],
                                                                      qualityLevel: .balanced,
                                                                      recognizesMultipleItems: false,
                                                                      isHighFrameRateTrackingEnabled: true,
                                                                      isPinchToZoomEnabled: true,
                                                                      isGuidanceEnabled: true,
                                                                      isHighlightingEnabled: true)
    
    private var scannerAvailable: Bool { DataScannerViewController.isSupported && DataScannerViewController.isAvailable }


    var collectionButton = UIButton()
    var scanButton = UIButton()
    
    var lookupISBN: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dataScannerViewController.delegate = self
        collectionButton.addTarget(self, action: #selector(collectionButtonTapped), for: .touchUpInside)
        scanButton.addTarget(self, action: #selector(scanButtonTapped), for: .touchUpInside)
    }
    
    @objc func collectionButtonTapped() {
        print("Collection Button Tapped")
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
        
        collectionButton.translatesAutoresizingMaskIntoConstraints = false
        collectionButton.setTitle("View Collection", for: .normal)
        collectionButton.backgroundColor = .systemBlue
        collectionButton.setTitleColor(.white, for: .normal)
//        collectionButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        collectionButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        collectionButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
//        collectionButton.corner
        
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        scanButton.setTitle("Scan Barcode", for: .normal)
        scanButton.configuration?.cornerStyle = .medium
        scanButton.backgroundColor = .systemBlue
        scanButton.setTitleColor(.white, for: .normal)
        
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

extension ViewController: DataScannerViewControllerDelegate {
    func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
        // handle here the sudden camera scanner unavaliability. Ex: camera permission revoked.
        print("The scanner became unavailable. Sorry.")
    }
    
    func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
        for item in addedItems {
            switch item {
            case .barcode(let barcode):
                print("Barcode Observation - \(barcode.observation)")
                print("Barcode String Value - \(barcode.payloadStringValue)")
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
        let alertViewController = UIAlertController(title: nil, message: "Your ISBN is \(data)", preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alertViewController, animated: true)
    }
}

