//
//  HomeTableViewCell.swift
//  过渡动画
//
//  Created by karl on 2017-06-30.
//  Copyright © 2017年 Karl. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
  var collectionView: UICollectionView?
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    layoutIfNeeded()
    let layout = UICollectionViewFlowLayout()
    let margin: CGFloat = 15
    layout.itemSize = CGSize(width: 232, height: HomeTableViewCellHeight)
    layout.scrollDirection = .horizontal
    
    collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: HomeTableViewCellHeight), collectionViewLayout: layout)
    collectionView?.contentInset = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
    collectionView?.delegate = self
    collectionView?.dataSource = self
    collectionView?.backgroundColor = UIColor.clear
    collectionView?.showsHorizontalScrollIndicator = false
    collectionView?.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: "HomeCollectionViewCell")
    contentView.addSubview(collectionView!)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension HomeTableViewCell: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let cell = collectionView.cellForItem(at: indexPath) as? HomeCollectionViewCell {
      let models = cell.clipScreen()
      let topImageModel = models.topModel
      let bottomImageModel = models.bottomModel
      let leftImageModel = models.leftImageModel
      let rightImageModel = models.rightImageModel
      let tapImageModel = models.tapImageModel
      if let controller = viewController() as? ViewController {
        controller.doAnimation(topImageModel, bottomImageModel: bottomImageModel, leftImageModel: leftImageModel, rightImageModel: rightImageModel, tapImageModel: tapImageModel)
      }
    }
  }
}

extension HomeTableViewCell: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 5
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as? HomeCollectionViewCell else {
      fatalError("HomeCollectionViewCell注册失败")
    }
    cell.setImage("Airbnb0\(indexPath.row)")
    return cell
  }
}

class HomeCollectionViewCell: UICollectionViewCell {
  private let pictureImageView = UIImageView()
  private let priceImageView = UIImageView()
  override init(frame: CGRect) {
    super.init(frame: frame)
    pictureImageView.frame = CGRect(x: 0, y: 0, width: width, height: 156)
    contentView.addSubview(pictureImageView)
    
    priceImageView.frame = CGRect(x: 0, y: pictureImageView.bottom, width: width, height: 32)
    priceImageView.image = UIImage(named: "AirbnbPrice")
    contentView.addSubview(priceImageView)
  }
  
  func setImage(_ named: String) {
    pictureImageView.image = UIImage(named: named)
  }
  
  func getPictureImageView() -> UIImageView {
    return pictureImageView
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension HomeCollectionViewCell {
  func clipScreen() -> (topModel: AnimationModel, bottomModel: AnimationModel, leftImageModel: AnimationModel, rightImageModel: AnimationModel, tapImageModel: AnimationModel) {
    let cgImageRef = viewController()?.view.window?.snapshotImage().cgImage
    let imageView = getPictureImageView()
    guard let convertRect = imageView.superview?.convert(imageView.frame, to: nil) else {
      fatalError("cell的imageView的superView怎么能为空呢!!!!")
    }
    let scale = UIScreen.main.scale
    let topRect = CGRect(x: 0, y: 0, width: ScreenWidth * scale, height: convertRect.origin.y * scale)
    let bottomRect = CGRect(x: 0, y: convertRect.maxY * scale, width: ScreenWidth * scale, height: (ScreenHeight - convertRect.maxY) * scale)
    let leftRect = CGRect(x: 0, y: convertRect.origin.y * scale, width: convertRect.origin.x * scale, height: convertRect.height * scale)
    let rightRect = CGRect(x: convertRect.maxX * scale, y: convertRect.origin.y * scale, width: (ScreenWidth - convertRect.maxX) * scale, height: convertRect.height * scale)
    let topCgImage = cgImageRef?.cropping(to: topRect)
    let bottomCgImage = cgImageRef?.cropping(to: bottomRect)
    let leftCgImage = cgImageRef?.cropping(to: leftRect)
    let rightCgImage = cgImageRef?.cropping(to: rightRect)
    
    // 上
    let topModel = AnimationModel(image: UIImage(cgimage: topCgImage), startRect: CGRect(x: 0, y: 0, width: ScreenWidth, height: convertRect.origin.y), endRect: CGRect(x: 0, y: -convertRect.origin.y, width: ScreenWidth, height: convertRect.origin.y))
    // 下
    let bottomModel = AnimationModel(image: UIImage(cgimage: bottomCgImage), startRect: CGRect(x: 0, y: convertRect.maxY, width: ScreenWidth, height: (ScreenHeight - convertRect.maxY)), endRect: CGRect(x: 0, y: ScreenHeight, width: ScreenWidth, height: ScreenHeight - convertRect.maxY))
    // 左
    
    let s = 276 / convertRect.height
    let leftModel = AnimationModel(image: UIImage(cgimage: leftCgImage), startRect: CGRect(x: 0, y: convertRect.origin.y, width: convertRect.origin.x, height: convertRect.height), endRect: CGRect(x: -convertRect.origin.x * s, y: 0, width: convertRect.origin.x * s, height: convertRect.height * s))
    // 右
    let rightModel = AnimationModel(image: UIImage(cgimage: rightCgImage), startRect: CGRect(x: convertRect.maxX, y: convertRect.origin.y, width: ScreenWidth - convertRect.maxX, height: convertRect.height), endRect: CGRect(x: ScreenWidth, y: 0, width: (ScreenWidth - convertRect.maxX) * s, height: convertRect.height * s))
    
    let tapModel = AnimationModel(image: imageView.image, startRect: convertRect, endRect: CGRect(x: 0, y: 0, width: ScreenWidth, height: 276))
    return(topModel, bottomModel, leftModel, rightModel, tapModel)
  }
}

struct AnimationModel {
  var image: UIImage?
  var startRect: CGRect
  var endRect: CGRect
}

extension UIImage {
  convenience init?(cgimage: CGImage?) {
    if let cgimage = cgimage {
      self.init(cgImage: cgimage)
    } else {
      self.init(named: "")
    }
  }
}
