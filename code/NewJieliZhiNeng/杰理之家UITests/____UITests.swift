//___FILEHEADER___

import XCTest
import Foundation

class ___FILEBASENAMEASIDENTIFIER___: XCTestCase {
    var timer:Timer? = nil
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        if app.tabBars.buttons["设备"].waitForExistence(timeout: 10) {
            app.tabBars.buttons["设备"].tap()
        }
        
        if app.buttons["device_paired_finish"].waitForExistence(timeout: 100) {
            print("finish")
            app.buttons["device_paired_finish"].tap()
        }
        
        app.tabBars.buttons["多媒体"].tap()
        let collections = app.collectionViews.firstMatch
        let cell = collections.cells.element(boundBy: 0)
        if collections.scrollToElement(element: cell, isAutoStop: true) {
            cell.tap()
        }
        


    
        timer = Timer.init(timeInterval: 10, target: self, selector: #selector(actionTap), userInfo: nil, repeats: true)
        timer!.fire()
        
        if  app.wait(for: .notRunning, timeout: 1000) {
            print(app.debugDescription)
        }
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    
    @objc func actionTap(){
        let app = XCUIApplication()
        let elements = app.tables.firstMatch
        let count:Int = elements.cells.count-1;
        let k = arc4random_uniform(UInt32(count))
        let cell = elements.cells.element(boundBy: Int(k))
        if elements.scrollToElement(element: cell, isAutoStop: true) {
            cell.tap()
        }
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
           try! self.testExample()
        }
    }
}


extension XCUIElement{
    func scrollToElement(element:XCUIElement,isAutoStop:Bool = true) -> Bool {
        if self.elementType != .collectionView {
            return false
        }
        while !element.isHittable {
            if isAutoStop {
                let lastElement = self.cells.element(boundBy: self.cells.count - 1)
                if lastElement.isHittable {
                    return false
                }
            }
            self.swipeUp()
        }
        return true
    }
}
