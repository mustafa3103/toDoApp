//
//  CategoryViewController.swift
//  ToDoApp
//
//  Created by Mustafa on 23.11.2021.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categoryArray = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()

    }

    
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { action in
            //Add item butonuna basıldığında yapılacak işlemleri burada yapıyoruz.
            
            //Burada yeni item'ı ekliyoruz
            //Önce if else ile kontrol yapıyoruz, placeholder'ın içinde yazı olup olmadığını
            if textField.text != "" {
                //Eğer string var ise ekliyoruz bu alanda
                
                
                let newCategory = Category(context: self.context)
                newCategory.name = textField.text!
                
                
                self.categoryArray.append(newCategory)
                
                self.saveCategories()
                
                //Burada ise eklediğimiz veriyi tableView içinde güncelliyoruz.
                self.tableView.reloadData()
            }else {
                //Yeni bir item yoksa uyarı mesajı gösteriyoruz bu alanda.
                self.showToast(message: "We could not add new category because there is no text", seconds: 3.0)
            }
            
            
            
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
            
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    

    //MARK: - TableView Datasource methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        let category = categoryArray[indexPath.row]
        
        //Bu alanda versiyon kontrolü yapıp ona göre cell oluşturuyoruz.
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = categoryArray[indexPath.row].name
            cell.contentConfiguration = content
        }else {
            cell.textLabel?.text = category.name
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    
    //MARK: - TableView Delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            
            destinationVC.selectedCategory = categoryArray[indexPath.row]
            
        }
        
        
        
    }
    
    
    //MARK: - Data Manipulation
    func saveCategories() {
        do {
            try context.save()
        } catch  {
            print("Error while saving data. Error is \(error.localizedDescription)")
        }
        self.tableView.reloadData()
    }
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        
        do {
            categoryArray = try context.fetch(request)
        } catch  {
            print("Error while taking data from database. Error is \(error.localizedDescription)")
        }
        tableView.reloadData()
        
    }
    
}

//MARK: - Toast message
extension CategoryViewController {
    func showToast(message : String, seconds: Double){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = .black
        alert.view.alpha = 0.5
        alert.view.layer.cornerRadius = 15
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
}
