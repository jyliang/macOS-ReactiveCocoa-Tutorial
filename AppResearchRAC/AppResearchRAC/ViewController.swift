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
import ReactiveCocoa
import Result

class ViewController: NSViewController, NSTextFieldDelegate {

  @IBOutlet weak var searchResultsTableView: NSTableView!
  @IBOutlet var searchResultsController: NSArrayController!
  @IBOutlet weak var numberResultsComboBox: NSComboBox!
  @IBOutlet weak var collectionView: NSCollectionView!
  @IBOutlet weak var searchTextField: NSTextField!
  @IBOutlet weak var searchButton: NSButton!

  lazy var viewModel = ViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()

    bindSignals()
    registerCollectionViewItemPrototype()
  }

  // MARK: Private
  private func registerCollectionViewItemPrototype() {
    let itemPrototype = self.storyboard?.instantiateControllerWithIdentifier("collectionViewItem")
    as! NSCollectionViewItem
    collectionView.itemPrototype = itemPrototype
  }

  private func bindSignals() {
    bindTextFieldSignals()
    bindComboBoxSignals()
    bindSearchResultAndSelection()
    self.searchButton.rac_command = viewModel.searchCommand;
  }

  private func bindTextFieldSignals() {
    self.searchTextField.rac_textSignal().toSignalProducer()
      .map { stringValue in stringValue as! String }
      .startWithNext {
        [weak self]
        (search) in
        guard let s = self else { return }

        s.viewModel.searchTerm.value = search;
    }

    self.viewModel.searchEnabled.producer.startWithNext {
      [weak self]
      (enabled) in
      guard let s = self else { return }
      s.searchButton.enabled = enabled
    }
  }

  private func bindComboBoxSignals() {

    // Two events to trigger combobox value change
    // 1. Direct text change
    self.numberResultsComboBox.rac_textSignal().toSignalProducer().startWithNext {
      [weak self]
      (stringValue) in
      guard let s = self else {
        return
      }
      if let stringValue2 = stringValue as? String,
        count = Int(stringValue2) {
          s.viewModel.searchCount.value = count
      }
    }

    // 2. Combobox selection change
    self.numberResultsComboBox.rac_selectionChangeSignal().toSignalProducer().startWithNext {
      [weak self]
      (indexValue) in
      guard let s = self else {
        return
      }
      if let indexValue = indexValue as? NSNumber {
        let index = Int(indexValue)
        let comboBoxInfo = [5, 10, 25, 50, 100, 200]
        guard index < comboBoxInfo.count && index >= 0 else {
          return;
        }
        s.viewModel.searchCount.value = comboBoxInfo[index]
      }
    }
  }

  private func bindSearchResultAndSelection() {
    viewModel.itunesResults.producer.startWithNext {
      [weak self]
      (results) in
      dispatch_async(dispatch_get_main_queue()) {
        self?.searchResultsController.content = results
      }
    }

    searchResultsController
      .rac_valuesAndChangesForKeyPath("selection", options: [.Initial, .New], observer: self)
      .subscribeNext({
        [weak self]
        _ in
        guard let s = self else {
          return
        }
        s.viewModel.currentSelectionIndex.value = s.searchResultsController.selectionIndex
    })
  }
}
