//
//  NewTaskViewController.swift
//  Task manager
//
//  Created by Dorota Piačeková on 21.05.18.
//  Copyright © 2018 Dorota Piačeková. All rights reserved.
//
import UIKit
import Eureka
import CoreData
import ColorPickerRow
import UserNotifications

class NewTaskViewController: FormViewController {
    var subjectDef: String
    var deadlineDef: Date
    var notificationDef: Bool
    var categoryTitleDef: String
    var categoryColorDef: String
    var edit: Bool
    
    
    init(subject: String, deadline: Date, notification: Bool, categoryTitle: String, categoryColor: String, edit: Bool) {

        self.subjectDef = subject
        self.deadlineDef = deadline
        self.notificationDef = notification
        self.categoryTitleDef = categoryTitle
        self.categoryColorDef = categoryColor
        self.edit = edit
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = .flatBlack()
        animateScroll = true
        setupForm()

    }
    
    func setupForm() {
        form +++ Section("Task info")
            
            <<< TextRow("Subject") {
                $0.title = "Subject"
                $0.validationOptions = .validatesAlways
                $0.value = subjectDef
                let ruleRequired = RuleClosure<String> { rowValue in
                    return (rowValue == nil || rowValue!.isEmpty || rowValue == "") ? ValidationError(msg: "Field required!") : nil
                }
                $0.add(rule: ruleRequired)
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            <<< DateTimeInlineRow("Deadline") {
                $0.title = $0.tag
                $0.value = deadlineDef
                $0.value = Date().addingTimeInterval(60*60*24)
            }
            <<< SwitchRow("Notification") {
                $0.title = $0.tag
                $0.value = notificationDef
            }
            +++ Section("Task category")
            
            <<< TextRow("Category title") {
                $0.title = $0.tag
                $0.value = categoryTitleDef
                $0.placeholder = "Enter text here"
            }
            <<< ColorPickerRow("Category color") { (row) in
                row.title = "Color Picker"
                row.isCircular = true
                row.showsCurrentSwatch = false
                row.showsPaletteNames = true
                row.value = UIColor(hex: categoryColorDef)
                }
                .cellSetup { (cell, row) in
                    let palette = ColorPalette(name: "All",
                                               palette: [ColorSpec(hex: "#C6DA02", name: "Lime"),
                                                         ColorSpec(hex: "#79A700", name: "Green"),
                                                         ColorSpec(hex: "#F68B2C", name: "Orange"),
                                                         ColorSpec(hex: "#E2B400", name: "Brown"),
                                                         ColorSpec(hex: "#F5522D", name: "Red"),
                                                         ColorSpec(hex: "#FF6E83", name: "Pink"),])
                    cell.palettes = [palette]
            }
            
            +++ Section()
            <<< ButtonRow("Button") { (row: ButtonRow) -> Void in
                row.title = "Save"
                let subjectRow: TextRow? = self.form.rowBy(tag: "Subject")
                if subjectRow?.isValid == true {
                    row.disabled = false
                }
                else { row.disabled = true }
                row.evaluateDisabled()
                row.validate()
                row.reload(with: .automatic)
                }.onCellSelection { [weak self] (cell, row) in
                
                    let subjectRow: TextRow? = self?.form.rowBy(tag: "Subject")
                    let subject = subjectRow?.value
                    if subject == nil || subject == "" {
                        let alertController = UIAlertController(title: "Failure", message: "Subject is required!", preferredStyle: .alert)
                        let alert = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(alert)
                        self?.present(alertController, animated: true, completion: nil)
                    
                    } else {
                    let deadlineRow: DateTimeInlineRow = (self?.form.rowBy(tag: "Deadline"))!
                    let notificationRow: SwitchRow? = self?.form.rowBy(tag: "Notification")
                    let categoryTitleRow: TextRow? = self?.form.rowBy(tag: "Category title")
                    let categoryColorRow: ColorPickerRow = (self?.form.rowBy(tag: "Category color"))!
                    

                    let deadline = deadlineRow.value
                    let notification = notificationRow?.value
                    let categoryTitle = categoryTitleRow?.value
                    let categoryColor = categoryColorRow.value?.hexValue()
                
                    var message = ""
                    
                    if notification == true {
                        if let deadline = deadline, let subject = subject {
                            self?.scheduleNotification(date: deadline, subject: subject)
                        }
                    }
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                    let context = appDelegate.persistentContainer.viewContext
                    
                    if self?.edit == false {
                        message = "Task successfully created!"
                        
                        let taskEntity = NSEntityDescription.entity(forEntityName: "Task", in: context)!
                        let task = NSManagedObject(entity: taskEntity, insertInto: context)
                        
                        task.setValue(subject, forKey: "subject")
                        task.setValue(deadline, forKey: "deadline")
                        task.setValue(notification, forKey: "notification")
                        task.setValue(categoryTitle, forKey: "categoryTitle")
                        task.setValue(categoryColor, forKey: "categoryColor")
                        task.setValue(false, forKey: "solved")
                    
                        do {
                            try context.save()
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                    }
                    
                    else {
                        message = "Task successfully edited!"
                        let predicate = NSPredicate(format: "subject == %@", (self?.subjectDef)!)
                        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
                        fetchRequest.predicate = predicate
                        
                        do {
                            let fetchedTasks = try context.fetch(fetchRequest) as! [Task]
                            fetchedTasks[0].subject = subject
                            fetchedTasks[0].deadline = deadline
                            fetchedTasks[0].notification = notification!
                            fetchedTasks[0].categoryColor = categoryColor
                            fetchedTasks[0].categoryTitle = categoryTitle
                            
                        } catch {
                            print("Couldn't fetch tasks")
                        }
                        
                        do {
                            try context.save()
                        } catch {
                            print("Couldn't save tasks")
                        }
                        let detailView = TaskDetailView()
                        detailView.layoutSubviews()
                    }
                    
                    let alertController = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
                    let alert = UIAlertAction(title: "OK", style: .default, handler: { (alert: UIAlertAction!) in
                        self?.navigationController?.popViewController(animated: true)
                    })
                    alertController.addAction(alert)
                    self?.present(alertController, animated: true, completion: nil)
                    }
        }
    }
    func scheduleNotification(date: Date, subject: String) {
        
        let content = UNMutableNotificationContent()
        content.title = "Task deadline"
        content.subtitle = subject
        content.body = "Don't forget to solve it ;)"
        content.badge = 1
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let identifier = "notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

