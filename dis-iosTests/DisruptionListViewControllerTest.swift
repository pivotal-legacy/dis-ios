import XCTest
import Nimble
import SwiftyJSON
@testable import dis_ios

class DisruptionListViewControllerTest: XCTestCase {
    
    class StubDisruptionServiceSuccess: DisruptionServiceProtocol {
        func getDisruptions(completion: (result: Result<[Disruption]>) -> Void) {
            completion(result: .Success([
                Disruption(json: JSON(["line": "Northern", "status": "404 train not found", "startTime": "12:25", "endTime": "12:55","startTimestamp": 1458217500000, "endTimestamp": 1458219300000, "earliestEndTime": "12:45", "latestEndTime": "13:15", "earliestEndTimestamp": 1458218700000, "latestEndTimestamp":1458220500000]))!,
                Disruption(json: JSON(["line": "Jubilee", "status": "Regicide imminent", "startTime": "12:50", "endTime": "13:10","startTimestamp": 1458219000000, "endTimestamp": 1458220200000, "earliestEndTime": "13:00", "latestEndTime": "13:30", "earliestEndTimestamp": 1458219600000, "latestEndTimestamp":1458221400000]))!,
                Disruption(json: JSON(["line": "Hammersmith & City", "status": "Lost to the Gunners", "startTime": "13:05", "endTime": "13:45","startTimestamp": 1458219900000, "endTimestamp": 1458222300000, "earliestEndTime": "13:30", "latestEndTime": "14:00", "earliestEndTimestamp": 1458221400000, "latestEndTimestamp":1458223200000]))!
            ]))
        }
    }
    
    class StubDisruptionServiceSuccessNoDisruptions: DisruptionServiceProtocol {
        func getDisruptions(completion: (result: Result<[Disruption]>) -> Void) {
            completion(result: .Success([]))
        }
    }
    
    class StubDisruptionServiceNetworkError: DisruptionServiceProtocol {
        func getDisruptions(completion: (result: Result<[Disruption]>) -> Void) {
            completion(result: .HTTPError(message: "Couldn't retrieve data from server 💩"))
        }
    }
    
    var viewController: DisruptionListViewController!
    
    override func setUp() {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        viewController = storyboard.instantiateInitialViewController() as! DisruptionListViewController
        
        let _ = viewController.view
    }
    
    func testDisruptionsAreRefreshedWhenAppEntersForeground() {
        viewController.disruptionsService = StubDisruptionServiceSuccess()
        viewController.notificationCenter.postNotificationName(UIApplicationWillEnterForegroundNotification, object: nil)
                
        expect(self.viewController.tableView.numberOfRowsInSection(0)).to(equal(3))
    }
    
    func testTableBackgroundViewIsNilWhenDisruptionsAreReturned() {
        viewController.disruptionsService = StubDisruptionServiceSuccess()
        viewController.viewWillAppear(false)
        expect(self.viewController.tableView.backgroundView).to(beNil())
    }
    
    func testTableViewDataSourceRespondsCorrectlyWhenDisruptionsAreReturned() {
        viewController.disruptionsService = StubDisruptionServiceSuccess()
        viewController.viewWillAppear(false)
        
        expect(self.viewController.tableView.numberOfRowsInSection(0)).to(equal(3))

        let cell0 = self.viewController.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! DisruptionCell
        expect(cell0.lineNameLabel?.text).to(equal("Northern"))
        expect(cell0.statusLabel?.text).to(equal("404 train not found"))

        expect(cell0.startTimeLabel?.text).to(equal("12:25 PM"))
        expect(cell0.earliestEndTimeLabel?.text).to(equal("12:45 PM"))
        expect(cell0.latestEndTimeLabel?.text).to(equal("1:15 PM"))
        
        let cell1 = self.viewController.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! DisruptionCell
        expect(cell1.lineNameLabel?.text).to(equal("Jubilee"))
        expect(cell1.statusLabel?.text).to(equal("Regicide imminent"))
        expect(cell1.startTimeLabel?.text).to(equal("12:50 PM"))
        expect(cell1.earliestEndTimeLabel?.text).to(equal("1:00 PM"))
        expect(cell1.latestEndTimeLabel?.text).to(equal("1:30 PM"))
        
        let cell2 = self.viewController.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as! DisruptionCell
        expect(cell2.lineNameLabel?.text).to(equal("Hammersmith & City"))
        expect(cell2.statusLabel?.text).to(equal("Lost to the Gunners"))
        expect(cell2.startTimeLabel?.text).to(equal("1:05 PM"))
        expect(cell2.earliestEndTimeLabel?.text).to(equal("1:30 PM"))
        expect(cell2.latestEndTimeLabel?.text).to(equal("2:00 PM"))
        
    }
    
    func testTableBackgroundViewHasMessageWhenThereAreNoDisruptions() {
        viewController.disruptionsService = StubDisruptionServiceSuccessNoDisruptions()
        viewController.viewWillAppear(false)
        expect(self.viewController.tableView.backgroundView).to(beAKindOf(UIView.self))
        expect(self.viewController.errorViewLabel.text).to(equal("No Disruptions"))
    }
    
    func testTableRemovesRowsWhenTheServerReturnsNoDisruptions() {
        viewController.disruptionsService = StubDisruptionServiceSuccess()
        viewController.viewWillAppear(false)
        
        expect(self.viewController.tableView.numberOfRowsInSection(0)).to(equal(3))
        
        viewController.disruptionsService = StubDisruptionServiceSuccessNoDisruptions()
        viewController.viewWillAppear(false)
        expect(self.viewController.tableView.numberOfRowsInSection(0)).to(equal(0))
    }
    
    func testTableBackgroundViewHasMessageWhenAnErrorIsReturned() {
        viewController.disruptionsService = StubDisruptionServiceNetworkError()
        viewController.viewWillAppear(false)
        expect(self.viewController.tableView.backgroundView).to(beAKindOf(UIView.self))
        expect(self.viewController.errorViewLabel.text).to(equal("Couldn't retrieve data from server 💩"))
    }
    
    func testRefreshControllerEndsRefreshingWhenViewDisappears() {
        self.viewController.refreshControl!.beginRefreshing()
        
        viewController.viewWillDisappear(false)
        expect(self.viewController.refreshControl?.refreshing).to(beFalse())
    }

}
