//
//  PatientHealthRecord.swift
//  Hajj Dynamics
//
//  Created by Essa AlOwayyid on 03/08/2018.
//  Copyright © 2018 Essa AlOwayyid. All rights reserved.
//

import Foundation
import UIKit

class PatientHealthRecordViewController: UITableViewController  {
    
    @IBOutlet weak var dismissClicked: UIBarButtonItem!
    
    @IBAction func closeClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}




