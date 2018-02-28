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

class TodoListViewController: UITableViewController {
    
    let realm = try! Realm()
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            cell.accessoryType = item.done ? .checkmark : .none
            
//            if (item.done == true) {
//                cell.accessoryType = .checkmark
//            }
//            else {
//                cell.accessoryType = .none
//            }
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
    
//    // save the database
//    func saveItems() {
//        do {
//            try context.save()
//        }
//        catch {
//            print("Error encoding array, \(error)")
//        }
//        tableView.reloadData()
//    }
    
    // give the method the ability to be called with default value which is no parameter as well
    func loadItems() {

//        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
//
//        // To avoid unwrap nil predicate parameter
//        if let additionalPredicate = predicate {
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
//        } else {
//            request.predicate = categoryPredicate
//        }
//
////        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, categoryPredicate])
////
////        request.predicate = compoundPredicate
//
//        do {
//            itemArray = try context.fetch(request)
//        } catch {
//            print(error)
//        }
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()
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

