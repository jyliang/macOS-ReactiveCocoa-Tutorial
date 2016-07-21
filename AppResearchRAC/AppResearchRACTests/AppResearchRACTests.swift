//
//  AppResearchRACTests.swift
//  AppResearchRACTests
//
//  Created by Jason Liang on 7/15/16.
//  Copyright © 2016 _company_ All rights reserved.
//

import XCTest
@testable import AppResearchRAC

import ReactiveCocoa

class AppResearchRACTests: XCTestCase {

  let searchViewModel = ViewModel()

  override func setUp() {
    super.setUp()
    searchViewModel.searchTerm.value = "Code"
    searchViewModel.searchCount.value = 5
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testiTunesCallWithSignal() {
    let searchTerm = searchViewModel.searchTerm.value
    let signal = searchViewModel.searchSignal(searchTerm, resultsCount: 5)
    signal.subscribeNext({ (result) in
      guard let result = result as? NSArray else {
        XCTFail("Result did not come back as dictionary")
        return
      }
      XCTAssert(result.count == 5, "Result count should be 5")
    })
    do {
      try signal.asynchronouslyWaitUntilCompleted()
    } catch {
    }
  }

  func testiTunesCallWithCommand() {
    if let signal = searchViewModel.searchCommand?.execute("") {
      do {
        try signal.asynchronouslyWaitUntilCompleted()
      } catch {
      }
      XCTAssert(searchViewModel.itunesResults.value.count == searchViewModel.searchCount.value, "Expect converted search result to be the same as specified search count")
    }
  }

  func testNetworkPerformance() {
    // Throw in some performance test on these network calls.
    self.measureBlock {
      self.testiTunesCallWithCommand()
    }
  }

}
