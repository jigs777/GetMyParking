//
//  HomeVC.swift
//  GetMyParking
//
//  Created by Piyu on 22/11/20.
//

import UIKit
import MapKit

class HomeVC: UIViewController {

    var arrData = [RootRuesult](){
        didSet{
            addAnnotation()
        }
        
    }
    lazy var arrayAnnotation:[LiveTrackingAnnotation] = []

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblName: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        if kdefaults.bool(forKey: "isFirstTime"){
            getDataFromApi()
        }else{
            self.getAllDataFromCoreData()

        }
    }
    
    @IBAction func btnRefreshTapped(_ sender: UIButton) {
        DBManager.sharedDatabase.deleteAllData()
        arrayAnnotation = []
        removeAllAnnotation()
        DispatchQueue.main.async {
            self.getDataFromApi()
        }
   
    }
    
    
    @IBAction func btnarrowTapped(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextvc = storyBoard.instantiateViewController(withIdentifier: "CountryListVC") as! CountryListVC
        nextvc.delegate = self
        nextvc.arrData = self.arrData
        self.present(nextvc, animated:true, completion:nil)
    }
    
  
    func getDataFromApi(){
        
        if let url = URL(string: "https://restcountries.eu/rest/v2/all") {
           URLSession.shared.dataTask(with: url) { data, response, error in
              if let data = data {
                  do {
                     let res = try JSONDecoder().decode(Array<RootRuesult>.self, from: data)
                     DBManager.sharedDatabase.saveAllData(data: data)
                     self.getAllDataFromCoreData()
                     print(res)
                  } catch let error {
                     print(error)
                  }
               }
           }.resume()
            
            
        }
    }
    
    func getAllDataFromCoreData(){
        let db = DBManager.sharedDatabase.getAllData()
      
        if db.count > 0{
            let decoder = JSONDecoder()

            if let jsonData = try? decoder.decode(Array<RootRuesult>.self, from: db[0].data!) {
                self.arrData = jsonData
                DLog(arrData.count)
            }
        }
        
    }
    
    func removeAllAnnotation(){
        if mapView.annotations.count > 0 {
            let allAnnotations = mapView.annotations
            mapView.removeAnnotations(allAnnotations)

        }
    }
    

}

extension HomeVC {
    
    func addAnnotation(){
        arrayAnnotation = []
        removeAllAnnotation()
        if self.arrData.count > 0{
            for i in 0..<arrData.count{
                
                
                if self.arrData[i].latlng!.count > 0 {
                    let annotation = LiveTrackingAnnotation()
                    annotation.lat = self.arrData[i].latlng![0]
                    annotation.lon = self.arrData[i].latlng![1]
                    annotation.title = self.arrData[i].name ?? ""
                    annotation.name = self.arrData[i].name ?? ""
                    annotation.coordinate = CLLocationCoordinate2D(latitude: Double(self.arrData[i].latlng![0]), longitude: Double(self.arrData[i].latlng![1]))
                    arrayAnnotation.append(annotation)

                }
            }
                self.mapView.addAnnotations(self.arrayAnnotation)

        }
        
        DispatchQueue.main.async {
            let mapEdgePadding = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            var zoomRect:MKMapRect = MKMapRect.null
            
            for index in 0..<self.arrayAnnotation.count {
                let annotation = self.arrayAnnotation[index]
                let aPoint:MKMapPoint = MKMapPoint.init(annotation.coordinate)
                let rect:MKMapRect = MKMapRect.init(x: aPoint.x, y: aPoint.y, width: 0.1, height: 0.1)
                
                if (zoomRect.isNull) {
                    zoomRect = rect
                } else {
                    zoomRect = zoomRect.union(rect)
                }
            }
            self.mapView.setVisibleMapRect(zoomRect, edgePadding: mapEdgePadding, animated: false)
        }
        
        if arrayAnnotation.count > 0 {
            self.mapView.showAnnotations(arrayAnnotation, animated: true)
        }


    }
}

extension HomeVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
       
        
            
            let identifier = "pin"
            
            guard let annotation = annotation as? LiveTrackingAnnotation else {
                return nil
            }
            
            var view: CustomAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? CustomAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = CustomAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            view.lblName?.text = annotation.name ?? ""
            view.lblName?.textColor = .red
            view.imgObject?.image = UIImage(named: "marker")
            
            return view
       
    }
    
    

    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        
        if view.reuseIdentifier?.lowercased() == "pin" {
            let tempAnnotation = view.annotation as! LiveTrackingAnnotation
            let mapCamera = MKMapCamera(lookingAtCenter: tempAnnotation.coordinate, fromEyeCoordinate: tempAnnotation.coordinate, eyeAltitude: 500)
            mapView.setCamera(mapCamera, animated: false)
            
            self.mapView.selectAnnotation(tempAnnotation, animated: true)
        }
        
    }
}
extension HomeVC : HomeDetailsVCDelegate{
    func selectedCountry(selCountry: RootRuesult) {
        self.lblName.text = selCountry.name ?? ""
        
        
        let tempAnnotation = self.arrayAnnotation.filter({$0.name == selCountry.name})
        if tempAnnotation.count > 0 {
            let coordinate = CLLocationCoordinate2D(latitude: tempAnnotation[0].lat!, longitude: tempAnnotation[0].lon!)
            let mapCamera = MKMapCamera(lookingAtCenter: coordinate, fromEyeCoordinate: coordinate, eyeAltitude: 1500)
            mapView.setCamera(mapCamera, animated: false)
            self.mapView.selectAnnotation(tempAnnotation[0], animated: true)

        }
    }
    
    
    
}
