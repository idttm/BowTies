//
//  ColorAttributeTransformer.swift
//  BowTies
//
//  Created by Andrew Cheberyako on 20.04.2021.
//

import UIKit

class ColorAttributeTransformer:
  NSSecureUnarchiveFromDataTransformer {

  //1
  override static var allowedTopLevelClasses: [AnyClass] {
    [UIColor.self]
  }

  //2
  static func register() {
    let className =
      String(describing: ColorAttributeTransformer.self)
    let name = NSValueTransformerName(className)

    let transformer = ColorAttributeTransformer()
    ValueTransformer.setValueTransformer(
      transformer, forName: name)
  }
}
