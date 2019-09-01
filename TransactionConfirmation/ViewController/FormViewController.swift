//
//  ViewController.swift
//  TransactionConfirmation
//
//  Created by Karunanithi Veerappan on 9/1/19.
//  Copyright © 2019 Karunanithi. All rights reserved.
//

import UIKit

class FormViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var commentBox: UITextView!
    let authentication = BiometricIDAuth()
    @IBOutlet weak var signatureImageView: UIImageView!
    @IBOutlet weak var signatureStackView: UIStackView!
    @IBOutlet weak var disputeButton: UIButton!
    var showDisputeButton = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        let touchBool = authentication.canEvaluatePolicy()
        if touchBool {
            showAuthenticationAlert()
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        disputeButton.isHidden = !showDisputeButton
    }
    func showAuthenticationAlert() {
        let alertView = UIAlertController(title: "Please Authenticate",
                                          message: "To continue the app usage please authenticate yourself",
                                          preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "Authenticate", style: .default, handler: { (_) in
            self.authenticateUser()
        })
        alertView.addAction(retryAction)
        self.present(alertView, animated: true)
    }
    func authenticateUser() {
        authentication.authenticateUser { [weak self] (message) in
            if let message = message {
                let alertView = UIAlertController(title: "Error",
                                                  message: message,
                                                  preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { (_) in
                    self?.authenticateUser()
                })
                alertView.addAction(retryAction)
                self?.present(alertView, animated: true)
            }
        }
    }
    func showSignView() {
        signatureStackView.arrangedSubviews.forEach { (view) in
            if view.tag != 2 {
                view.isHidden = false
            }
        }
    }
    func hideSignView() {
        signatureStackView.arrangedSubviews.forEach { (view) in
            if view.tag != 2 {
                view.isHidden = true
            }
        }
    }
    func showSignatureVC() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let signatureVC = storyBoard.instantiateViewController(withIdentifier: "SingatureViewController") as? SignatureViewController else {
            return
        }
        signatureVC.delegate = self
        showDisputeButton = false
        present(signatureVC, animated: true, completion: nil)
    }
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SubmitPDFViewController {
            showDisputeButton = true
            disputeButton.isHidden = true
            destination.pdfUrl = contentView.exportAsPdfFromView()
            hideSignView()
        }
    }
    // MARK: - Actions
    @IBAction func checkMarkButtonActiobn(_ sender: UIButton) {
        if sender.image(for: .normal) == UIImage(named: "checkBox") {
            sender.setImage(UIImage(named: "checkBoxSelected"), for: .normal)
        } else {
            sender.setImage(UIImage(named: "checkBox"), for: .normal)
        }
    }
    @IBAction func disputeButtonAction(_ sender: UIButton) {
        sender.isHidden = true
        showSignatureVC()
    }
    @IBAction func signatureImageViewAction(_ sender: Any) {
        showSignatureVC()
    }
}

// MARK: - SignatureVCDelegate
extension FormViewController: SignatureVCDelegate {
    func signatureImageRecieved(_ image: UIImage?) {
        showSignView()
        signatureImageView.image = image
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.performSegue(withIdentifier: "SubmitPDFViewController", sender: self)
        }
    }
}
// MARK: - UITextViewDelegate
extension FormViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= 256

    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Type your comments here" {
            textView.text = nil
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        countLabel.text = String(textView.text.count) + "/256"
    }
}
