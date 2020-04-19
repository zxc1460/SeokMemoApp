//
//  MemoDetailViewController.swift
//  MemoAppWithImages
//
//  Created by Seok on 13/02/2020.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit
import RealmSwift

class MemoDetailViewController: UIViewController {
    
    // MARK: - variables
    var memo: MemoModel?
    var imgArray = [String]()
    
    fileprivate let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(DetailCell.self, forCellWithReuseIdentifier: "DetailCell")
        return cv
    }()
    
    // MARK: - outlets and actions
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    
    
    @IBAction func deleteMemo(_ sender: Any) {
        if let m = memo {
            if let dir = m.directory {
                let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(dir)
                do {
                    try FileManager.default.removeItem(at: directoryPath)
                } catch {
                    print("디렉토리 삭제 중 에러 발생")
                }
                
            }
            
            let realm = try! Realm()
            try! realm.write {
                realm.delete(m)
            }
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editMemo(_ sender: Any) {
        let memoWriteViewController = self.storyboard?.instantiateViewController(withIdentifier: "MemoWriteViewController") as! MemoWriteViewController
        memoWriteViewController.memo = self.memo
        self.navigationController?.pushViewController(memoWriteViewController, animated: true)
    }
    
    
    // MARK: - fuctions about view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let m = memo {
            imgArray.removeAll()
            for item in m.urls {
                imgArray.append(item)
            }
            
            titleLabel.text = m.title!
            contentTextView.text = m.content!
        }
        
        view.addSubview(collectionView)
        collectionView.backgroundColor = .white
        collectionView.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 5).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60).isActive = true
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        imgArray.removeAll()
        if let m = memo {
            for item in m.urls {
                imgArray.append(item)
            }
            
            titleLabel.text = m.title!
            contentTextView.text = m.content!
        }
        
        self.collectionView.reloadData()
        super .viewWillAppear(animated)
    }

}

// MARK: - UICollectionViewCell
class DetailCell: UICollectionViewCell {
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
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - extension
extension MemoDetailViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2.5, height: collectionView.frame.width / 1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imgArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCell", for: indexPath) as! DetailCell
               if let url = URL(string: imgArray[indexPath.row]) {
                   cell.imageView.load(url: url)
               }
               
               return cell
    }
    
    
}
