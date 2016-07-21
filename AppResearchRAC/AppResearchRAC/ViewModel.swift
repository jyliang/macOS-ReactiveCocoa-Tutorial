//
//  ViewModel.swift
//  AppResearchRAC
//
//  Created by Jason Liang on 7/15/16.
//  Copyright © 2016 _company_ All rights reserved.
//

import Cocoa
import ReactiveCocoa

class ViewModel: NSObject {

  let searchTerm = MutableProperty<String>("")
  let searchCount = MutableProperty<Int>(5)
  let itunesResults = MutableProperty<[iTunesResult]>([iTunesResult]())
  let searchEnabled = MutableProperty<Bool>(false)
  let currentSelectionIndex = MutableProperty<Int>(NSNotFound)
  var searchCommand: RACCommand?

  override init() {
    super.init()

    loadSearchCommand()

    searchTerm.producer.startWithNext {
      [weak self]
      (value) in
      guard let s = self else { return }
      s.searchEnabled.value = value.characters.count > 0
    }

    currentSelectionIndex.producer.startWithNext {
      [weak self]
      (index) in
      guard let s = self else {
        return
      }
      guard index != NSNotFound && index >= 0 && index < s.itunesResults.value.count else {
        return
      }
      let result = s.itunesResults.value[index]
      result.loadIcon()
      result.loadScreenShots()
    }

  }

  func loadSearchCommand() {
    self.searchCommand = RACCommand {
      [weak self]
      (object) -> RACSignal! in
      guard let s = self else {
        return RACSignal.empty()
      }

      let signal = s.searchSignal(s.searchTerm.value, resultsCount: s.searchCount.value)
      signal.subscribeNext({ (response) in
        guard let result = response as? NSArray else {
          print("Error: Network response structure has changed. Expecting an array instead.")
          return
        }
        let itunesResults = result.flatMap { $0 as? NSDictionary }
          .map { return iTunesResult(dictionary: $0) }
          .enumerate()
          .map({ (index, element) -> iTunesResult in
            element.rank = index + 1
            return element
        })
        s.itunesResults.value = itunesResults
      })
      return signal
    }
    self.searchCommand?.executionSignals.subscribeNext({ (completion) in
      print("search copmleted")
    })
  }

  func searchSignal(query: String, resultsCount: Int) -> RACSignal {
    return RACSignal.createSignal {
      subscriber in
      iTunesRequestManager.getSearchResults(query, results: resultsCount, langString: "en_US") { (results, error) in
        guard error == nil else {
          subscriber.sendError(error!)
          return
        }
        subscriber.sendNext(results)
        subscriber.sendCompleted()
      }
      return nil
    }
  }
}
