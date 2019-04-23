//
//  PayoutViewController.swift
//  feedthebot
//
//  Created by d. nye on 4/11/19.
//  Copyright © 2019 Mobile Flow LLC. All rights reserved.
//

import UIKit


class MFPayoutCell : UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var trainingType: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func populate(_ activityObj :MFActivity) {
        let icon_image = activityObj.getImage()
        let type = activityObj.trainingType.detail().capitalized
        let earnings = activityObj.earnings
        let date_string : String = activityObj.updatedAt.description
        
        icon.image = icon_image
        trainingType.text = type
        let price = String(format: "%.2f", earnings)
        amount.text = "$\(price)"
        dateLabel.text = date_string
    }
    
    func setBackground(_ row: Int) {
        self.backgroundColor = MFDarkBlue()
        trainingType.textColor = .white
        amount.textColor = .white
    }

}

class PayoutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBAction func doDoneButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func doPayoutButton(_ sender: Any) {

    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var activityList = [MFActivity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let testActivities = UserManager.sharedInstance.getTestActivity(12)
        activityList.append(contentsOf: testActivities)

        let points :Int = activityList.map({ $0.points }).reduce(0, +)
        let exchangeRate = UserManager.sharedInstance.getUserDetails().exchangeRate
        let earnings :Double = Double(points) * exchangeRate
        let price = String(format: "$%.2f", earnings)
        titleLabel.text = price
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
    }
    

    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let section_count = 1
        return section_count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let row_count = activityList.count
        return row_count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MFPayoutCell", for: indexPath) as! MFPayoutCell
        let activityObj = activityList[indexPath.row]
        cell.populate(activityObj)
        cell.setBackground(indexPath.row)
        return cell
    }

    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
