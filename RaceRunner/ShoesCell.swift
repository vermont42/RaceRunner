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
  private weak var shoesDelegate: ShoesDelegate!
  private var shoes: Shoes!
  private static let curLabel = "Cur: "
  private static let maxLabel = "Max: "
  
  func displayShoes(shoes: Shoes, shoesDelegate: ShoesDelegate) {
    name.text = shoes.name
    kilometers.text = ShoesCell.curLabel + Converter.stringifyKilometers(shoes.kilometers.floatValue, includeUnits: true)
    maxKilometers.text = ShoesCell.maxLabel + Converter.stringifyKilometers(shoes.maxKilometers.floatValue, includeUnits: true)
    thumbnail.image = UIImage(data: shoes.thumbnail)
    updateIsCurrentImage(shoes.isCurrent.boolValue)
    self.shoesDelegate = shoesDelegate
    self.shoes = shoes
    isCurrentImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ShoesCell.toggleIsCurrent)))
    isCurrentImage.userInteractionEnabled = true
  }
  
  func toggleIsCurrent() {
    shoes.isCurrent = NSNumber(bool: !(shoes.isCurrent.boolValue))
    updateIsCurrentImage(shoes.isCurrent.boolValue)
    if shoes.isCurrent.boolValue {
      shoesDelegate.makeNewIsCurrent(shoes)
    }
  }
  
  private func updateIsCurrentImage(isCurrent: Bool) {
    if isCurrent {
      isCurrentImage.image = Shoes.checked
    }
    else {
      isCurrentImage.image = Shoes.unchecked
    }
  }
}
