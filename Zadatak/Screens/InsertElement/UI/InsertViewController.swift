//
//  InsertViewController.swift
//  Zadatak
//
//  Created by Luka Ivanić on 25.09.2021..
//

import UIKit
import ProgressHUD
import CoreData


class InsertViewController: UITableViewController {
    
    var elementToReturn: Element?
    var isEditElement = false
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var titleTextFIeld: UITextField!
    @IBOutlet weak var tagTextField: UITextField!
    @IBOutlet weak var beginningDatePicker: UIDatePicker!
    @IBOutlet weak var endingDatePicker: UIDatePicker!
    @IBOutlet weak var insertButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
                
        displayElementIfExists()
        setupDatePickers()
        configureTextField()
        
    }
    
}

// Logic
extension InsertViewController {
    
    @IBAction func insertPressed(_ sender: Any) {
        
        guard let title = titleTextFIeld.text, !title.isEmpty else {
            ProgressHUD.showFailed("You need to input a title.")
            return
        }
        let beginningDate = beginningDatePicker.date
        let endingDate = endingDatePicker.date
        
        if elementToReturn == nil {
            elementToReturn = Element(context: context)
            elementToReturn?.id = UUID()
        }
        
        elementToReturn?.title = title
        elementToReturn?.tag = tagTextField.text
        elementToReturn?.beginningDate = beginningDate
        elementToReturn?.endingDate = endingDate
        
        performSegue(withIdentifier: "unwindToMainSeg", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let destinationVC = segue.destination as? MainViewController,
              var elementToReturn = elementToReturn else { return }
        
        destinationVC.returnedElement = (isEditElement) ? ReturnedElement.editElement(elementToReturn) : ReturnedElement.insertElement(elementToReturn)
    }
}

// UI
extension InsertViewController: UITextFieldDelegate {
    
    func configureTextField(){
        tagTextField.delegate = self
        titleTextFIeld.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tagTextField {
            tagTextField.resignFirstResponder()
        } else if textField == titleTextFIeld {
            tagTextField.becomeFirstResponder()
        }
        return false
    }
}


extension InsertViewController {
    
    func displayElementIfExists(){
        
        guard let element = elementToReturn else { return }
        
        insertButton.setTitle("Save edit", for: .normal)
                
        titleTextFIeld.text = element.title
        tagTextField.text = element.tag
        beginningDatePicker.setDate(element.beginningDate!, animated: true)
        endingDatePicker.setDate(element.endingDate!, animated: true)
        
    }
    
    func setupDatePickers(){
        beginningDatePicker.addTarget(self, action: #selector(limitEndingDatePicker), for: .valueChanged)
        limitEndingDatePicker()
    }
    
    @objc func limitEndingDatePicker(){
        UIView.animate(withDuration: 0.5) {
            self.endingDatePicker.minimumDate = self.beginningDatePicker.date
        }
    }
    
}

extension InsertViewController {

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


