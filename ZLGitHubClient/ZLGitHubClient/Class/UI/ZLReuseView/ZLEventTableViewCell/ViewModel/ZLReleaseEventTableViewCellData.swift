//
//  ZLReleaseEventTableViewCellData.swift
//  ZLGitHubClient
//
//  Created by 朱猛 on 2020/7/7.
//  Copyright © 2020 ZM. All rights reserved.
//

import UIKit

class ZLReleaseEventTableViewCellData: ZLEventTableViewCellData {
    
    private var _eventDescription : NSAttributedString?
    
    override func getEventDescrption() -> NSAttributedString {
        if _eventDescription != nil {
            return _eventDescription!
        }
        
        guard let payload : ZLReleaseEventPayloadModel = self.eventModel.payload as? ZLReleaseEventPayloadModel else {
            return super.getEventDescrption()
        }
        
        let str = "\(payload.action) release \(payload.releaseModel.tag_name)\n\n  \(payload.releaseModel.name)\n\nin \(self.eventModel.repo.name)"
        let attributedStr =  NSMutableAttributedString.init(string: str , attributes: [NSAttributedString.Key.foregroundColor:UIColor.init(cgColor: UIColor.init(named: "ZLLabelColor3")!.cgColor),NSAttributedString.Key.font:UIFont.init(name: Font_PingFangSCRegular, size: 15.0)!])
                
        weak var weakSelf = self
        
        let releaseRange = (str as NSString).range(of: payload.releaseModel.tag_name)
        attributedStr.yy_setTextHighlight(releaseRange, color: UIColor.init(cgColor: UIColor.init(named: "ZLLinkLabelColor1")!.cgColor), backgroundColor: UIColor.clear , tapAction: {(containerView : UIView, text : NSAttributedString, range: NSRange, rect : CGRect) in
            let vc = ZLWebContentController.init()
            vc.requestURL = URL.init(string: payload.releaseModel.html_url)
            vc.hidesBottomBarWhenPushed = true
            weakSelf?.viewController?.navigationController?.pushViewController(vc, animated: true)
        })
        
        let repoNameRange = (str as NSString).range(of: self.eventModel.repo.name)
        attributedStr.yy_setTextHighlight(repoNameRange, color: UIColor.init(cgColor: UIColor.init(named: "ZLLinkLabelColor1")!.cgColor), backgroundColor: UIColor.clear , tapAction: {[weak weakSelf = self](containerView : UIView, text : NSAttributedString, range: NSRange, rect : CGRect) in
            
            if let repoFullName = weakSelf?.eventModel.repo.name,let vc = ZLUIRouter.getRepoInfoViewController(repoFullName: repoFullName) {
                vc.hidesBottomBarWhenPushed = true
                weakSelf?.viewController?.navigationController?.pushViewController(vc, animated: true)
            }
        })
        
        _eventDescription = attributedStr
        
        return attributedStr
    }
    
    override func getCellReuseIdentifier() -> String {
        return "ZLEventTableViewCell"
    }
    
    override func getCellHeight() -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func onCellSingleTap() {
        
        guard let payload : ZLReleaseEventPayloadModel = self.eventModel.payload as? ZLReleaseEventPayloadModel else {
            return
        }
        
        let vc = ZLWebContentController.init()
        vc.requestURL = URL.init(string: payload.releaseModel.html_url)
        vc.hidesBottomBarWhenPushed = true
        self.viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func clearCache() {
        self._eventDescription = nil
    }

}
