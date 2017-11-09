import UIKit
import CoreData


class TableViewController: UITableViewController {
    
    var taskList = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ToDos"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let context = getContext()
        let request = getFetchRequest()
        do {
            taskList = (try context.fetch(request))
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = taskList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = task.value(forKeyPath: "taskDescription") as? String
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let actionSheet = UIAlertController(title: cell?.textLabel?.text, message: nil, preferredStyle: .actionSheet)
        let delete: UIAlertAction = UIAlertAction(title: "Delete Task", style: .destructive) { action in
            self.deleteTask(index: indexPath.row)
            self.tableView.reloadData()
        }
        let copy: UIAlertAction = UIAlertAction(title: "Copy", style: .default) { action in
            UIPasteboard.general.string = cell?.textLabel?.text
        }
        let cancel: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action in }
        actionSheet.addAction(delete)
        actionSheet.addAction(copy)
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addTask(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Task", message: "What would you like to do?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [unowned self] action in
            let textField = alert.textFields?.first
            let taskToSave = textField?.text
            self.saveTask(description: taskToSave!)
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addTextField()
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        present(alert, animated: true)
    }
    
    func saveTask(description: String) {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "Task", in: context)
        let task = NSManagedObject(entity: entity!, insertInto: context)
        task.setValue(description, forKeyPath: "taskDescription")
        do {
            try context.save()
            taskList.append(task)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteTask(index: Int) {
        let context = getContext()
        let request = getFetchRequest()
        do {
            taskList = (try context.fetch(request))
            let task = taskList[index]
            context.delete(task)
            do {
                try context.save()
                taskList.remove(at: index)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        } catch {
            print("Error with request: \(error)")
        }
    }
    
    func getContext() -> NSManagedObjectContext{
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        return context!
    }
    
    func getFetchRequest() -> NSFetchRequest<NSManagedObject> {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Task")
        return request
    }
    
    /*
    In case working with multiple entities use this version of fetchRequest().
     
     func fetchRequest(entityName: String) -> NSFetchRequest<NSManagedObject> {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        return fetchRequest
     }
     */
    
}
