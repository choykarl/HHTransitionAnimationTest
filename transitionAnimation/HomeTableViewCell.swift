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
  // 主要的思路是将全屏截图
  // 然后获取到当前点击的cell的位置
  // 然后将屏幕图片切割成5个部分
  // 当前点击cell的上部和下部,当前点击cell的左边和右边和当前的点击的cell这5个部分
  // 然后将这5部分直接用5个UIImageView加在当前控制器上
  // 给这个5个UIImageView做动画
  // 动画结束,直接无动画的push到下个页面
  func clipScreen() -> (topModel: AnimationModel, bottomModel: AnimationModel, leftImageModel: AnimationModel, rightImageModel: AnimationModel, tapImageModel: AnimationModel) {
    
    // 给当前控制器view截图
    let cgImageRef = viewController()?.view.window?.snapshotImage().cgImage
    
    // 获取点击的cell上的imageView
    let imageView = getPictureImageView()
    // 将这个imageView坐标系转换到主窗口
    guard let convertRect = imageView.superview?.convert(imageView.frame, to: nil) else {
      fatalError("cell的imageView的superView怎么能为空呢!!!!")
    }
    
    let scale = UIScreen.main.scale
    // 根据点击的cell上的图片在主窗口上的位置,将前面截的图分割为上下左右4个部分
    let topRect = CGRect(x: 0, y: 0, width: ScreenWidth * scale, height: convertRect.origin.y * scale)
    let bottomRect = CGRect(x: 0, y: convertRect.maxY * scale, width: ScreenWidth * scale, height: (ScreenHeight - convertRect.maxY) * scale)
    let leftRect = CGRect(x: 0, y: convertRect.origin.y * scale, width: convertRect.origin.x * scale, height: convertRect.height * scale)
    let rightRect = CGRect(x: convertRect.maxX * scale, y: convertRect.origin.y * scale, width: (ScreenWidth - convertRect.maxX) * scale, height: convertRect.height * scale)
    
    // 根据上面计算的上下左右4个rect,将截图切割开
    let topCgImage = cgImageRef?.cropping(to: topRect)
    let bottomCgImage = cgImageRef?.cropping(to: bottomRect)
    let leftCgImage = cgImageRef?.cropping(to: leftRect)
    let rightCgImage = cgImageRef?.cropping(to: rightRect)
    
    /* 包装成模型方便用
       模型里包括,切割后的图片,动画的起始位置,和动画的结束位置
     */
    
    // 上
    let topModel = AnimationModel(image: UIImage(cgimage: topCgImage), startRect: CGRect(x: 0, y: 0, width: ScreenWidth, height: convertRect.origin.y), endRect: CGRect(x: 0, y: -convertRect.origin.y, width: ScreenWidth, height: convertRect.origin.y))
    // 下
    let bottomModel = AnimationModel(image: UIImage(cgimage: bottomCgImage), startRect: CGRect(x: 0, y: convertRect.maxY, width: ScreenWidth, height: (ScreenHeight - convertRect.maxY)), endRect: CGRect(x: 0, y: ScreenHeight, width: ScreenWidth, height: ScreenHeight - convertRect.maxY))
    // 左
    let s = 276 / convertRect.height
    let leftModel = AnimationModel(image: UIImage(cgimage: leftCgImage), startRect: CGRect(x: 0, y: convertRect.origin.y, width: convertRect.origin.x, height: convertRect.height), endRect: CGRect(x: -convertRect.origin.x * s, y: 0, width: convertRect.origin.x * s, height: convertRect.height * s))
    // 右
    let rightModel = AnimationModel(image: UIImage(cgimage: rightCgImage), startRect: CGRect(x: convertRect.maxX, y: convertRect.origin.y, width: ScreenWidth - convertRect.maxX, height: convertRect.height), endRect: CGRect(x: ScreenWidth, y: 0, width: (ScreenWidth - convertRect.maxX) * s, height: convertRect.height * s))
    // 当前点击的
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
