//
//  HomeTableView.swift
//  过渡动画
//
//  Created by karl on 2017-06-30.
//  Copyright © 2017年 Karl. All rights reserved.
//

let HomeTableViewCellHeight: CGFloat = 156 + 32 + 15
let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height

import UIKit

class HomeTableView: UITableView {

  override init(frame: CGRect, style: UITableViewStyle) {
    super.init(frame: frame, style: style)
    dataSource = self
    showsVerticalScrollIndicator = false
    separatorColor = UIColor.clear
    rowHeight = HomeTableViewCellHeight
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension HomeTableView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 4
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell")
    if cell == nil {
      cell = HomeTableViewCell(style: .default, reuseIdentifier: "HomeTableViewCell")
    }
    return cell!
  }
}
