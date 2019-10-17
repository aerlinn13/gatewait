//
//  FlightsVC.swift
//  gatewait
//
//  Created by Danil on 13.10.2019.
//  Copyright © 2019 Danil Chernyshev. All rights reserved.
//

import UIKit
import RealmSwift

class FlightsVC: UIViewController, UITextFieldDelegate {
    
    lazy var realm: Realm = {
        return try! Realm()
    }()

    @IBOutlet weak var flightNumberField: UITextField!
    
    @IBAction func findGatesButton(_ sender: Any) {
        getFlight()
    }

    @IBOutlet weak var findGatesButtonOutlet: UIButton!
    
    var foundGates: Results<Gate>?

    func getFlight() {
        if let id = flightNumberField.text {
            let gates = realm.objects(Gate.self).filter("flight = '\(id)'")
            if (gates.count > 0) {
                foundGates = gates
                performSegue(withIdentifier: "openGates", sender: self)
            } else {
                print("no gates found")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "openGates") {
            let vc = segue.destination as! GatesVC
            if let gates = self.foundGates {
                vc.gates = gates
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        findGatesButtonOutlet.layer.cornerRadius = 5
        flightNumberField.textAlignment = .center
        flightNumberField.becomeFirstResponder()
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
