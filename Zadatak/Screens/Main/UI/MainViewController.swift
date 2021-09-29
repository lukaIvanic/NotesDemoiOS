//
//  MainViewController.swift
//  Zadatak
//
//  Created by Luka Ivanić on 24.09.2021..
//

import UIKit



class MainViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataManager: DataManager = DataManagerImpl()
    
    var elements: [Element] { dataManager.elements }
    var newElement: Element?
    var returnedElement: ReturnedElement?
    var clickedIndex: Int?
    var offset = 0
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        switch returnedElement {
            case .insertElement(let newElement):
                dataManager.addElement(newElement)
                tableView.insertRows(at: [IndexPath(row: Int(newElement.index), section: 0)], with: .automatic)
                remakeConnections()
            case .editElement(let editedElement):
                dataManager.editElement(editedElement)
                tableView.reloadData()
                remakeConnections()
            case .none:
                break
        }
        
        returnedElement = nil
        clickedIndex = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        dataManager.fetchData()
        remakeConnections()
    }
    
}

extension MainViewController {
    
    func setupUI(){
        addInsertButton()
        tableView.heightAnchor.constraint(equalToConstant: CGFloat(cellHeight * 8)).isActive = true
    }
    
    func setupTableView(){
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = 80
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
    }
    
    func addInsertButton(){
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Insert", style: .plain, target: self, action: #selector(insertItem))
        
    }
    
}


extension MainViewController {

    @objc func insertItem(){
        performSegue(withIdentifier: "elementListToInsertSegue", sender: self)
    }

    @IBAction func unwindToMainSeg(_ sender: UIStoryboardSegue) {}

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let insertViewController = segue.destination as? InsertViewController,
              let index = clickedIndex
              else { return }

        insertViewController.elementToReturn = elements[index]
        insertViewController.isEditElement = true
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ElementCell else {
            return UITableViewCell()
        }
        cell.configure(elements[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        clickedIndex = indexPath.row
        performSegue(withIdentifier: "elementListToInsertSegue", sender: self)
    }
}

extension MainViewController: UITableViewDragDelegate, UITableViewDropDelegate {
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            self.dataManager.deleteElement(indexPath)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.remakeConnections()
            
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = elements[indexPath.row]
        
        UIView.animate(withDuration: 0.25) {
            for view in tableView.subviews {
                if view.tag == 12 {
                    view.backgroundColor = .systemRed.withAlphaComponent(0)
                }
            }
        }
        
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let mover = dataManager.elements.remove(at: sourceIndexPath.row)
        dataManager.elements.insert(mover, at: destinationIndexPath.row)

        dataManager.saveData()
        remakeConnections()
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) { }

}



extension MainViewController {
    
    func remakeConnections(){
        
        var count = 0
                
        removePreviousConnections()
        for i1 in 0..<elements.count {
            for i2 in i1+1..<elements.count {
                
                if count >= 4 { break }

                if elements[i1].tag == elements[i2].tag,
                   elements[i1].tag != nil,
                   elements[i1].tag != "",
                   i1 != i2 {
                    makeView(i1, i2)
                    count += 1
                }
            }
        }
    }
    
    func makeView(_ i1: Int, _ i2: Int){
        
        var hieghtOffset: CGFloat = CGFloat(abs((i2-i1-4))*cellHeight)
                            
        let newPath = UIView(frame: CGRect(x: view.bounds.width - CGFloat(halfCellHeight) + CGFloat(offset),
                                           y: CGFloat(min(i1 * cellHeight + halfCellHeight, i2 * cellHeight + halfCellHeight)),
                                           width: 4,
                                           height: abs(CGFloat(i1 - i2)) * CGFloat(cellHeight)))

        newPath.backgroundColor = .systemRed.withAlphaComponent(0)
        newPath.tag = 12
        
        self.tableView.addSubview(newPath)
        
        UIView.animate(withDuration: 1) {
            newPath.backgroundColor = .systemRed.withAlphaComponent(1)
        }
        
        offset += 8
    }
        
    func removePreviousConnections(){

        for view in tableView.subviews {
            if view.tag == 12 {
                view.removeFromSuperview()
            }
        }
        offset = 0
    }
    
}
