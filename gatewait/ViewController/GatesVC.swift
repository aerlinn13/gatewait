//
//  GatesVC.swift
//  gatewait
//
//  Created by Danil on 13.10.2019.
//  Copyright © 2019 Danil Chernyshev. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON
import Loaf

class GatesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var flightNameLabel: UILabel!
    @IBOutlet weak var mainGateLabel: UILabel!
    @IBOutlet weak var mainGateAmountLabel: UILabel!
    @IBOutlet weak var mainGateAmountStack: UIStackView!
    @IBOutlet weak var ReloadButtonOutlet: UIButton!
    @IBAction func ReloadButton(_ sender: Any) {
        self.getLiveData()
    }
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var gatesTableView: UITableView!
    @IBOutlet weak var dataSourceLabel: UILabel!
    @IBOutlet weak var mainGateBackgroundView: UIImageView!
    
    
    
    var gates: Array<Gate>?
    var mainGate: Gate?
    lazy var realm: Realm = {
        return try! Realm()
    }()
    var flightId: String?
    var loading = false
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gates!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GateTableViewCell") as! GateTableViewCell
        if let gate = gates?[indexPath.row] {
            cell.gateLabel.text = gate.id.replacingOccurrences(of: "*", with: "")
            cell.flightsAmount.text = String(gate.amount)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func getLiveData() {
        if loading {
            return
        }
        loading = true

        self.ReloadButtonOutlet.rotateView()
        self.switchToParsingMode()

        let session = URLSession.shared
        let date = Date()
        let airline = flightId!.letters
        let flightCode = flightId!.digits
        let year = String(date.year)
        let month = String(date.month)
        let day = String(date.day)
        
        let url = URL(string: "https://www.flightstats.com/v2/api-next/flight-tracker/" + airline + "/" + flightCode + "/" + year + "/" + month + "/" + day)!
        let task = session.dataTask(with: url, completionHandler: { data, response, error in
            if (error != nil) {
                self.switchToHistoricalMode()
            }
            if let json = try? JSONSerialization.jsonObject(with: data!, options: []) {
                if let dictionary = json as? [String: Any] {
                    print(dictionary)
                    if let data = dictionary["data"] as? [String: Any] {
                        if let isLanded = data["isLanded"] as? Int {
                            if isLanded == 0 {
                                 if let airport = data["departureAirport"] as? [String: Any] {
                                    if let gate = airport["gate"] as? String {
                                        self.switchToLiveMode(gate)
                                    } else {
                                        self.switchToHistoricalMode()
                                    }
                        }
                            }
                }
                    } else {
                        self.switchToHistoricalMode()
                    }
                }
            }
        })
        task.resume()
    }
    
    func switchToParsingMode() {
        DispatchQueue.main.async {
            
            UIView.transition(with: self.dataSourceLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.dataSourceLabel.text = "Connecting to \(self.mainGate!.airport)"
            }, completion: nil)
        }
    }
    
    func switchToHistoricalMode() {
        DispatchQueue.main.async {
            UIView.transition(with: self.dataSourceLabel, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.dataSourceLabel.text = "Historical data"
                self.dataSourceLabel.textColor = UIColor(rgb: 0xFEB901)
                self.dataSourceLabel.backgroundColor = UIColor(rgb: 0xFFD86E)
            }, completion: { finished in
                self.ReloadButtonOutlet.layer.removeAllAnimations()
                Loaf("Gate not available", state: .custom(.init(backgroundColor: .black, font: UIFont(name: "Myriad Pro", size: 18.0)!, icon: nil, textAlignment: .center)), location: .bottom,  presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(2.75))
            })
            self.loading = false
        }
    }
    
    func switchToLiveMode(_ gateNumber: String) {
        print(gateNumber)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            UIView.transition(with: self.mainGateBackgroundView, duration: 0.75, options: .transitionCrossDissolve, animations: {
                self.mainGateBackgroundView.image = UIImage(named: "live_background")
            }, completion: nil)
            
            UIView.transition(with: self.dataSourceLabel, duration: 0.75, options: .transitionCrossDissolve, animations: {
                self.dataSourceLabel.text = "Connected to \(self.mainGate!.airport)"
                self.dataSourceLabel.textColor = UIColor(rgb: 0x5AD042)
                self.dataSourceLabel.backgroundColor = UIColor(rgb: 0x90FF7A)
            }, completion: nil)
            
            UIView.transition(with: self.mainGateAmountStack, duration: 1.25, options: .transitionCrossDissolve, animations: {
                self.mainGateAmountStack.isHidden = true
            }, completion: nil)
            
            self.mainGateLabel.text = gateNumber
            DispatchQueue.main.async {
            self.ReloadButtonOutlet.layer.removeAllAnimations()
            self.loading = false
            }
            
        }
    }
    
    func setGates() {
        var foundGates = Array<Gate>(gates!)
        foundGates = foundGates.sorted(by: { $0.amount > $1.amount })
        mainGate = foundGates[0]
        self.mainGateLabel.text = mainGate!.id.replacingOccurrences(of: "*", with: "")
        self.mainGateAmountLabel.text = String(mainGate!.amount)
        var flightName = mainGate!.flight
        let flight = realm.objects(Flight.self).filter("id = '\(mainGate!.flight)'")
        if flight.count > 0 {
            flightId = flightName
            flightName = flightName + " " + flight[0].airline
        }
        flightNameLabel.text = flightName
        foundGates.removeFirst()
        gates = foundGates
    }
    
    func decorateScreen() {
        dataSourceLabel.layer.cornerRadius = 5
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        gatesTableView.register(UINib(nibName: "GateTableViewCell", bundle: nil), forCellReuseIdentifier: "GateTableViewCell")
        setGates()
        decorateScreen()
        getLiveData()
        
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
