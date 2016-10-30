//
//  ShoesCell.swift
//  RaceRunner
//
//  Created by Joshua Adams on 1/14/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

import UIKit
import CoreData
import MGSwipeTableCell

class ShoesCell: MGSwipeTableCell {
  @IBOutlet var name: UILabel!
  @IBOutlet var kilometers: UILabel!
  @IBOutlet var maxKilometers: UILabel!
  @IBOutlet var thumbnail: UIImageView!
  @IBOutlet var isCurrentImage: UIImageView!
  fileprivate weak var shoesDelegate: ShoesDelegate!
  fileprivate var shoes: Shoes!
  fileprivate static let curLabel = "Cur: "
  fileprivate static let maxLabel = "Max: "
  
  func displayShoes(_ shoes: Shoes, shoesDelegate: ShoesDelegate) {
    name.text = shoes.name
    kilometers.text = ShoesCell.curLabel + Converter.stringifyKilometers(shoes.kilometers.floatValue, includeUnits: true)
    maxKilometers.text = ShoesCell.maxLabel + Converter.stringifyKilometers(shoes.maxKilometers.floatValue, includeUnits: true)
    thumbnail.image = UIImage(data: shoes.thumbnail as Data)
    updateIsCurrentImage(shoes.isCurrent.boolValue)
    self.shoesDelegate = shoesDelegate
    self.shoes = shoes
    isCurrentImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ShoesCell.toggleIsCurrent)))
    isCurrentImage.isUserInteractionEnabled = true
  }
  
  func toggleIsCurrent() {
    shoes.isCurrent = NSNumber(value: !(shoes.isCurrent.boolValue) as Bool)
    updateIsCurrentImage(shoes.isCurrent.boolValue)
    if shoes.isCurrent.boolValue {
      shoesDelegate.makeNewIsCurrent(shoes)
    }
  }
  
  fileprivate func updateIsCurrentImage(_ isCurrent: Bool) {
    if isCurrent {
      isCurrentImage.image = Shoes.checked
    }
    else {
      isCurrentImage.image = Shoes.unchecked
    }
  }
}
