# JLUsefulTools

[![CI Status](https://img.shields.io/travis/EzioChen/JLUsefulTools.svg?style=flat)](https://travis-ci.com/EzioChen/JLUsefulTools)
[![Version](https://img.shields.io/cocoapods/v/JLUsefulTools.svg?style=flat)](https://cocoapods.org/pods/JLUsefulTools)
[![License](https://img.shields.io/cocoapods/l/JLUsefulTools.svg?style=flat)](https://cocoapods.org/pods/JLUsefulTools)
[![Platform](https://img.shields.io/cocoapods/p/JLUsefulTools.svg?style=flat)](https://cocoapods.org/pods/JLUsefulTools)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

JLUsefulTools is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'JLUsefulTools'
```

## Author

EzioChen, jackenwind@163.com

## License

JLUsefulTools is available under the MIT license. See the LICENSE file for more info.

## Simple Code

To convert data 

```
import UIKit
import JLUsefulTools

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let dataArr:[UInt8] = [0x01,0x02,0x03,0x04]
        let data = Data(bytes: dataArr, count: 4)
        
        ECPrintInfo("dataL\(data.eHex)", self, "\(#function)", #line)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
        
```
