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
import StoreKit

class GatesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var flightNameLabel: UILabel!
    @IBOutlet weak var mainGateLabel: UILabel!
    @IBOutlet weak var mainGateAmountLabel: UILabel!
    @IBOutlet weak var ReloadButtonOutlet: UIButton!
    @IBAction func ReloadButton(_ sender: Any) {
        self.getLiveData(tomorrow: false)
    }
    @IBOutlet weak var flightSign: UIImageView!
    @IBOutlet weak var flightAmount: UILabel!
    
    @IBAction func closeButton(_ sender: Any) {
        if willShowReview {
            SKStoreReviewController.requestReview()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var gatesTableView: UITableView!
    @IBOutlet weak var dataSourceLabel: UILabel!
    @IBOutlet weak var mainGateBackgroundView: UIImageView!
    
    lazy var realm: Realm = {
        return try! Realm()
    }()
    
    var gates: Array<Gate>?
    var mainGate: Gate?
    var flightsTotal = 0
    var flightId: String?
    var loading = false
    var willShowReview = false
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gates!.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GateTableViewCell") as! GateTableViewCell
        cell.selectionStyle = .none
        let authorCell = tableView.dequeueReusableCell(withIdentifier: "AuthorTableViewCell") as! AuthorTableViewCell
        authorCell.selectionStyle = .none
        if indexPath.row == gates!.count { return authorCell }

        if let gate = gates?[indexPath.row] {
            cell.gateLabel.text = gate.id.replacingOccurrences(of: "*", with: "")
            let percentage = Double(gate.amount) / Double(self.flightsTotal) * 100
            cell.flightsAmount.text = String(Int(percentage.rounded())) + "%"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == gates!.count {
            let subject = "Inquiry"
            let coded = "mailto:daniel@lindir.co.uk?subject=\(subject)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

            if let emailURL: NSURL = NSURL(string: coded!) {
                if UIApplication.shared.canOpenURL(emailURL as URL) {
                    UIApplication.shared.openURL(emailURL as URL)
                }
            }
        }
    }
    
    func getLiveData(tomorrow: Bool) {
        if loading {
            return
        }
        loading = true
        
        DispatchQueue.main.async {
            if !tomorrow {
                self.ReloadButtonOutlet.rotateView()
            }
        self.switchToParsingMode()
        }

        let airline = flightId!.letters
        let flightCode = flightId!.digits
        let date = Date()

        if tomorrow {
            let tomorrowDate = Calendar.current.date(byAdding: .day, value: 1, to: date)
            getGates(airline: airline, flightCode: flightCode, date: tomorrowDate!)
        } else {
            getGates(airline: airline, flightCode: flightCode, date: date)
        }
        
        
    }
    
    func getGates(airline: String, flightCode: String, date: Date) {
        print(date)
        let year = String(date.year)
        let month = String(date.month)
        let day = String(date.day)
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(5)
        configuration.timeoutIntervalForResource = TimeInterval(5)
        let session = URLSession(configuration: configuration)
        let url = URL(string: "https://www.flightstats.com/v2/api-next/flight-tracker/" + airline + "/" + flightCode + "/" + year + "/" + month + "/" + day)!
        let task = session.dataTask(with: url, completionHandler: { data, response, error in
            if (error != nil) {
                self.switchToHistoricalMode()
                return
            }
            if let json = try? JSONSerialization.jsonObject(with: data!, options: []) {
                if let dictionary = json as? [String: Any] {
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
                            } else {
                                self.loading = false
                                self.getLiveData(tomorrow: true)
                            }
                        } else {
                            self.switchToHistoricalMode()
                        }
                    } else {
                        self.switchToHistoricalMode()
                    }
                } else {
                    self.switchToHistoricalMode()
                }
            } else {
                self.switchToHistoricalMode()
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
                Loaf("Gate not available", state: .custom(.init(backgroundColor: .black, font: UIFont(name: "Graphein Pro", size: 18.0)!, icon: nil, textAlignment: .center)), location: .bottom,  presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show(.custom(2.75))
            })
            self.loading = false
        }
    }
    
    func switchToLiveMode(_ gateNumber: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            UIView.transition(with: self.mainGateBackgroundView, duration: 0.75, options: .transitionCrossDissolve, animations: {
                self.mainGateBackgroundView.image = UIImage(named: "live_background")
            }, completion: nil)
            
            UIView.transition(with: self.dataSourceLabel, duration: 0.75, options: .transitionCrossDissolve, animations: {
                self.dataSourceLabel.text = "Connected to \(self.mainGate!.airport)"
                self.dataSourceLabel.textColor = UIColor(rgb: 0x5AD042)
                self.dataSourceLabel.backgroundColor = UIColor(rgb: 0x90FF7A)
            }, completion: nil)
            
            UIView.transition(with: self.flightSign, duration: 1.25, options: .transitionCrossDissolve, animations: {
                self.flightSign.isHidden = true
            }, completion: nil)
            
            UIView.transition(with: self.flightAmount, duration: 1.25, options: .transitionCrossDissolve, animations: {
                self.flightAmount.isHidden = true
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
        self.flightsTotal = Array<Gate>(foundGates).map({$0.amount}).reduce(0, +)
        self.mainGateLabel.text = mainGate!.id.replacingOccurrences(of: "*", with: "")
        let percentage = Double(mainGate!.amount) / Double(self.flightsTotal) * 100
        if Int(percentage.rounded()) > 60 {
            self.willShowReview = true
        }
        mainGateAmountLabel.text = String(Int(percentage.rounded())) + "%"
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
        self.gatesTableView.backgroundColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setGates()
        gatesTableView.register(UINib(nibName: "GateTableViewCell", bundle: nil), forCellReuseIdentifier: "GateTableViewCell")
        gatesTableView.register(UINib(nibName: "AuthorTableViewCell", bundle: nil), forCellReuseIdentifier: "AuthorTableViewCell")
        decorateScreen()
        getLiveData(tomorrow: false)
    }
}
