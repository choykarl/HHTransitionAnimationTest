//
//  ViewController.swift
//  transitionAnimation
//
//  Created by karl on 2017-07-02.
//  Copyright © 2017年 Karl. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  var tableView: HomeTableView?
  let topImageView = AnimationImageView()
  let bottomImageView = AnimationImageView()
  let leftImageView = AnimationImageView()
  let rightImageView = AnimationImageView()
  let tapImageView = AnimationImageView()
  override func viewDidLoad() {
    super.viewDidLoad()
    
    automaticallyAdjustsScrollViewInsets = false
    
    tableView = HomeTableView(frame: CGRect(x: 0, y: 64, width: ScreenWidth, height: ScreenHeight - 64), style: .plain)
    view.addSubview(tableView!)
    
    view.addSubview(topImageView)
    view.addSubview(bottomImageView)
    view.addSubview(leftImageView)
    view.addSubview(rightImageView)
    view.addSubview(tapImageView)
  }
  
  func doAnimation(_ topImageModel: AnimationModel, bottomImageModel: AnimationModel, leftImageModel: AnimationModel, rightImageModel: AnimationModel, tapImageModel: AnimationModel) {
    tableView?.isHidden = true
    navigationController?.navigationBar.isHidden = true
    topImageView.model = topImageModel
    bottomImageView.model = bottomImageModel
    leftImageView.model = leftImageModel
    rightImageView.model = rightImageModel
    tapImageView.model = tapImageModel
    
    
    didDoAnimation {
      let vc = RoomDetailViewController()
      vc.viewController = self
      vc.setImage(tapImageModel.image)
      self.navigationController?.pushViewController(vc, animated: false)
    }
  }
  
  func preparePop() {
    didDoAnimation {
      self.navigationController?.navigationBar.isHidden = false
      self.tableView?.isHidden = false
    }
  }
  
  private func didDoAnimation(_ completion: @escaping () -> ()) {
    let group = DispatchGroup()
    group.enter(); topImageView.doAnimation{ group.leave() }
    
    group.enter(); bottomImageView.doAnimation{ group.leave() }
    
    group.enter(); leftImageView.doAnimation{ group.leave() }
    
    group.enter(); rightImageView.doAnimation{ group.leave() }
    
    group.enter(); tapImageView.doAnimation { group.leave() }
    
    group.notify(queue: .main) {
      completion()
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    didDoAnimation {
      self.tableView?.isHidden = false
    }
  }
}

class AnimationImageView: UIImageView {
  var model: AnimationModel? {
    didSet {
      image = model?.image
    }
  }
  var isDo = false
  func doAnimation(_ completion: @escaping () -> ()) {
    guard let model = model else { return }
    if isDo == false {
      self.isHidden = false
      frame = model.startRect
      UIView.animate(withDuration: 0.35, delay: 0.1, options: UIViewAnimationOptions.curveEaseOut, animations: {
        self.frame = model.endRect
      }) { (_) in
        self.isDo = true
        completion()
      }
    } else {
      UIView.animate(withDuration: 0.35, delay: 0.1, options: UIViewAnimationOptions.curveEaseOut, animations: {
        self.frame = model.startRect
      }) { (_) in
        self.isDo = false
        completion()
        self.isHidden = true
      }
    }
  }
}

