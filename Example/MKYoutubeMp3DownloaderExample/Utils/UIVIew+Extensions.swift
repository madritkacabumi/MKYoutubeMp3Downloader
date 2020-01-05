//
//  UIVIew+Extensions.swift
//

import UIKit

extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
    public static func instanceFromNib(name:String, fromBundle bundle : Bundle? = Bundle.main) -> UIView {
        return UINib(nibName: name, bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
    }
    
    public func clearAllSuBViews(){
        for view in self.subviews{
            view.removeFromSuperview()
        }
    }
    
    // convert view into image
    public func toImage() -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        guard let context = UIGraphicsGetCurrentContext()
            else {
                return UIImage()
        }
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    // loop recursively through views and get an array
    public func subviewsRecursive() -> [UIView] {
        
        return subviews + subviews.flatMap { $0.subviewsRecursive() }
    }
    
    public func applyGradient(colours: [UIColor], locations: [NSNumber]?, startPoint : CGPoint?, endPoint : CGPoint?) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        if(startPoint != nil && endPoint != nil){
            gradient.startPoint = startPoint!
            gradient.endPoint = endPoint!
        }
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.addSublayer(gradient)
        
        return gradient
    }
    
    // hiding keyboard when tapped around
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        endEditing(false)
    }
    
    public func asCircle(){
        self.layer.cornerRadius = self.frame.width / 2;
        self.layer.masksToBounds = true
    }
    
    static public func createView<T : UIView>(fromBundle bundle : Bundle? = Bundle.main) -> T?{
        let popup = UIView.instanceFromNib(name: String(describing: T.self), fromBundle: bundle) as? T
        return popup
    }
    
    //create round corners at direction
    func roundCorners(corners: CACornerMask, radius: CGFloat) {
        clipsToBounds = true
        layer.cornerRadius = radius
        if #available(iOS 11.0, *) {
            layer.maskedCorners = corners
        } else {
            // Fallback on earlier versions
        }
    }
    
    public func attachTo(view : UIView){
        
        view.addSubview(self)
        // self.frame = view.bounds
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: self.superview!.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: self.superview!.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: self.superview!.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: self.superview!.trailingAnchor, constant: 0).isActive = true
    }
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

