//
//  CreateGroupVC.swift
//  Rival
//
//  Created by VICTOR CHU on 2018-08-26.
//  Copyright © 2018 Victor Chu. All rights reserved.
//

import UIKit
import Firebase

class CreateGroupVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var emailSearchTextfield: UITextField!
    @IBOutlet weak var groupMemberLabel: UILabel!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var followerArray = [Follower]()
    var chosenUserArray = [String]()
    var chosenUidArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        tableView.delegate = self
        tableView.dataSource = self
        emailSearchTextfield.delegate = self
        emailSearchTextfield.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        doneBtn.isHidden = true
    }
    
    @objc func textFieldDidChange() {
        if emailSearchTextfield.text == "" {
            followerArray = []
            tableView.reloadData()
        } else {
            DataService.instance.searchQueryFollowing(forSearchQuery: emailSearchTextfield.text!) { (returnFollowerArray) in
                self.followerArray = returnFollowerArray
                self.tableView.reloadData()
            }
        }
    }

    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        if titleTextField.text != "" && descriptionTextField.text != "" {
            chosenUidArray.append((Auth.auth().currentUser?.uid)!)
            DataService.instance.createGroup(withTitle: titleTextField.text!, andDescription: descriptionTextField.text!, forUserIds: chosenUidArray) { (groupCreated) in
                if groupCreated {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    print("Group could not be created")
                }
            }
        }
    }
}

extension CreateGroupVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followerArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell") as? GroupCell else { return UITableViewCell() }
        
        let follower = followerArray[indexPath.row]
        
        if chosenUserArray.contains(followerArray[indexPath.row].senderName) {
            cell.configureCell(profileImage: follower.senderProfileUrl, name: follower.senderName, isSelected: true)
        } else {
            cell.configureCell(profileImage: follower.senderProfileUrl, name: follower.senderName, isSelected: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? GroupCell else { return }
        if !chosenUserArray.contains(cell.NameLabel.text!) {
            chosenUserArray.append(cell.NameLabel.text!)
            chosenUidArray.append(followerArray[indexPath.row].senderId)
            groupMemberLabel.text = chosenUserArray.joined(separator: ", ")
            doneBtn.isHidden = false
        } else {
            chosenUserArray = chosenUserArray.filter({ $0 != cell.NameLabel.text! })
            chosenUidArray = chosenUidArray.filter({ $0 != followerArray[indexPath.row].senderId})
            if chosenUserArray.count >= 1 {
                groupMemberLabel.text = chosenUserArray.joined(separator: ", ")
            } else {
                groupMemberLabel.text = "ADD PEOPLE TO YOUR GROUP"
                doneBtn.isHidden = true
            }
        }
    }
}
