//
//  ViewController.swift
//  ToDoApp
//
//  Created by Mustafa on 17.11.2021.
//

import UIKit

//UITableViewController yazıyor ViewController yerine, nedeni ise main.Storyboard alanında oluşturmuş olduğumuz tableViewController'ı bağlamak için.
class ToDoViewController: UITableViewController {
    
    var itemArray = ["First", "Second", "Third"]
    
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let items = defaults.array(forKey: "TodoListArray") as? [String] {
            itemArray = items
            
        }
    }
    
    //MARK: - TableView DataSource methods

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        //Bu alanda versiyon kontrolü yapıp ona göre cell oluşturuyoruz.
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = itemArray[indexPath.row]
            cell.contentConfiguration = content
        }else {
            cell.textLabel?.text = itemArray[indexPath.row]
        }
        
        return cell
    }
    //Bu fonksiyon da ise kaç tane cell olması gerektiğini belirtiyoruz.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    //MARK: - TableView Delegate methods
    
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            
            //Bu alanda ise checkmark'ı ekleme ve çıkartma işlemini yapıyoruz.
            if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCell.AccessoryType.none {
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }else {
                tableView.cellForRow(at: indexPath)?.accessoryType = .none
            }
            
            //Buradaki kodun amacı ise seçmiş olduğumuz sıranın üstündeki seçili olma ibaresini kaldırmak
            tableView.deselectRow(at: indexPath, animated: true)
        }
    
    //MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new ToDo Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            //Add item butonuna basıldığında yapılacak işlemleri burada yapıyoruz.
            
            //Burada yeni item'ı ekliyoruz
            //Önce if else ile kontrol yapıyoruz, placeholder'ın içinde yazı olup olmadığını
            if textField.text != "" {
                //Eğer string var ise ekliyoruz bu alanda
                self.itemArray.append(textField.text!)
                self.defaults.set(self.itemArray, forKey: "TodoListArray")
                
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
    
}

extension UIViewController{

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

