import UIKit

class DisruptionCell: UITableViewCell {

    @IBOutlet weak var lineNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var earliestEndTimeLabel: UILabel!
    @IBOutlet weak var latestEndTimeLabel: UILabel!
    @IBOutlet weak var leftBorder: UIView!
    
    override func awakeFromNib() {
        userInteractionEnabled = false
    }
}
