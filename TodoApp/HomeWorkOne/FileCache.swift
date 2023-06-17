import Foundation

class FileCache {
    private(set) var todoItems: [TodoItem] = []
    
    func addNewTodoItem(todoItem: TodoItem) {
        for i in 0..<todoItems.count {
            if (todoItem.id == todoItems[i].id) {
                todoItems[i] = todoItem
                return
            }
        }
        todoItems.append(todoItem)
    }
    
    func removeTodoItem(id: String) {
        for i in 0..<todoItems.count {
            if (id == todoItems[i].id) {
                todoItems.remove(at: i);
                break
            }
        }
    }
    
    func saveTodoItemsToFile(fileName: String) {
        guard let fileURL = getFileURL(fileName: fileName) else {return}
        var jsonDatas: [[String : Any]] = []
        for item in todoItems {
            if let json = item.json as? [String : Any] {
                jsonDatas.append(json)
            }
        }
        do {
            let combinedJsonData = try JSONSerialization.data(withJSONObject: jsonDatas, options: .prettyPrinted)
            try combinedJsonData.write(to: fileURL)
            print(fileURL.path)
            print("File created and written successfully.")
        } catch {
            print("Error: \(error)")
        }
    }
    

    func loadTodoItemsFromFile(fileName: String) {
        guard let fileURL = getFileURL(fileName: fileName) else {return}
        do {
            let json = try Data(contentsOf: fileURL)
            guard let todoItems = try JSONSerialization.jsonObject(with: json, options: []) as? [[String : Any]] else {return}
            self.todoItems = []
            for item in todoItems {
                guard let todoItem = TodoItem.parse(json: item) else {continue}
                self.todoItems.append(todoItem)
            }
        } catch {
            print("Error reading file: \(error)")
        }
    }
    
    
    func saveTodoItemsToCSVFile(fileName: String) {
        guard let fileURL = getFileURL(fileName: fileName) else {return}
        let csvString = todoItems.map({$0.csv}).joined(separator: "\n")
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print(error)
        }
    }
    
    func loadTodoItemsFromCSVFile(fileName: String) {
        guard let fileURL = getFileURL(fileName: fileName) else {return}
        do {
            let csvString = try String(contentsOf: fileURL)
            let csvRows = csvString.components(separatedBy: "\n")
            self.todoItems = []
            for csvRow in csvRows {
                guard let todoItem = TodoItem.parse(csvRow: csvRow) else {continue}
                self.todoItems.append(todoItem)
            }
        } catch {
            print(error)
        }
    }
    
    
    private func getFileURL(fileName: String) -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to access documents directory.")
            return nil
        }
        return documentsDirectory.appendingPathComponent(fileName)
    }
}

