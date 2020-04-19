//
//  MemoListTableViewController.swift
//  MemoAppWithImages
//
//  Created by Seok on 13/02/2020.
//  Copyright © 2020 swift. All rights reserved.
//

import UIKit
import RealmSwift

class MemoListTableViewController: UITableViewController {
    // MARK: - variables
    
    var realm: Realm?
    var items: Results<MemoModel>?
    
    // MARK: - action
    
    @IBAction func writeMemo(_ sender: Any) {
        let memoWriteViewController = self.storyboard?.instantiateViewController(withIdentifier: "MemoWriteViewController") as! MemoWriteViewController
        
        self.navigationController?.pushViewController(memoWriteViewController, animated: true)
    }
    
    
    // MARK: - function about view appear, load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        realm = try? Realm()
        
        items = realm?.objects(MemoModel.self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let count = items?.count {
            return count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MemoDetailViewController {
            if let item = items?[tableView.indexPathForSelectedRow!.row] {
                destination.memo = item
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = items?[indexPath.row] else {
            return UITableViewCell()
        }
        if item.urls.count > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WithImageCell", for: indexPath) as! WithImageCell
            let url = URL(string: item.urls[0])
            cell.imageView?.image = resizedImage(at: url!, for: CGSize(width: 75, height: 75))
            
            cell.titlelabel.text = item.title!
            cell.contentLabel.text = item.content!
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WithoutImageCell", for: indexPath) as! WithoutImageCell
            
            cell.titleLabel.text = item.title!
            cell.contentLabel.text = item.content!
            
            return cell
        }

    }
    
    func resizedImage(at url: URL, for size: CGSize) -> UIImage? {
        guard let imageSource = CGImageSourceCreateWithURL(url as NSURL, nil),
            let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
        else {
            return nil
        }

        let context = CGContext(data: nil,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: image.bitsPerComponent,
                                bytesPerRow: image.bytesPerRow,
                                space: image.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
                                bitmapInfo: image.bitmapInfo.rawValue)
        context?.interpolationQuality = .high
        context?.draw(image, in: CGRect(origin: .zero, size: size))

        guard let scaledImage = context?.makeImage() else { return nil }

        return UIImage(cgImage: scaledImage)
    }
}

