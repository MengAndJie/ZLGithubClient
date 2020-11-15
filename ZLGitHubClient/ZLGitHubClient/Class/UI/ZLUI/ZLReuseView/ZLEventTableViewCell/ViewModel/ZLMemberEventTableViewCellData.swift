//
//  ZLMemberEventTableViewCellData.swift
//  ZLGitHubClient
//
//  Created by 朱猛 on 2020/7/7.
//  Copyright © 2020 ZM. All rights reserved.
//

import UIKit

class ZLMemberEventTableViewCellData: ZLEventTableViewCellData {
    
    private var _eventDescription : NSAttributedString?
    
    override func getEventDescrption() -> NSAttributedString {
        if _eventDescription != nil {
            return _eventDescription!
        }
        
        guard let payload : ZLMemberEventPayloadModel = self.eventModel.payload as? ZLMemberEventPayloadModel else {
            return super.getEventDescrption()
        }
        
        let str = "\(payload.action) collaborator \(payload.member.loginName)\n\nto \(self.eventModel.repo.name)"
        let attributedStr =  NSMutableAttributedString.init(string: str , attributes: [NSAttributedString.Key.foregroundColor:UIColor.init(cgColor: UIColor.init(named: "ZLLabelColor3")!.cgColor),NSAttributedString.Key.font:UIFont.init(name: Font_PingFangSCRegular, size: 15.0)!])
        
        weak var weakSelf = self
        
        let memberRange = (str as NSString).range(of: "\(payload.member.loginName)")
        attributedStr.yy_setTextHighlight(memberRange, color: UIColor.init(cgColor: UIColor.init(named: "ZLLinkLabelColor1")!.cgColor), backgroundColor: UIColor.clear , tapAction: {(containerView : UIView, text : NSAttributedString, range: NSRange, rect : CGRect) in
            let vc = ZLUserInfoController.init(loginName: payload.member.loginName, type: ZLGithubUserType_User)
            vc.hidesBottomBarWhenPushed = true
            weakSelf?.viewController?.navigationController?.pushViewController(vc, animated: true)
        })
        
        let repoNameRange = (str as NSString).range(of: self.eventModel.repo.name)
        attributedStr.yy_setTextHighlight(repoNameRange, color: UIColor.init(cgColor: UIColor.init(named: "ZLLinkLabelColor1")!.cgColor), backgroundColor: UIColor.clear , tapAction: {(containerView : UIView, text : NSAttributedString, range: NSRange, rect : CGRect) in
            
            let repoModel = ZLGithubRepositoryModel.init()
            repoModel.full_name = weakSelf?.eventModel.repo.name ?? "";
            let vc = ZLRepoInfoController.init(repoInfoModel: repoModel)
            vc.hidesBottomBarWhenPushed = true
            weakSelf?.viewController?.navigationController?.pushViewController(vc, animated: true)
            
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
    
    override func clearCache() {
        self._eventDescription = nil
    }
    
    
}
