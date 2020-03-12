//
//  PersonDetailViewController.swift
//  HallOfFame
//
//  Created by theevo on 3/11/20.
//  Copyright © 2020 theevo. All rights reserved.
//

import UIKit

class PersonDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var cohortLabel: UILabel!
    @IBOutlet weak var interestsTableView: UITableView!
    
    
    // MARK: - Properties
    
    var person: Person?
    
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViews()
        
        interestsTableView.delegate = self
        interestsTableView.dataSource = self
        
    }
    
    
    // MARK: - Helper Methods
    
    func updateViews() {
        guard let person = person else { return }
        personNameLabel.text = "\(person.firstName) \(person.lastName)"
        cohortLabel.text = person.cohort
        
    }
    
    // MARK: - Actions
    
    // Add Interest
    
    @IBAction func newInterestTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Add Interest", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Basketball"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        let saveAsLikeAction = UIAlertAction(title: "Save as Like", style: .default) { (_) in
            guard let interest = alert.textFields?.first?.text,
                !interest.isEmpty,
                let person = self.person
                else { return }
            
            PersonController.shared.postLike( interestText: interest, person: person ) { (result) in
                DispatchQueue.main.async {
                    switch result {
                        
                    case .success(_):
                        self.person?.likes?.append(Like(text: interest))
                        self.interestsTableView.reloadData()
                        
                    case .failure(let error):
                        self.presentErrorToUser(localizedError: error)
                    } // end switch
                } // end dispatchqueue
            } // end postLike
        } // end saveAsLikeAction
        
        alert.addAction(saveAsLikeAction)
        
        let saveAsDisikeAction = UIAlertAction(title: "Save as Dislike", style: .default) { (_) in
            guard let interest = alert.textFields?.first?.text,
                !interest.isEmpty,
                let person = self.person
                else { return }
            
            PersonController.shared.postDislike( interestText: interest, person: person ) { (result) in
                DispatchQueue.main.async {
                    switch result {
                        
                    case .success(_):
                        self.person?.dislikes?.append(Dislike(text: interest))
                        self.interestsTableView.reloadData()
                        
                    case .failure(let error):
                        self.presentErrorToUser(localizedError: error)
                    } // end switch
                } // end dispatchqueue
            } // end postLike
        } // end saveAsDisikeAction
        
        alert.addAction(saveAsDisikeAction)
        
        present(alert, animated: true)
    } // end newInterestTapped
    
    // Delete Person
    @IBAction func deletePersonButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure?", message: "This action cannot be undone.", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Confirm", style: .destructive) { (_) in
            guard let person = self.person else { return }
            PersonController.shared.delete(person: person) { (result) in
                DispatchQueue.main.async {
                    
                    switch result{
                    case .success(_):
                        self.navigationController?.popViewController(animated: true)
                    case .failure(let error):
                        self.presentErrorToUser(localizedError: error)
                    }
                }
            }
        }
        alert.addAction(deleteAction)
        present(alert, animated: true)
    }
    
    
    
    
} // end class

extension PersonDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Likes" : "Dislikes"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ?
            person?.likes?.count ?? 0 :
            person?.dislikes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "interestCell", for: indexPath)
        
        let interestText = indexPath.section == 0 ?
            person?.likes?[indexPath.row].text :
            person?.dislikes?[indexPath.row].text
        
        cell.textLabel?.text = interestText
        
        return cell
    }
    
    
}
