//
//  UIViewController+Ext.swift
//  MyTodoList
//
//  Created by Sendo Tjiam on 07/04/22.
//

import Foundation
import UIKit

extension UIViewController {
    
    func createDefaultAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Back", style: .default, handler: nil))
        return alert
    }
    
    func createCustomAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        return alert
    }
}
