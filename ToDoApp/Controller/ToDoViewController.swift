//
//  ViewController.swift
//  ToDoApp
//
//  Created by Mustafa on 17.11.2021.
//

import UIKit
import CoreData
//UITableViewController yazıyor ViewController yerine, nedeni ise main.Storyboard alanında oluşturmuş olduğumuz tableViewController'ı bağlamak için.
class ToDoViewController: UITableViewController {
    
    var itemArray = [Item]()
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    //MARK: - TableView DataSource methods
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        //Bu alanda versiyon kontrolü yapıp ona göre cell oluşturuyoruz.
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = itemArray[indexPath.row].title
            cell.contentConfiguration = content
        }else {
            cell.textLabel?.text = item.title
        }
        
        //Çekilen verinin done'ı true ise checkmark'ı aktif ediyoruz değilse none yapıyoruz.
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    //Bu fonksiyon da ise kaç tane cell olması gerektiğini belirtiyoruz.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //MARK: - TableView Delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Silme işlemleri için kullanılan metodlar.
        //context.delete(itemArray[indexPath.row])
        //itemArray.remove(at: indexPath.row)
        
        
        //Bu alanda ise checkmark'ı ekleme ve çıkartma işlemini yapıyoruz.
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        tableView.reloadData()
        //Buradaki kodun amacı ise seçmiş olduğumuz sıranın üstündeki seçili olma ibaresini kaldırmak
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

    
    //MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new To Do Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            //Add item butonuna basıldığında yapılacak işlemleri burada yapıyoruz.
            
            //Burada yeni item'ı ekliyoruz
            //Önce if else ile kontrol yapıyoruz, placeholder'ın içinde yazı olup olmadığını
            if textField.text != "" {
                //Eğer string var ise ekliyoruz bu alanda
                
                
                let newItem = Item(context: self.context)
                newItem.title = textField.text!
                newItem.done = false
                newItem.parentCategory = self.selectedCategory
                self.itemArray.append(newItem)
                
                self.saveItems()
                
                //Burada ise eklediğimiz veriyi tableView içinde güncelliyoruz.
                self.tableView.reloadData()
            }else {
                //Yeni bir item yoksa uyarı mesajı gösteriyoruz bu alanda.
                self.showToast(message: "We could not add new item because there is no text", seconds: 3.0)
            }
            
            
            
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manupulation methods
    func saveItems() {
        do {
            try context.save()
        } catch  {
            print("Error while saving data. Error is \(error.localizedDescription)")
        }
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
        }else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch  {
            print("Error while taking data from database. Error is \(error.localizedDescription)")
        }
        tableView.reloadData()
        
    }
    
    
}
//MARK: - Toast message
extension ToDoViewController {
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

//MARK: - Search bar methods
extension ToDoViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
        
        
        
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            
            loadItems()
            DispatchQueue.main.async {
                //Arama yerinde işimiz bitince klavyeyi bu alanda kaybediyoruz.
                searchBar.resignFirstResponder()
            }
            
        }
        
    }
}

