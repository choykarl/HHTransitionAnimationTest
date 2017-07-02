//
//  RoomDetailViewController.swift
//  transitionAnimation
//
//  Created by karl on 2017-07-02.
//  Copyright © 2017年 Karl. All rights reserved.
//

import UIKit

class RoomDetailViewController: UIViewController {

  weak var viewController: ViewController?
  private let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 276))
  private let bottomImageView = UIImageView()
  private let backButton = UIButton(frame: CGRect(x: 20, y: 35, width: 24, height: 24))
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    
    view.backgroundColor = UIColor.white
    view.addSubview(imageView)
    
    bottomImageView.frame = CGRect(x: 0, y: imageView.bottom, width: ScreenWidth, height: ScreenHeight - imageView.bottom + 20)
    bottomImageView.alpha = 0
    bottomImageView.image = UIImage(named: "AirbnbDetail")
    view.addSubview(bottomImageView)
    
    backButton.setImage(UIImage(named: "back"), for: .normal)
    backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
    view.addSubview(backButton)
  }
  
  func back() {
    navigationController?.popViewController(animated: false)
    viewController?.preparePop()
  }
  
  func setImage(_ image: UIImage?) {
    imageView.image = image
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    super.viewWillDisappear(animated)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
      self.bottomImageView.alpha = 1
      self.bottomImageView.setTop(self.bottomImageView.top - 20)
    }, completion: nil)
  }
}
