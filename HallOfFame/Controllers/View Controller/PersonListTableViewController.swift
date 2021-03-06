//
//  PersonListTableViewController.swift
//  HallOfFame
//
//  Created by theevo on 3/11/20.
//  Copyright © 2020 theevo. All rights reserved.
//

import UIKit

class PersonListTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var page = 0
    var isFinalPage = false
    
    // MARK: - Lifecycle Methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchPeople()
        
    }
    
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PersonController.shared.people.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "personCell", for: indexPath)
        
        let person = PersonController.shared.people[indexPath.row]
        
        cell.textLabel?.text = "\(person.firstName) \(person.lastName)"
        cell.detailTextLabel?.text = "\(person.cohort)"
        
        if indexPath.row == PersonController.shared.people.count - 1 {
            fetchPeople()
        }
        
        return cell
    }
    
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = PersonController.shared.people[indexPath.row]
        
        PersonController.shared.getPerson(person: person) { (result) in
            DispatchQueue.main.async {
                switch result {
                    
                case .success(let person):
                    //IIDOO
                    
                    // Destination
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    guard let destinationVC = storyboard.instantiateViewController(identifier: "personDetailViewController") as? PersonDetailViewController else { return }
                    
                    
                    // Object - Sent
                    destinationVC.person = person
                    
                    // Present to user
                    self.navigationController?.pushViewController(destinationVC, animated: true)
                    
                case .failure(let error):
                    self.presentErrorToUser(localizedError: error)
                }
            }
        }    }
    
    
    // MARK: - Helper Methods
    
    func fetchPeople() {
        
        guard !isFinalPage else { return }
        
        PersonController.shared.getPeople(page: page) { (result) in
            DispatchQueue.main.async {
                switch result {
                    
                case .success(let people):
                    self.tableView.reloadData()
                    if people.count < 50 {
                        self.isFinalPage = true
                    } else {
                        self.page += 1
                    }
                    
                case .failure(let error):
                    self.presentErrorToUser(localizedError: error)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func createPersonButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Add Person", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "First name"
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Last name"
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Cohort"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (_) in
            guard let firstName = alert.textFields?.first?.text,
                !firstName.isEmpty,
                let lastName = alert.textFields?[1].text,
                !lastName.isEmpty,
                let cohort = alert.textFields?.last?.text,
                !cohort.isEmpty else { return }
            
            PersonController.shared.postPerson(firstName: firstName, lastName: lastName, cohort: cohort) { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        self.tableView.reloadData()
                    case .failure(let error):
                        self.presentErrorToUser(localizedError: error)
                    }
                }
            }
        }
        
        alert.addAction(saveAction)
        
        present(alert, animated: true)
    }
    
    
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    
    
}
