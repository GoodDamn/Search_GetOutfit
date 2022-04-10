//
//  RangeSlider.swift
//  GetOutfit
//
//  Created by Cell on 01.04.2022.
//

import UIKit

class RangeSlider: UIControl{
    
    private var lowerValue: CGFloat = 0.2;
    private var upperValue: CGFloat = 0.8;
    
    var minValue: Int = 0;
    var maxValue: Int = 1;
    
    var maxDecimal: CGFloat = 100{
        didSet{
            lowerValue = CGFloat(minValue)/maxDecimal;
            upperValue = CGFloat(maxValue)/maxDecimal;
            updateLayerFrames();
        }
    };
    
    var thumbImage = UIImage(systemName: "circle.fill")!;
    
    private let rangeLayer = CAShapeLayer();
    private let lowerThumb = UIImageView();
    private let lowerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 12));
    
    
    private let upperThumb = UIImageView();
    private let upperLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: 12));
    
    private var previousLocation = CGPoint();

    override var frame: CGRect{
        didSet{
            updateLayerFrames();
        }
    }
    
    private func updateLayerFrames(){
        lowerLabel.text = minValue.description;
        upperLabel.text = maxValue.description;
        
        lowerThumb.frame = CGRect(origin: thumbOriginForValue(lowerValue,0,0), size: thumbImage.size);
        lowerLabel.frame = CGRect(origin: thumbOriginForValue(lowerValue,lowerLabel.frame.width/3,20), size: lowerLabel.frame.size);
        upperThumb.frame = CGRect(origin: thumbOriginForValue(upperValue,0,0), size: thumbImage.size);
        upperLabel.frame = CGRect(origin: thumbOriginForValue(upperValue,upperLabel.frame.width/3,20), size: upperLabel.frame.size);
    }
    
    func positionForValue(_ value: CGFloat) -> CGFloat{
        return bounds.width * value;
    }
    
    private func thumbOriginForValue(_ value: CGFloat,_ offsetX:CGFloat ,_ offsetY:CGFloat) -> CGPoint{
        let x = positionForValue(value) - thumbImage.size.width / 2.0;
        return CGPoint(x: x-offsetX, y: (bounds.height - thumbImage.size.height) / 2.0 - offsetY);
    }
    
    private func setupComponents(_ label:UILabel, _ thumb:UIImageView)->Void{
        label.layer.cornerRadius = 6;
        label.layer.backgroundColor = UIColor.lightGray.cgColor;
        label.layer.masksToBounds = true;
        label.backgroundColor = .lightGray;
        label.textAlignment = .center;
        
        thumb.layer.shadowRadius = 3;
        thumb.layer.shadowColor = UIColor.black.cgColor;
        thumb.layer.shadowOpacity = 0.75;
        thumb.layer.shadowOffset = CGSize(width: 0.5, height: 0.7);
        
        addSubview(thumb);
        addSubview(label);
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        //layer.addSublayer(rangeLayer);
        
        setupComponents(lowerLabel, lowerThumb);
        setupComponents(upperLabel, upperThumb);
        
        updateLayerFrames();
    }
    
    override func draw(_ rect: CGRect) {
        
        /*let path = UIBezierPath();
        let centerHeight = bounds.height/2;
        path.move(to: CGPoint(x: 0, y: centerHeight));
        path.addLine(to: CGPoint(x: layer.frame.width, y: centerHeight));
        path.close();
        
        rangeLayer.path = path.cgPath;
        rangeLayer.strokeColor = UIColor.blue.cgColor;
        rangeLayer.lineWidth = centerHeight+2;
        rangeLayer.strokeStart = 0.5;
        rangeLayer.strokeEnd = 1.0;
        rangeLayer.lineCap = .round;*/
        let thumbLayer = CAShapeLayer();
        thumbLayer.path = UIBezierPath(arcCenter: CGPoint(x: 15, y: 15), radius: 15, startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath;
        thumbLayer.fillColor = UIColor.white.cgColor;
        
        UIGraphicsBeginImageContext(CGSize(width: 30, height: 30));
        thumbLayer.render(in: UIGraphicsGetCurrentContext()!);
        lowerThumb.image = UIGraphicsGetImageFromCurrentImageContext()!;
        upperThumb.image = UIGraphicsGetImageFromCurrentImageContext()!;
        thumbImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        
        updateLayerFrames();
    }
}

extension RangeSlider{
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self);
        
        if (lowerThumb.frame.contains(previousLocation)){
            lowerThumb.isHighlighted = true;
        } else if (upperThumb.frame.contains(previousLocation)){
            upperThumb.isHighlighted = true;
        }
        
        return lowerThumb.isHighlighted || upperThumb.isHighlighted;
    }
    
    private func boundValue(_ value:CGFloat, toLowerValue lowerValue: CGFloat, upperValue:CGFloat)->CGFloat{
        return min(max(value,lowerValue),upperValue);
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self);
        let deltaLocation = location.x - previousLocation.x;
        let deltaValue = deltaLocation/bounds.width;
        
        previousLocation = location;
        
        if lowerThumb.isHighlighted{
            lowerValue += deltaValue;
            lowerValue = boundValue(lowerValue, toLowerValue: 0, upperValue: upperValue);
            minValue = Int((lowerValue*maxDecimal).rounded());
            
            //rangeLayer.strokeStart = lowerValue;
        } else if upperThumb.isHighlighted{
            upperValue += deltaValue;
            upperValue = boundValue(upperValue, toLowerValue: lowerValue, upperValue: 1);
            maxValue = Int((upperValue*maxDecimal).rounded());
            
            //rangeLayer.strokeEnd = upperValue;
        }
        
        CATransaction.begin();
        CATransaction.setDisableActions(true);
        
        updateLayerFrames();
        
        CATransaction.commit();
        
        return true;
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        lowerThumb.isHighlighted = false;
        upperThumb.isHighlighted = false;
    }
}
