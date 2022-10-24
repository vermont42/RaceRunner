//
//  UITableViewCellExtension.swift
//  RaceRunner
//
//  Created by Josh Adams on 10/21/22.
//  Copyright © 2022 Josh Adams. All rights reserved.
//

import UIKit

extension UITableViewCell {
  var cellActionButtonLabels: [UILabel]? {
    superview?.subviews
      .filter { String(describing: $0).range(of: "UISwipeActionPullView") != nil }
      .flatMap { $0.subviews }
      .filter { String(describing: $0).range(of: "UISwipeActionStandardButton") != nil }
      .flatMap { $0.subviews }
      .compactMap { $0 as? UILabel }
  }
}
