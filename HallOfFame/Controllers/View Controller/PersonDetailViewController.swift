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
