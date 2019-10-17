//
//  GatesVC.swift
//  gatewait
//
//  Created by Danil on 13.10.2019.
//  Copyright © 2019 Danil Chernyshev. All rights reserved.
//

import UIKit
import RealmSwift

class GatesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var flightName: UILabel!
    
    @IBOutlet weak var mainGate: UILabel!
    
    @IBOutlet weak var gatesTableView: UITableView!
    
    var gates: Results<Gate>?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gates!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GateTableViewCell") as! GateTableViewCell
        if let text = gates?[indexPath.row].id {
            cell.gateLabel.text = text.replacingOccurrences(of: "*", with: "")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let gate = gates?[0] {
            self.mainGate.text = gate.id.replacingOccurrences(of: "*", with: "")
            self.flightName.text = gate.flight
        }
        gatesTableView.register(UINib(nibName: "GateTableViewCell", bundle: nil), forCellReuseIdentifier: "GateTableViewCell")

        
        // Do any additional setup after loading the view.
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
