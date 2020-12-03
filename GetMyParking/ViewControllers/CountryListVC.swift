//
//  CountryListVC.swift
//  GetMyParking
//
//  Created by Piyu on 22/11/20.
//

import UIKit

class tblCustomCell: UITableViewCell {

    @IBOutlet var lblName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
protocol HomeDetailsVCDelegate {
    func selectedCountry(selCountry:RootRuesult)
}
class CountryListVC: UIViewController {
    var arrData = [RootRuesult]()
    @IBOutlet var tableview: UITableView!
    var delegate: HomeDetailsVCDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.reloadData()
        // Do any additional setup after loading the view.
    }
    

   

}
// MARK:- Extension: UITableViewDataSource

extension CountryListVC : UITableViewDataSource , UITableViewDelegate {
    
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrData.count
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        return cellName(tableView, indexPath,objectdata: (arrData[indexPath.row]))

        
    }
    
    

    func cellName( _ tableView : UITableView, _ indexPath : IndexPath,objectdata:RootRuesult) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tblCustomCell") as! tblCustomCell
        cell.lblName.text = objectdata.name ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if delegate != nil{
            self.delegate?.selectedCountry(selCountry: arrData[indexPath.row])
            self.dismiss(animated: true, completion: nil)
        }

    }
    
    
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
   
    
    
}
