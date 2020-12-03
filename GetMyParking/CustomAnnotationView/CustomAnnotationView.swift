//
//  GetMyParking
//
//  Created by Piyu on 22/11/20.


import MapKit

class CustomAnnotationView: MKAnnotationView {
    
    @IBOutlet weak var containerView : UIView?
    @IBOutlet weak var contentView : UIView?
    @IBOutlet weak var imgObject : UIImageView?
    @IBOutlet weak var lblName : UILabel?
    @IBOutlet weak var viewAnnotation : UIView?

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
       // self.setup()
    }
    
    
    func setup() {
        
        guard let nibView = loadViewFromNib() else {
            return
        }
        
        self.contentView = nibView
        nibView.frame = CGRect(x: 0, y: 0, width: 150, height: 100)
        bounds = nibView.frame
        addSubview(nibView)

    }
    
    func loadViewFromNib() -> UIView! {
        let bundle = Bundle(for: type(of: self))
        let name =  "CustomAnnotationView"
        let nib = UINib(nibName: name, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    override func prepareForReuse() {
        super.layoutSubviews()
    }
   
    
}



