import UIKit
import CoreData

class ViewController: UIViewController {
    
    var taskList = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ToDos"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Task")
        do {
            taskList = (try managedContext?.fetch(fetchRequest))!
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addTodo(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Task", message: "What would you like to do?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [unowned self] action in
            let textField = alert.textFields?.first
            let taskToSave = textField?.text
            self.save(description: taskToSave!)
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addTextField()
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        present(alert, animated: true)
    }
    
    func save(description: String) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate?.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Task", in: managedContext!)
        let task = NSManagedObject(entity: entity!, insertInto: managedContext)
        task.setValue(description, forKeyPath: "taskDescription")
        do {
            try managedContext?.save()
            taskList.append(task)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = taskList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = task.value(forKeyPath: "taskDescription") as? String
        return cell
    }
    
}

