//
//  ViewController.swift
//  Todoey
//
//  Created by Kyle Wang on 2018-02-22.
//  Copyright © 2018 Kyle Wang. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    var todoItems : Results<Item>?
    
    var selectedCategory : Category? {
        // specify what happens when the variable has a new value
        didSet {
            loadItems()
        }
    }
    
    let defaults = UserDefaults.standard

    // get file path of where the plist resides and append a new plist
    let dataFilePath = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
//    // use UIApplication.shared to get current app as an object as AppDelegate to get the database context
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        if let items = UserDefaults.standard.array(forKey: "TodoListArray") as? [Item] {
//            itemArray = items
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let colorHex = selectedCategory?.color else { fatalError() }
            
        title = selectedCategory?.name
        
        updateNavBar(withHexCode: colorHex)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "1D9BF6")
    }

    //MARK: - Nav Bar Setup Methods
    
    func updateNavBar(withHexCode colorHexCode : String) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
        guard let navBarColor = UIColor(hexString: colorHexCode) else {fatalError() }
        
        searchBar.barTintColor = navBarColor
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //
    //MARK: - TableView Datasource Methods
    //
    
    // create tableView cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // reuse a cell object for return
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items added"
        }
        
        return cell
    }
    
    // tell data source how many cells to display
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    //
    //MARK: - TableView Delegate Methods
    //
    
    // Action when select on a cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
//        // to remove item
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
        
//        todoItems[indexPath.row].done = !todoItems[indexPath.row].done
//        saveItems()
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
//                    // to delete item
//                    realm.delete(item)
                }
            } catch {
                print(error)
            }
        }
        
        tableView.reloadData()
        
        // remove the grayed out background when tapping on a cell
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //
    //MARK: - Add New Item
    //
    
    // Action when add button is pressed
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
  
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print(error)
                }
                
            }
            
            self.tableView.reloadData()
            // store custom objects using UserDefault will crash the app
            //self.defaults.set(self.itemArray, forKey: "TodoListArray")
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //
    //MARK: - Model Manipulation methods
    //
    
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()
    }
    
    // swipe action method
    override func updateModel(at indexPath: IndexPath) {
        
        if let itemToDelete = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(itemToDelete)
                }
            } catch {
                print(error)
            }
        }
    }
}

///
//MARK: - Search Bar Extension
///

extension TodoListViewController: UISearchBarDelegate {
    // filter content with search keywords
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        todoItems = todoItems?.filter("title CONTAINS %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }

    // reload the table view with all content
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                // dismiss the keyboard and cursor on the search bar
                searchBar.resignFirstResponder()
            }
        }
    }
}

//extension TodoListViewController: UISearchBarDelegate {
//    // filter content with search keywords
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        let request : NSFetchRequest<Item> = Item.fetchRequest()
//
//        let predicate = NSPredicate(format: "title CONTAINS %@", searchBar.text!)
//
//        request.predicate = predicate
//
//        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
//        request.sortDescriptors = [sortDescriptor]
//
//        loadItems(with: request, predicate: predicate)
//    }
//
//    // reload the table view with all content
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchBar.text?.count == 0 {
//            loadItems()
//
//            DispatchQueue.main.async {
//                // dismiss the keyboard and cursor on the search bar
//                searchBar.resignFirstResponder()
//            }
//        }
//    }
//}

