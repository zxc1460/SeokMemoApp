//
//  MemoWriteViewController.swift
//  MemoAppWithImages
//
//  Created by Seok on 17/02/2020.
//  Copyright © 2020 swift. All rights reserved.
//

// 멀티 이미지 픽커 라이브러리
// https://github.com/opalorange/OpalImagePicker
import UIKit
import RealmSwift
import Photos
import OpalImagePicker

class MemoWriteViewController: UIViewController{
    // MARK: - variables
    
    var imgArray = [String]()
    var memo: MemoModel?
    var folderName: String?
    
    fileprivate let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        return cv
    }()

    
    // MARK: - outlets, actions
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBAction func selectImages(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "카메라", style: .default, handler: { (result) in
            self.openCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "사진첩", style: .default, handler: { (result) in
            self.openGallery()
        }))
        actionSheet.addAction(UIAlertAction(title: "URL", style: .default, handler: { (result) in
            self.openUrl()
        }))
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (result) in
        }))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func saveMemo(_ sender: Any) {
        if titleTextField.text != "" && contentTextView.text != "" {
            let realm = try! Realm()
            if let m = memo {
                try! realm.write {
                    m.title = titleTextField.text
                    m.content = contentTextView.text
                    m.urls.removeAll()
                    
                    for item in imgArray {
                        m.urls.append(item)
                    }
                    
                    if m.directory == nil {
                        if let folder = folderName {
                            m.directory = folder
                        }
                    }
                    
                    if(m.directory != nil) {
                        let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(m.directory!)
                        print(directoryPath)
                        do {
                            let items = try FileManager.default.contentsOfDirectory(atPath: directoryPath.path)
                            
                            for item in items {
                                var check: Bool = true
                                for str in m.urls {
                                    let url = URL(string: str)
                                    if url!.lastPathComponent == item {
                                        check = false
                                        break
                                    }
                                }
                                if(check) {
                                    let finalpath = directoryPath.appendingPathComponent(item)
                                    do {
                                        try FileManager.default.removeItem(at: finalpath)
                                    } catch {
                                        print("파일 삭제 중 에러 발생")
                                    }
                                }
                            }
                        } catch {
                            print("디렉토리 순회 중 에러 발생")
                        }
                    }
                    
                }
            
                
            } else {
                let newMemo = MemoModel()
                newMemo.title = titleTextField.text
                newMemo.content = contentTextView.text
                if newMemo.directory == nil {
                    if let folder = folderName {
                        newMemo.directory = folder
                    }
                }
                for item in imgArray {
                    newMemo.urls.append(item)
                }
                
                try! realm.write {
                    realm.add(newMemo)
                }
            }
            self.navigationController?.popViewController(animated: true)
            
        } else {
            let alert = UIAlertController(title: "제목과 내용을 입력해주세요.", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - defined function
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openGallery() {
        let imagePicker = OpalImagePickerController()
        self.presentOpalImagePickerController(imagePicker, animated: true, select: { (assets) in
            for i in 0..<assets.count {
                assets[i].getURL { (optionalUrl) in
                    if let url = optionalUrl {
                        let data = try! Data(contentsOf: url)
                        let image = UIImage(data: data)
                        let endIndex = url.lastPathComponent.firstIndex(of: ".")
                        let name = url.lastPathComponent[..<endIndex!] + ".JPG"
                        self.saveAndAppend(image: image, name: String(name))
                        
                    }
                }
            }

            imagePicker.dismiss(animated: true) {
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }, cancel: {
        })
    }
    
    func openUrl() {
        var check: Bool = false
        
        let alert = UIAlertController(title: "URL을 입력하셔야 합니다.", message: nil, preferredStyle: .alert)
        alert.addTextField()
        alert.textFields![0].placeholder = "URL을 입력해주세요."
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            if let str = alert.textFields![0].text {
                if let url = URL(string: str) {
                    if let data = try? Data(contentsOf: url) {
                        if UIImage(data: data) != nil {
                            check = true
                        }
                    }
            
                }
            }
            
            if(check) {
                self.imgArray.append(alert.textFields![0].text!)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            } else {
                let errAlert = UIAlertController(title: "잘못된 URL입니다.", message: nil, preferredStyle: .alert)
                errAlert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                self.present(errAlert, animated: true, completion: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveAndAppend(image: UIImage?, name: String) {
        if let img = image {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            if folderName == nil {
                folderName = String.uniqueName()
            }
            if let m = memo {
                if let dir = m.directory {
                    folderName = dir
                }
            }
            let finalPath = paths.appendingPathComponent(folderName!)
            if !FileManager.default.fileExists(atPath: finalPath.path) {
                do {
                    try FileManager.default.createDirectory(atPath: finalPath.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("디렉토리를 생성하지 못 했습니다.")
                }
            }
            let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(folderName!)
            
            let filename = documentsUrl.appendingPathComponent(name)
            
            
            let data = img.jpegData(compressionQuality: 1.0)//Set image quality here
            do {
                // writes the image data to disk
                try? data?.write(to: filename)
            } catch {
                print("error:", error)
            }
            print(filename.path)
            self.imgArray.append(filename.absoluteString)
        }
    }
    
    // MARK: - functions about view
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let m = memo {
            for item in m.urls {
                imgArray.append(item)
            }
            self.titleTextField.text = m.title!
            self.contentTextView.text = m.content!
            if let folder = m.directory {
                folderName = folder
            }
        }
        
        view.addSubview(collectionView)
        collectionView.backgroundColor = .white
        collectionView.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 5).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60).isActive = true
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.collectionView.reloadData()
    }
}

// MARK: - CollectionView Cell Class

class ImageCell: UICollectionViewCell {
    
    fileprivate let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    fileprivate let deleteButton: UIButton = {
       let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "deleteImage"), for: .normal)
        btn.tintColor = .red
        btn.isHidden = true
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        contentView.addSubview(deleteButton)
        deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - extensions

extension MemoWriteViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2.5, height: collectionView.frame.width / 1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imgArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        if let url = URL(string: imgArray[indexPath.row]) {
            cell.imageView.load(url: url)
        }
        
        cell.deleteButton.isHidden = false
        cell.deleteButton.layer.setValue(indexPath.row, forKey: "index")
        cell.deleteButton.addTarget(self, action: #selector(deleteImage(sender:)), for: .touchUpInside)
        return cell
    }
    
    @objc func deleteImage(sender: UIButton) {
        let i: Int = (sender.layer.value(forKey: "index")) as! Int
        self.imgArray.remove(at: i)
        self.collectionView.reloadData()
    }
        
}


extension PHAsset {
    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        }
    }
}

extension MemoWriteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            saveAndAppend(image: image, name: String.uniqueImageName())
        }
        dismiss(animated: true) {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension String {
    static func uniqueImageName() -> String {
        let uniqueString = ProcessInfo.processInfo.globallyUniqueString + ".JPG"
        
        return uniqueString
    }
    
    static func uniqueName() -> String {
        let uniqueString = ProcessInfo.processInfo.globallyUniqueString
        
        return uniqueString
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }

}
