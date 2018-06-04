//
//  SettingsViewController.swift
//  Task manager
//
//  Created by Dorota Piačeková on 21.05.18.
//  Copyright © 2018 Dorota Piačeková. All rights reserved.
//

import Foundation
import UIKit
import Eureka
import CoreData
import UserNotifications

class SettingsViewController: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = .flatBlack()
        
         form +++ Section("Notifications")
            <<< SwitchRow(){
                $0.title = "Notifications"
                $0.value = true
            }
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Save"
                }.onCellSelection { [weak self] (cell, row) in
                    let notificationsRow: SwitchRow? = self?.form.rowBy(tag: "Notifications")

                    let notifications = notificationsRow?.value
                    
                    if notifications == false {
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    }
                    
        }
        }
    }


