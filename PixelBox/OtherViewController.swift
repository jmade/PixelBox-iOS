import UIKit


struct PixelBox {
    let filename:String
    let imageName:String
    
    let date:Date
    let image:UIImage
    let pixelValues:[PixelValue]
    
    var message:String {
        get {
            return DateFormatter.timestamp.string(from: date)
        }
    }
    
    func deleteFiles(){
        delete([:],filename)
        delete([:],imageName,false)
    }
}



class OtherViewController: UIViewController {
    
    weak var collectionView: UICollectionView!
    var datasource:[PixelBox] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func loadView() {
        super.loadView()
        title = "Saved Creations"
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delaysContentTouches = false
        self.view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            ])
        self.collectionView = collectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.backgroundColor = .white
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.collectionView.register(PixelBoxCell.self, forCellWithReuseIdentifier: PixelBoxCell.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stockData()
    }
    
    
    func stockData(){
        datasource = retrieveFiles().compactMap({ loadFile($0) }).compactMap({loadPixelBox($0)}).sorted(by: { $0.date < $1.date })
    }
    
    
    func loadPixelBox(_ data:NSDictionary) -> PixelBox? {
        
        var filename: String? = nil
        if let fn = data["filename"] as? String {
            filename = fn
        }
        
        
        // date
        var date:Date? = nil
        if let datestring = data["date"] as? String {
            if let convertedDate = DateFormatter.timestamp.date(from: datestring) {
                date = convertedDate
            }
        }
        
        // Image
        var pixelKey: String? = nil
        var image: UIImage? = nil
        if let loadedPixelKey = data["pixelKey"] as? String {
            pixelKey = loadedPixelKey
            if let loadedImage = loadImage(loadedPixelKey) {
                image = loadedImage
            }
        }
        
        //Pixel data
        var pixelValues: [PixelValue] = []
        if let pixelData = data["pixelData"] as? [[String:String]] {
            pixelValues = pixelData.map({PixelValue($0)})
        }
        
        
        if let d = date,let i = image,let key = pixelKey,let file = filename {
           
           return  PixelBox(filename: file, imageName: key, date: d, image: i, pixelValues: pixelValues)
        }
        
        return nil
        
    }



}

extension OtherViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PixelBoxCell.identifier, for: indexPath) as! PixelBoxCell
        cell.configureCell(datasource[indexPath.row])
        return cell
    }
}


extension OtherViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellSelected()
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = .yellow
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = .lightGray
        }
    }
    
    func cellSelected(){
        var name = "-"
        if let selected = collectionView.indexPathsForSelectedItems?.first?.row {
            name = datasource[selected].filename
        }
        
        let alert = UIAlertController(title: "What would you Like to do?", message: name, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Load", style: .default, handler: { _ in
            self.fetchPixelVC()
        }))
        
        alert.addAction(UIAlertAction(title: "Share", style: .default, handler: { _ in
            self.sharePixelBox()
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deletePixelBox()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in }))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func sharePixelBox(){
        if let index = collectionView.indexPathsForSelectedItems?.first?.row {
            let file = datasource[index]
            print(" file -> \(file.filename) ")
            shareFile(file.filename, presentingVC: self)
        }
        
    }
    
    func deletePixelBox() {
        let index = collectionView.indexPathsForSelectedItems?.first?.row ?? 0
        let pixelBox = datasource[index]
        pixelBox.deleteFiles()
        stockData()
    }
    
    func fetchPixelVC() {
        
        let index = collectionView.indexPathsForSelectedItems?.first?.row ?? 0
        
        if let parent = self.parent?.parent {
            if parent is UITabBarController {
                let children = (parent as! UITabBarController).children
                for child in children {
                    if child is PixelViewController {
                        (child as! PixelViewController).remoteLoad(datasource[index])
                    }
                }
            }
        }
        
        
    }
}



extension OtherViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.bounds.size.width - 16, height: 120)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8)
    }
}



class PixelBoxCell: UICollectionViewCell {
    static let identifier = "com.pixelbox.cell"
    
    let textLabel = UILabel()
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        imageView.layer.cornerRadius = 8.0
        imageView.layer.masksToBounds = true
    
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textLabel)
        
        let guide = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            
            imageView.widthAnchor.constraint(equalTo: guide.widthAnchor, multiplier: 1/3),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0),
            imageView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            imageView.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            
            textLabel.topAnchor.constraint(equalTo: guide.topAnchor),
            textLabel.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            textLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            
            ])
        
        contentView.backgroundColor = .lightGray
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping
        
        contentView.layer.cornerRadius = 8.0
        contentView.layer.masksToBounds = true
    }
    
    func configureCell(_ pixelBox:PixelBox) {
        imageView.image = pixelBox.image
        textLabel.text = pixelBox.message
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        fatalError("Interface Builder is not supported!")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        fatalError("Interface Builder is not supported!")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        textLabel.text = nil
    }
}
