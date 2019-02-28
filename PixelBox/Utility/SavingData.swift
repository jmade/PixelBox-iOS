
import UIKit


struct FileSave {
    
}


struct SaveDataConstant {
    static let Name:String = "Pixel"
    static let Ext:String = "pxl"
}

typealias Const = SaveDataConstant

func shareFile(_ filename:String,presentingVC:UIViewController) {
    let saveManager = SaveManager(SaveKey(filename,FileExtension.value))
    let activityController = UIActivityViewController(activityItems: ["\(Const.Name) File", saveManager.saveURL], applicationActivities: [CustomActivity()])
    activityController.excludedActivityTypes = [
        UIActivity.ActivityType.assignToContact,
        UIActivity.ActivityType.print,
        UIActivity.ActivityType.addToReadingList,
        UIActivity.ActivityType.saveToCameraRoll,
        UIActivity.ActivityType.openInIBooks,
        UIActivity.ActivityType.copyToPasteboard,
        UIActivity.ActivityType.message,
        UIActivity.ActivityType(rawValue: "com.apple.reminders.RemindersEditorExtension"),
        UIActivity.ActivityType(rawValue: "com.apple.mobilenotes.SharingExtension"),
    ]
    presentingVC.present(activityController, animated: true)
}


struct FileExtension {
    static let value = ".\(Const.Ext)"
}


func loadFile(_ filename:String = "File") -> NSDictionary? {
    let saveManager = SaveManager(SaveKey(filename,FileExtension.value))
    if let openedData = saveManager.open(filename) {
        return openedData
    } else {
        return nil
    }
}

func loadImage(_ imageName:String) -> UIImage? {
    var image: UIImage? = nil
    let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
    let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
    let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
    if let dirPath          = paths.first
    {
        let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(imageName)
        image = UIImage(contentsOfFile: imageURL.path)
    }
    return image
}


func save(_ saveData:SaveData = [:],_ filename:String = "File"){
    let saveManager = SaveManager(SaveKey(filename,FileExtension.value))
    if !saveManager.save(saveData) {
        print("Error Saving")
    } else {
       print("Saved Data")
    }
}

func delete(_ saveData:SaveData = [:],_ filename:String = "File",_ needsExtension:Bool = true){
    print("--\n[DELETING FILE]: \(filename)\n--")
    let saveManager = SaveManager(SaveKey(filename, needsExtension ? FileExtension.value : ""))
    if !saveManager.delete(filename) {
        print("Error Saving")
    } else {
        print("Saved Data")
    }
}



func retrieveFiles() -> [String] {
    
    func listFilesFromDocumentsFolder() -> [String]? {
        return try?FileManager.default.contentsOfDirectory(atPath:FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path)
    }
    
    if let documentFiles = listFilesFromDocumentsFolder() {
        return documentFiles.filter({ $0.contains(".\(Const.Ext)") })
    } else {
        return ["-"]
    }
}





typealias SaveDataEncoded = String

protocol SaveDateEncodable {
    func saveDataEncode() -> SaveDataEncoded
}

func createSaveDataWith(_ encodableData:[SaveDateEncodable]) -> SaveData {
    var encodedSaveData = SaveDataEncoded()
    
    for data in encodableData {
        encodedSaveData.append(data.saveDataEncode())
    }
    
    return ["Data":encodedSaveData] as SaveData
}

typealias SaveData = NSDictionary

struct SaveKey {
    let documentName: String
    let fileExtension : String
    var location : String {
        return documentName + fileExtension
    }
    
    init(_ documentName : String = "Default",_ ext : String = ".plist") {
        self.documentName = documentName
        self.fileExtension = ext
    }
}



struct SaveManager {
    private var savekey : SaveKey
    
    init(_ savekey : SaveKey) {
        self.savekey = savekey
    }
    
    init() {
        self.savekey = SaveKey()
    }
    
}


extension SaveManager {
    public var documentName : String {
        return savekey.documentName
    }
    
    public var fileExtension : String {
        return savekey.fileExtension
    }
    
    public var saveURL : URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(savekey.location)
    }
}


extension SaveManager {

    
    func save(_ data : NSDictionary) -> Bool {
        let savedPlace = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(savekey.location)
        return data.write(toFile: savedPlace.path, atomically: false)
    }
    
    func open(_ fileName : String) -> NSDictionary? {
        let location = fileName
        let savedPlace = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(location)
        let data = NSDictionary(contentsOfFile: savedPlace.path)
        return data
    }
    
    
    func delete(_ fileName : String) -> Bool {
        
        let appendage = fileName + fileExtension
        
        let url = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(appendage)
        
        
        if !FileManager().fileExists(atPath: url.path) {
            print("File: \(appendage) Does Not Exist")
        }
        else {
            
            let url = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(appendage)
            
            do {
                try FileManager.default.removeItem(at: url)
                print(" Deleted File: \(url) ")
            } catch {
                print("Failed to remove file \(appendage) ")
            }
            
        }
        
        
        return true
    }
}





//MARK:  Data Saving - PLIST

struct DataPropertyKey {
    
    static let documentName : String = "\(Const.Name)Data"
    static let fileExtension : String = ".plist"
    
    static let DocumentsDirectory : URL = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL =  DocumentsDirectory.appendingPathComponent(documentName)
    
}


struct DataManager {
    
    func getPath() -> String {
        
        let documentName = DataPropertyKey.documentName
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let appendage = documentName + DataPropertyKey.fileExtension
        let path = documentDirectory.appendingPathComponent(appendage)
        
        return path
    }
    
    
    func makePlist(_ plistName : String, rootDictionary : NSDictionary) -> Bool {
        
        var result = true
        let documentName = plistName
        let fileManager = FileManager.default
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let appendage = documentName + DataPropertyKey.fileExtension
        let path = documentDirectory.appendingPathComponent(appendage)
        if(!fileManager.fileExists(atPath: path)) {
            let baseData = rootDictionary
            let isWritten = baseData.write(toFile: path, atomically: true)
            print("is the file created: \(isWritten)")
        }
        else {
            result = false
        }
        
        return result
    }
}









