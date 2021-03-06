//
//  ZLRepoHeaderInfoView.swift
//  ZLGitHubClient
//
//  Created by 朱猛 on 2019/8/19.
//  Copyright © 2019 ZM. All rights reserved.
//

import UIKit

@objc enum ZLRepoHeaderInfoViewEvent : Int {         // 在enum之前加@objc 可以转换为objc enum
    case issue = 1
    case star = 2
    case copy = 3
    case watch = 4
    case watchAction = 5
    case starAction = 6
    case forkAction = 7
    case imageAction = 8
}

@objc protocol ZLRepoHeaderInfoViewDelegate: NSObjectProtocol
{
    var avatarUrl: String? {get}
    var repoName: NSAttributedString? {get}
    var updatedTime: String? {get}
    var desc: String? {get}
    var issueNum: Int {get}
    var starsNum: Int {get}
    var forksNum: Int {get}
    var watchersNum: Int {get}
    
    func onZLRepoHeaderInfoViewEvent(event: ZLRepoHeaderInfoViewEvent)
}

class ZLRepoHeaderInfoView: ZLBaseView {


    @IBOutlet weak var headImageButton: UIButton!
    @IBOutlet weak var repoNameLabel: YYLabel!
    @IBOutlet  weak var timeLabel: UILabel!
    @IBOutlet  weak var descLabel: UILabel!
    
    @IBOutlet private weak var issuesButton: UIButton!
    @IBOutlet private weak var starsButton: UIButton!
    @IBOutlet private weak var forksButton: UIButton!
    @IBOutlet private weak var watchersButton: UIButton!
    
    @IBOutlet weak var issuesNumLabel: UILabel!
    @IBOutlet weak var starsNumLabel: UILabel!
    @IBOutlet weak var forksNumLabel: UILabel!
    @IBOutlet weak var watchersNumLabel: UILabel!
    
    @IBOutlet weak var watchButton: UIButton!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var forkButton: UIButton!
    
    
    weak var delegate : ZLRepoHeaderInfoViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.repoNameLabel.preferredMaxLayoutWidth = ZLKeyWindowWidth - 60
        self.justUpdate()
    }
    
    
    
    @IBAction func onButtonClicked(_ sender: UIButton) {
        self.delegate?.onZLRepoHeaderInfoViewEvent(event: ZLRepoHeaderInfoViewEvent.init(rawValue: sender.tag) ?? .issue)
    }
    
    
    func justUpdate() {
        self.issuesButton.setTitle(ZLLocalizedString(string: "issues", comment: "问题"), for: .normal)
        self.starsButton.setTitle(ZLLocalizedString(string: "star", comment: "标星"), for: .normal)
        self.forksButton.setTitle(ZLLocalizedString(string: "fork", comment: "拷贝"), for: .normal)
        self.watchersButton.setTitle(ZLLocalizedString(string: "watcher", comment: "关注"), for:.normal)
        
        self.watchButton.setTitle(ZLLocalizedString(string: "Watch", comment: "关注"), for: .normal)
        self.starButton.setTitle(ZLLocalizedString(string: "Star", comment: "标星"), for: .normal)
        self.forkButton.setTitle(ZLLocalizedString(string: "Fork", comment: "拷贝"), for: .normal)
        self.watchButton.setTitle(ZLLocalizedString(string: "Unwatch", comment: "取消关注"), for: .selected)
        self.starButton.setTitle(ZLLocalizedString(string: "Unstar", comment: "取消标星"), for: .selected)
        timeLabel.text = delegate?.updatedTime
    }
    
    
    func fillWithData(delegate: ZLRepoHeaderInfoViewDelegate){
        self.delegate = delegate
        self.reloadData()
    }
    
    func reloadData(){
        headImageButton.sd_setBackgroundImage(with: URL(string: delegate?.avatarUrl ?? ""),
                                              for: .normal,
                                              placeholderImage: UIImage.init(named: "default_avatar"))
        repoNameLabel.attributedText = delegate?.repoName
        timeLabel.text = delegate?.updatedTime
        descLabel.text = delegate?.desc
        
        issuesNumLabel.text = "\(delegate?.issueNum ?? 0)"
        starsNumLabel.text = "\(delegate?.starsNum ?? 0)"
        forksNumLabel.text = "\(delegate?.forksNum ?? 0)"
        watchersNumLabel.text = "\(delegate?.watchersNum ?? 0)"
    }
    
}
