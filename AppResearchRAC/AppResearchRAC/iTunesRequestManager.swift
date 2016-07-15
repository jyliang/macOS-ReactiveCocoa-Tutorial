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

struct iTunesRequestManager {
  static func getSearchResults(query: String, results: Int, langString: String, completionHandler: (NSArray, NSError?) -> Void) {
    let urlComponents = NSURLComponents(string: "https://itunes.apple.com/search")
    let termQueryItem = NSURLQueryItem(name: "term", value: query)
    let limitQueryItem = NSURLQueryItem(name: "limit", value: "\(results)")
    let mediaQueryItem = NSURLQueryItem(name: "media", value: "software")
    urlComponents?.queryItems = [termQueryItem, mediaQueryItem, limitQueryItem]

    guard let url = urlComponents?.URL else {
      return
    }

    let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
      do {
        let itunesData = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
        if let results = itunesData["results"] as? NSArray {
          completionHandler(results, nil)
        } else {
          completionHandler([], nil)
        }
      } catch _ {
        completionHandler([], error)
      }

    })
    task.resume()
  }

  static func downloadImage(imageURL: NSURL, completionHandler: (NSImage?, NSError?) -> Void) {
    let task = NSURLSession.sharedSession().dataTaskWithURL(imageURL, completionHandler: { (data, response, error) -> Void in
      guard let data = data where error == nil else {
        completionHandler(nil, error)
        return
      }
      let image = NSImage(data: data)
      completionHandler(image, nil)
    })
    task.resume()
  }
}