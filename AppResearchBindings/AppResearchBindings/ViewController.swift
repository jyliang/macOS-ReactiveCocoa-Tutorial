/*
 * Copyright (c) 2015 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Cocoa

class ViewController: NSViewController, NSTextFieldDelegate {

  @IBOutlet var searchResultsController: NSArrayController!
  @IBOutlet weak var numberResultsComboBox: NSComboBox!
  @IBOutlet weak var collectionView: NSCollectionView!

  @IBOutlet weak var searchTextField: NSTextField!

  dynamic var loading = false

  override func viewDidLoad() {
    super.viewDidLoad()

    let itemPrototype = self.storyboard?.instantiateControllerWithIdentifier("collectionViewItem")
    as! NSCollectionViewItem
    collectionView.itemPrototype = itemPrototype
    // Do any additional setup after loading the view.
  }

  // 1
  func tableViewSelectionDidChange(notification: NSNotification) {
    // 2
    if let result = searchResultsController.selectedObjects.first as? Result {
      // 3
      result.loadIcon()
      result.loadScreenShots()
    }
  }

  @IBAction func searchClicked(sender: AnyObject!) {
    if (searchTextField.stringValue == "") {
      return
    }
    // 2

    if let resultsNumber = Int(numberResultsComboBox.stringValue) {
      // 3
      loading = true
      iTunesRequestManager.getSearchResults(searchTextField.stringValue, results: resultsNumber, langString: "en_us") { (results, error) -> Void in
        // 4
        let itunesResults = results.flatMap { $0 as? NSDictionary }
          .map { return Result(dictionary: $0) }
          .enumerate()
          .map({ (index, element) -> Result in
            element.rank = index + 1
            return element
        })
        // 5
        dispatch_async(dispatch_get_main_queue()) {
          // 6
          self.loading = false
          self.searchResultsController.content = itunesResults
          self.setColorsOnData()
        }
      }
    }
  }

  func setColorsOnData() {
    // 1
    let allResults = searchResultsController.arrangedObjects
    // 2
    let sortDescriptor = NSSortDescriptor(key: "userRatingCount", ascending: false)
    // let sortDescriptorTwo = NSSortDescriptor(key: "averageUserRating", ascending: false)
    // 3
    let sortedResults = allResults.sortedArrayUsingDescriptors([sortDescriptor]) as NSArray
    // 4
    for index in 0..<sortedResults.count {
      // 5
      let red = CGFloat(Float(index) / Float(sortedResults.count))
      let green = CGFloat(1.0 - (Float(index) / Float(sortedResults.count)))
      let color = NSColor(calibratedRed: red, green: green, blue: 0.0, alpha: 1.0)
      // 6
      if let result = sortedResults.objectAtIndex(index) as? Result {
        result.cellColor = color
      }
    }
  }

  override func controlTextDidEndEditing(obj: NSNotification) {
    // enter pressed
    searchClicked(searchTextField)
  }
}