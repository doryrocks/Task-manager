//
//  TaskListViewController.swift
//  Task manager
//
//  Created by Dorota Piačeková on 13.05.18.
//  Copyright © 2018 Dorota Piačeková. All rights reserved.
//

import UIKit
import ChameleonFramework
import CoreData

class TasksListViewController: UIViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    let tableView: UITableView = UITableView(frame: .zero, style: .grouped)
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext?
    let headers = ["To-do", "Done"]
    var tasks: [[Task]] = [[]]
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        context = appDelegate.persistentContainer.viewContext
        navigationController?.setNavigationBarHidden(false, animated: true)
        let titleLabel = UILabel(frame: .zero)
        titleLabel.text = "Your tasks"
        titleLabel.textColor = .black
        self.navigationItem.titleView = titleLabel
        self.navigationController?.navigationBar.barTintColor = UIColor.flatMint()
        self.view.backgroundColor = .white
        let new = UIBarButtonItem(image: #imageLiteral(resourceName: "navbar_ic_add"), style: .done, target: self, action: #selector(newTaskButtonTapped))
        new.tintColor = .flatBlack()
        let settings = UIBarButtonItem(image: #imageLiteral(resourceName: "navbar_ic_settings"), style: .plain, target: self, action: #selector(settingsButtonTapped))
        settings.tintColor = .flatBlack()
        navigationItem.rightBarButtonItems = [settings, new]
        tableView.indexPathsForSelectedRows?.forEach {
            tableView.deselectRow(at: $0, animated: true)
        }
        
        loadTasks { (tasks) in
            guard let tasks = tasks else {
                let alertController = UIAlertController(title: "Loading failed", message: "Couldn't load tasks :(", preferredStyle: .alert)
                let alert = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(alert)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            self.tasks = self.sortTasks(tasks)
            self.tableView.reloadData()
            self.loadView()
        }
    }
    
    override func loadView() {
        super.loadView()
            view.addSubview(tableView)
            tableView.frame = view.bounds
            tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            tableView.separatorColor = .flatMint()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        if let context = context {
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: context)
                self.loadView()
        }
        
    }
    
    @objc func newTaskButtonTapped(sender: AnyObject) {
        let new = NewTaskViewController(subject: "", deadline: Date(), notification: false, categoryTitle: "", categoryColor: "", edit: false)
        self.navigationController?.pushViewController(new, animated: true)
    }
    
    @objc func settingsButtonTapped() {
        let settings = SettingsViewController()
        self.navigationController?.pushViewController(settings, animated: true)
    }
}


// MARK: Delegate & datarousce

extension TasksListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headers[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = tasks[indexPath.section][indexPath.row].subject
        cell?.textLabel?.textColor = .flatBlack()
        
        if tasks[indexPath.section][indexPath.row].categoryTitle != nil && tasks[indexPath.section][indexPath.row].categoryColor != nil {
            cell?.accessoryView = makeCategoryTag(title: tasks[indexPath.section][indexPath.row].categoryTitle!, color: UIColor(hex: tasks[indexPath.section][indexPath.row].categoryColor!)!)
        } else {
            cell?.accessoryView = nil
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        cell?.detailTextLabel?.text = formatter.string(from: tasks[indexPath.section][indexPath.row].deadline!)
        cell?.detailTextLabel?.textColor = .flatGray()
        return cell!
    }
    
     func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
            let deleteTitle = NSLocalizedString("Delete", comment: "Delete action")
            let deleteAction = UITableViewRowAction(style: .destructive, title: deleteTitle) { (action, indexPath) in
                let objectToDelete = self.tasks[indexPath.section][indexPath.row]
                self.tasks[indexPath.section].remove(at: indexPath.row)
                self.context?.delete(objectToDelete)
                
                do {
                    try self.context?.save()
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
                catch let error{
                    print("Could not save Deletion \(error)")
                }
            }
        if indexPath.section == 0 {
            let solveTitle = NSLocalizedString("Solve", comment: "Solve action")
            let solveAction = UITableViewRowAction(style: .normal, title: solveTitle) { (action, indexPath) in
                
                let subject = self.tasks[indexPath.section][indexPath.row].subject
                let predicate = NSPredicate(format: "subject == %@", subject!)
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
                fetchRequest.predicate = predicate
                
                do {
                    let fetchedTasks = try self.context?.fetch(fetchRequest) as! [Task]
                        fetchedTasks[0].solved = true
                } catch {
                    print("Couldn't fetch tasks")
                }
                
                do {
                    try self.context?.save()
                } catch {
                    print("Couldn't save tasks")
                }
                self.loadTasks(completion: { (tasks) in
                    self.tasks = self.sortTasks(tasks!)
                    tableView.beginUpdates()
                    tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 1))
                    tableView.endUpdates()
                })
            }
            solveAction.backgroundColor = .green
            return [solveAction, deleteAction]
        } else { return [deleteAction] }
    }
}


extension TasksListViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = TaskDetailViewController(for: (tasks[indexPath.section][indexPath.row].subject)!)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    public func loadTasks(completion: @escaping (_ tasks: [Task]?) -> Void) {
        let taskFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        guard let tasks = try? managedContext?.fetch(taskFetch) else {
            completion(nil)
            return
        }
        completion(tasks as? [Task])
    }

    
    @objc func managedObjectContextObjectsDidChange(notification: NSNotification) {
        loadTasks { (tasks) in
            guard let tasks = tasks else {
                let alertController = UIAlertController(title: "Loading failed", message: "Couldn't load tasks :(", preferredStyle: .alert)
                let alert = UIAlertAction(title: "OK", style: .default, handler: { (alert: UIAlertAction!) in
                })
                alertController.addAction(alert)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            self.tasks = self.sortTasks(tasks)
            self.tableView.reloadData()
            self.loadView()
       
    }

   }
    func makeCategoryTag(title: String, color: UIColor) -> UIButton {
        let rVal = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 25))
        rVal.setTitle(title, for: .normal)
        rVal.backgroundColor = color
        rVal.setTitleColor(.black, for: .normal)
        rVal.titleLabel?.font = .systemFont(ofSize: 14)
        rVal.layer.cornerRadius = 6
        rVal.centerVertically()
        rVal.clipsToBounds = true
        rVal.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        return rVal
    }
    
    func sortTasks(_ tasks: [Task]) -> [[Task]] {
        var todo: [Task] = []
        var done: [Task] = []
        for task in tasks {
            if task.solved == true {
                done.append(task)
            } else {
                todo.append(task)
            }
        }
        return [todo, done]
    }
    
}
