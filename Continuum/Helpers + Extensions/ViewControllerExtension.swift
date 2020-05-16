//
//  ViewControllerExtension.swift
//  Continuum
//
//  Created by Jimmy on 5/14/20.
//  Copyright © 2020 trevorAdcock. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentSimpleAlertWith(title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okayAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
}
