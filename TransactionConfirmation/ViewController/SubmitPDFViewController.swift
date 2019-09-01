//
//  SubmitPDFViewController.swift
//  TransactionConfirmation
//
//  Created by Karunanithi Veerappan on 9/1/19.
//  Copyright © 2019 Karunanithi. All rights reserved.
//

import UIKit
import PDFKit
import SwiftyDropbox

class SubmitPDFViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var pdfView: PDFView!
    var pdfUrl = ""
    let spinner = SpinnerViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Preview Your Application"
        let url = URL(fileURLWithPath: pdfUrl)
        if let pdfDocument = PDFDocument(url: url) {
            pdfView.displayMode = .singlePageContinuous
            pdfView.autoScales = true
            pdfView.document = pdfDocument
        }
        observeAuthentication()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    func observeAuthentication() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dropBoxAuthenticationResponse(notification:)),
                                               name: .dropBoxResponse,
                                               object: nil)
    }
    @objc func dropBoxAuthenticationResponse(notification: NSNotification) {
        if let response = notification.userInfo?["response"] as? DropBoxResponse {
            switch response {
            case .success:
                uploadPdfToDropBox()
            case .error:
                Utility.showAlert(self, "Error", "Something went wrong")
                print("error")
            case .cancelled:
                Utility.showAlert(self, "Error", "You cancelled the process")
                print("cancelled")
            }
        }
    }
    func uploadPdfToDropBox() {
        createSpinnerView()
        let client = DropboxClientsManager.authorizedClient
        let url = URL(fileURLWithPath: pdfUrl)
        let name = "ReportTransaction-" + Utility.randomString(length: 6) + ".pdf"
        client?.files.upload(path: "/ReportTransaction/\(name)", input: url)
            .response { response, error in
                self.removeSpinner()
                if let _ = response {
                    Utility.showAlert(self, "Success", "Your form submitted successfully")
                } else if let error = error {
                    Utility.showAlert(self, "Error", error.description)
                }
        }
    }
    func createSpinnerView() {
        addChild(spinner)
        spinner.view.frame = view.frame
        view.addSubview(spinner.view)
        spinner.didMove(toParent: self)
    }
    func removeSpinner() {
        DispatchQueue.main.async {
            self.spinner.willMove(toParent: nil)
            self.spinner.view.removeFromSuperview()
            self.spinner.removeFromParent()
        }
    }

    @IBAction func submitButtonAction(_ sender: Any) {
        DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                      controller: self,
                                                      openURL: { (url: URL) -> Void in
                                                        UIApplication.shared.open(url,
                                                                                  options: [:],
                                                                                  completionHandler: nil)
        })
    }
}
