//
//  Products.swift
//  RaceRunner
//
//  Created by Joshua Adams on 2/14/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

public enum Products {
  public static let store = IapHelper(productIdentifiers: Products.productIdentifiers)
  public static let runningHorse = prefix + "runninghorse"
  public static let broadcastRuns = prefix + "broadcastruns"
  private static let productIdentifiers: Set<ProductIdentifier> = [Products.runningHorse, Products.broadcastRuns]
  private static let prefix = "biz.joshadams.RaceRunner."
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
  return productIdentifier.components(separatedBy: ".").last
}
