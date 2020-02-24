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
        self.tableView.reloadData()
        super.viewWillAppear(animated)
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
            let data = try! Data(contentsOf: url!)
            let image = UIImage(data: data)
            cell.imageView?.image = image
            
            if item.title!.count > 15 {
                let index = item.title!.index(item.title!.startIndex, offsetBy: 15)
                let range = item.title!.startIndex..<index
                let subText = item.title![range]
                let dotText = String("...")
                let text = "\(subText)\(dotText)"
                cell.titlelabel.text = text
            } else {
                cell.titlelabel.text = item.title!
            }
            
            if item.content!.count > 20 {
                let index = item.content!.index(item.content!.startIndex, offsetBy: 20)
                let range = item.content!.startIndex..<index
                let subText = item.content![range]
                let dotText = String("...")
                let text = "\(subText)\(dotText)"
                cell.contentLabel.text = text
            } else {
                cell.contentLabel.text = item.content!
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WithoutImageCell", for: indexPath) as! WithoutImageCell
            
            if item.title!.count > 20 {
                let index = item.title!.index(item.title!.startIndex, offsetBy: 20)
                let range = item.title!.startIndex..<index
                let subText = item.title![range]
                let dotText = String("...")
                let text = "\(subText)\(dotText)"
                cell.titleLabel.text = text
            } else {
                cell.titleLabel.text = item.title!
            }
            
            if item.content!.count > 25 {
                let index = item.content!.index(item.content!.startIndex, offsetBy: 25)
                let range = item.content!.startIndex..<index
                let subText = item.content![range]
                let dotText = String("...")
                let text = "\(subText)\(dotText)"
                cell.contentLabel.text = text
            } else {
                cell.contentLabel.text = item.content!
            }
            
            return cell
        }

    }
}

