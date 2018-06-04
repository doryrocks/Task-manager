//
//  TaskDetailView.swift
//  Task manager
//
//  Created by Dorota Piačeková on 21.05.18.
//  Copyright © 2018 Dorota Piačeková. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework
import CoreData

class TaskDetailView: UIScrollView {
    // MARK: - Variables
    // MARK: public
    
    var content: Task? {
        didSet {
            if let content = content {
                setupContent(content)
            } else {
                setupEmptyContent()
            }
        }
    }
    
    // MARK: private
    private lazy var loadingView: UIActivityIndicatorView = self.makeLoadingView()
    private lazy var stackView: UIStackView = UIStackView()
    private lazy var stateLabel: UILabel = self.makeStateLabel()
    private lazy var subjectLabel: UILabel = self.makeSubjectLabel()
    private lazy var deadlineLabel: UILabel = self.makeDeadlineLabel()
    private lazy var notificationLabel: UILabel = self.makeNotificationLabel()
    private lazy var editButton: UIButton = self.makeEditButton()
    private lazy var solveButton: UIButton = self.makeSolveButton()
    private lazy var deleteButton: UIButton = self.makeDeleteButton()
    private lazy var categoryView: UIView = UIView()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        context = appDelegate.persistentContainer.viewContext
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Content
    // MARK: private
    func setupEmptyContent() {
        subviews.forEach {
            $0.removeFromSuperview()
        }
        addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        loadingView.startAnimating()
    }
    
    func setupContent(_ content: Task) {
        loadingView.stopAnimating()
        loadingView.removeFromSuperview()
        
        if stackView.superview == nil {
            let taskStackView = UIStackView()
            taskStackView.alignment = .center
            taskStackView.axis = .horizontal
            taskStackView.spacing = 10
            if content.categoryColor != nil && content.categoryTitle != nil {
                categoryView = self.makeCategoryTag(title: (self.content?.categoryTitle)!, color: UIColor(hex: (self.content?.categoryColor)!)!)
            }
           
            [solveButton, editButton, deleteButton].forEach {
                taskStackView.addArrangedSubview($0)
                
            }
            
            addSubview(stackView)
            stackView.alignment = .center
            stackView.axis = .vertical
            stackView.spacing = 20
            
            [subjectLabel, categoryView, stateLabel, notificationLabel, deadlineLabel, taskStackView].forEach {
                stackView.addArrangedSubview($0)
            }
            stackView.setCustomSpacing(90, after: deadlineLabel)
            
            setupConstratins()
        }
        updateContent(content)
    }
    
    private func setupConstratins() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 80).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        

    }
    
    public func updateContent(_ content: Task) {
        subjectLabel.text = content.subject
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        deadlineLabel.text = "Deadline: " + formatter.string(from: content.deadline!)
        if content.notification == true {
            notificationLabel.text = "Notification: Yes"
        } else {
            notificationLabel.text = "Notification: No"
        }
        if content.solved == true {
            stateLabel.text = "State: Done"
        } else {
            stateLabel.text = "State: To-do"
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: Views builders
    private func makeLoadingView() -> UIActivityIndicatorView {
        let rVal = UIActivityIndicatorView()
        rVal.activityIndicatorViewStyle = .gray
        return rVal
    }
    
    private func makeDeadlineLabel() -> UILabel {
        let rVal = UILabel()
        rVal.textColor = .flatBlack()
        rVal.font = .systemFont(ofSize: 18)
        return rVal
    }
    
    private func makeStateLabel() -> UILabel {
        let rVal = UILabel()
        rVal.textColor = .flatBlack()
        rVal.font = .systemFont(ofSize: 18)
        return rVal
    }
    
    private func makeNotificationLabel() -> UILabel {
        let rVal = UILabel()
        rVal.textColor = .flatBlack()
        rVal.font = .systemFont(ofSize: 18)
        return rVal
    }
    
    private func makeSubjectLabel() -> UILabel {
        let rVal = UILabel()
        rVal.textColor = .flatMint()
        rVal.font = UIFont.boldSystemFont(ofSize: 24)
        return rVal
    }
    
    private func makeSolveButton() -> UIButton {
        let rVal = UIButton()
        rVal.setTitle("Solve", for: .normal)
        rVal.backgroundColor = .flatGreen()
        rVal.setTitleColor(.black, for: .normal)
        rVal.setTitleColor(UIColor.black.withAlphaComponent(0.6), for: .highlighted)
        rVal.titleLabel?.font = .systemFont(ofSize: 18)
        rVal.layer.cornerRadius = 6
        rVal.layer.borderColor = UIColor.flatBlack().cgColor
        rVal.layer.borderWidth = 1.5
        rVal.centerVertically()
        rVal.clipsToBounds = true
        rVal.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        rVal.addTarget(self, action: #selector(TaskDetailView.solveButtonTapped), for: .touchUpInside)
        return rVal
    }
    
    private func makeCategoryTag(title: String, color: UIColor) -> UIButton {
        let rVal = UIButton()
        rVal.setTitle(title, for: .normal)
        rVal.backgroundColor = color
        rVal.setTitleColor(.black, for: .normal)
        rVal.titleLabel?.font = .systemFont(ofSize: 14)
        rVal.layer.cornerRadius = 6
        rVal.centerVertically()
        rVal.clipsToBounds = true
        rVal.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        return rVal
    }
    
    private func makeEditButton() -> UIButton {
        let rVal = UIButton()
        rVal.setTitle("Edit", for: .normal)
        rVal.backgroundColor = .flatOrange()
        rVal.setTitleColor(.black, for: .normal)
        rVal.setTitleColor(UIColor.black.withAlphaComponent(0.6), for: .highlighted)
        rVal.titleLabel?.font = .systemFont(ofSize: 18)
        rVal.layer.cornerRadius = 6
        rVal.layer.borderColor = UIColor.flatBlack().cgColor
        rVal.layer.borderWidth = 1.5
        rVal.centerVertically()
        rVal.clipsToBounds = true
        rVal.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        rVal.addTarget(self, action: #selector(TaskDetailView.editButtonTapped), for: .touchUpInside)
        return rVal
    }
    
    private func makeDeleteButton() -> UIButton {
        let rVal = UIButton()
        rVal.setTitle("Delete", for: .normal)
        rVal.backgroundColor = .flatRed()
        rVal.setTitleColor(.black, for: .normal)
        rVal.setTitleColor(UIColor.black.withAlphaComponent(0.6), for: .highlighted)
        rVal.titleLabel?.font = .systemFont(ofSize: 18)
        rVal.layer.borderColor = UIColor.flatBlack().cgColor
        rVal.layer.borderWidth = 1.5
        rVal.layer.cornerRadius = 6
        rVal.centerVertically()
        rVal.clipsToBounds = true
        rVal.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        rVal.addTarget(self, action: #selector(TaskDetailView.deleteButtonTapped), for: .touchUpInside)

        return rVal
    }
    
    private func makeTagView() -> UIView {
        let rVal = UIView()
        return rVal
        
    }
    
    @objc func editButtonTapped() {
        if content?.categoryTitle == nil {
            content?.categoryTitle = ""
        } else if content?.categoryColor == nil {
            content?.categoryColor = ""
        }
        let vc = NewTaskViewController(subject: (content?.subject)!, deadline: (content?.deadline)!, notification: (content?.notification)!, categoryTitle: (content?.categoryTitle)!, categoryColor: (content?.categoryColor)!, edit: true)
        (superview?.next as? UIViewController)?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func deleteButtonTapped() {
        let objectToDelete = self.content
        self.context.delete(objectToDelete!)
        
        do {
            try self.context.save()
        }
        catch let error{
            print("Could not save Deletion \(error)")
        }
        (superview?.next as? UIViewController)?.navigationController?.popViewController(animated: true)
    }
    
    @objc func solveButtonTapped() {
        let vc = TasksListViewController()
        
        if content?.solved == false {
        let predicate = NSPredicate(format: "subject == %@", (content?.subject)!)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = predicate
        
        do {
            let fetchedTasks = try self.context.fetch(fetchRequest) as! [Task]
            fetchedTasks[0].solved = true
        } catch {
            print("Couldn't fetch tasks")
        }
        
        do {
            try self.context.save()
        } catch {
            print("Couldn't save tasks")
        }
            vc.loadTasks { (tasks) in
                for task in tasks! {
                    if task.subject == self.content?.subject {
                        self.content = task
                        self.setupContent(task)
                    }
                }
            }
        }
        }
    }

    


