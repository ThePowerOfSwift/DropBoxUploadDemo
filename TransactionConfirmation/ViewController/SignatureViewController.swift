//
//  SingatureViewController.swift
//  TransactionConfirmation
//
//  Created by Karunanithi Veerappan on 9/1/19.
//  Copyright © 2019 Karunanithi. All rights reserved.
//

import UIKit

class SignatureViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var signatureView: SignatureView!
    weak var delegate: SignatureVCDelegate?
    
    var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animate(withDuration: 0.3) {
            self.backgroundView.removeFromSuperview()
        }
    }
    override func viewWillLayoutSubviews() {
        contentView.roundCorners([.topLeft, .topRight], radius: 10)
        self.presentingViewController?.view.addSubview(backgroundView)
        backgroundView.frame = self.presentingViewController?.view.bounds ?? .zero
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func doneButtonAction(_ sender: Any) {
        let signatureImage = signatureView.getSignature(scale: 10)
        dismiss(animated: true) {
            self.delegate?.signatureImageRecieved(signatureImage)
        }
    }
    @IBAction func resetButtonAction(_ sender: Any) {
        signatureView.clear()
    }
    
}
