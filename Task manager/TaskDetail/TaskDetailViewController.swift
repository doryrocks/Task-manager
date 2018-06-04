//
//  TaskDetailViewController.swift
//  Task manager
//
//  Created by Dorota Piačeková on 21.05.18.
//  Copyright © 2018 Dorota Piačeková. All rights reserved.
//

import Foundation
import UIKit

import UIKit

class TaskDetailViewController: UIViewController {
    let taskView = TaskDetailView()
    let taskList = TasksListViewController()
    
    init(for subject: String) {
        super.init(nibName: nil, bundle: nil)
        taskList.loadTasks { (tasks) in
            if let tasks = tasks {
                for task in tasks {
                    if task.subject == subject {
                        self.taskView.content = task
                    }
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = .flatBlack()
        let titleLabel = UILabel(frame: CGRect())
        titleLabel.textColor = .flatBlack()
        titleLabel.text = taskView.content?.subject
        self.navigationItem.titleView = titleLabel
        taskList.loadTasks { (tasks) in
            if let tasks = tasks {
                for task in tasks {
                    if task.subject == titleLabel.text {
                        self.taskView.content = task
                        self.taskView.setNeedsLayout()
                    }
                }
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        view.addSubview(taskView)
        taskView.frame = view.bounds
        taskView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = .white
        
    }
}
