//
//  ZLNewsBaseView.swift
//  ZLGitHubClient
//
//  Created by LongMac on 2019/8/30.
//  Copyright © 2019年 ZM. All rights reserved.
//

import UIKit

class ZLNewsBaseView: ZLBaseView {

    @IBOutlet weak var tableView: UITableView!
    
    override func awakeFromNib() {
        
        tableView.autoresizingMask = UIViewAutoresizing.init(rawValue: 0)
        tableView.register(UINib.init(nibName: "ZLNewsTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "ZLNewsTableViewCell")
//        tableView.register(ZLNewsTableViewCell.self, forCellReuseIdentifier: "ZLNewsTableViewCell")
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
    }

}