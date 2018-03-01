//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Kyle Wang on 2018-02-25.
//  Copyright © 2018 Kyle Wang. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categoryArray : Results<Category>?

//    // use UIApplication.shared to get current app as an object as AppDelegate to get the database context
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategory()
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat.hexValue()
            
            self.save(category: newCategory)
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //
    //MARK: - TableView Datasource Methods
    //
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No categories added yet"
        
        if let category = categoryArray?[indexPath.row] {
            
            guard let categoryColor = UIColor(hexString:category.color) else {fatalError()}
            cell.backgroundColor = categoryColor
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // if categoryArray is nil then return 1 as value
        return categoryArray?.count ?? 1
    }
    
    //
    //MARK: - TableView Delegate Methods
    //
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVS = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVS.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    
    //
    //MARK: - Data Manipulation Methods
    //
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print(error)
        }
        
        tableView.reloadData()
    }
    
    func loadCategory() {
        
        categoryArray = realm.objects(Category.self)
    
        tableView.reloadData()
    }
    
    // for swipe and delete a cell
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categoryArray?[indexPath.row] {
            
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print(error)
            }
        }
    }
}
