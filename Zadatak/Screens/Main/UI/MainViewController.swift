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
    var connectionManager: ConnectionManager?
    
    var elements: [Element] { dataManager.elements }
    var newElement: Element?
    var returnedElement: ReturnedElement?
    var clickedIndex: Int?
    
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
        connectionManager = ConnectionManager(elements)
        remakeConnections()
    }
    
}

extension MainViewController {
    
    func setupUI(){
        addInsertButton()
        tableView.heightAnchor.constraint(equalToConstant: CGFloat(cellHeight * visibleCellsCount)).isActive = true
    }
    
    func setupTableView(){
        tableView.estimatedRowHeight = CGFloat(cellHeight)
        tableView.rowHeight = CGFloat(cellHeight)
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
    
    func tableView(_ tableView: UITableView, dragSessionDidEnd session: UIDragSession) {
        
        UIView.animate(withDuration: 0.5) {
            for view in self.tableView.subviews {
                if view.tag == lineTag {
                    self.tableView.bringSubviewToFront(view)
                    view.backgroundColor = .systemRed.withAlphaComponent(1)
                }
            }
        }
      
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = elements[indexPath.row]
        
        UIView.animate(withDuration: 0.25) {
            for view in tableView.subviews {
                if view.tag == lineTag {
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
        
        print(tableView.frame.height)


        removePreviousConnections()
        guard let connections = connectionManager?.findConnections(elements) else { return }
        
        for connection in connections {
            makeLine(connection)
        }
        
    }
    
    
    func makeLine(_ connection: Connection){
        
        let i1 = connection.firstIndex
        let i2 = connection.secondIndex
        let position = connection.position
        
        let x = view.bounds.width - CGFloat((tagPaddingRight-8)) + CGFloat(position*(lineSpacing + lineWidth))
                                    
        let newPath = UIView(frame: CGRect(x: x,
                                           y: CGFloat(min(i1 * cellHeight + halfCellHeight, i2 * cellHeight + halfCellHeight)),
                                           width: 4,
                                           height: abs(CGFloat(i1 - i2)) * CGFloat(cellHeight)))
        
        newPath.backgroundColor = .systemRed.withAlphaComponent(0)
        newPath.tag = lineTag
        
        let topPoint = UIView()
        topPoint.frame = CGRect(x: newPath.frame.minX - 2, y: newPath.frame.minY - 2, width: 6, height: 6)
        topPoint.backgroundColor = newPath.backgroundColor
        topPoint.tag = newPath.tag
        
        let bottomPoint = UIView()
        bottomPoint.frame = CGRect(x: newPath.frame.minX - 2, y: newPath.frame.maxY - 2, width: 6, height: 6)
        bottomPoint.backgroundColor = newPath.backgroundColor
        bottomPoint.tag = newPath.tag
        
        tableView.addSubview(newPath)
        tableView.addSubview(topPoint)
        tableView.addSubview(bottomPoint)
        
        UIView.animate(withDuration: 1) {
            newPath.backgroundColor = .systemRed.withAlphaComponent(1)
            topPoint.backgroundColor = newPath.backgroundColor
            bottomPoint.backgroundColor = newPath.backgroundColor
        }
        
    }
        
    func removePreviousConnections(){

        for view in tableView.subviews {
            if view.tag == lineTag {
                view.removeFromSuperview()
            }
        }
    }
    
}
