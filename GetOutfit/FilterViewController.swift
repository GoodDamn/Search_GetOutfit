//
//  FilterViewController.swift
//  GetOutfit
//
//  Created by Cell on 29.03.2022.
//

import UIKit;

class FilterViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    private let userDef:UserDefaults = UserDefaults();
    
    private let colorsString:[String] = ["Красный","Черный","Синий","Желтый","Серый","Оранжевый","Розовый","Зеленый","Фиолетовый","Белый","Коричневый"];
    
    private var selectedColors:[String]? = nil;
    
    private let colors:[UIColor] = [UIColor.red,UIColor.black,UIColor.blue,UIColor.yellow,UIColor.gray,UIColor.orange,UIColor.systemPink,UIColor.green,UIColor.purple,UIColor.white,UIColor.brown];
    
    public var didQuit:((String, [String]?, String, [Int], [Int], [String])->Void)?
    
    @IBOutlet weak var tf_limit: UITextField!;
    @IBOutlet weak var collectionV_colors: UICollectionView!;
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!;
    @IBOutlet weak var segmentControlGender: UISegmentedControl!;
    @IBOutlet weak var segmentControlSort: UISegmentedControl!;
    @IBOutlet weak var segmentControlAsc: UISegmentedControl!;
    private let rangeSliderPrice = RangeSlider(frame: .zero),
                rangeSliderSize = RangeSlider(frame: .zero);
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionV_colors.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as! ColorCell;
        cell.contentView.backgroundColor = colors[indexPath.row];
        cell.layer.cornerRadius = 10;
        
        if(selectedColors!.contains(colorsString[indexPath.row])){
            cell.checkMark.isHidden = false;
        }
        
        if (indexPath.row == colors.count-1) {
            collectionHeight.constant = collectionV_colors.contentSize.height;
        }
        
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let checkMark = (collectionView.cellForItem(at: indexPath) as? ColorCell)?.checkMark;
        if !checkMark!.isHidden {
            checkMark!.isHidden = true;
            let index = selectedColors!.firstIndex(of: colorsString[indexPath.row]);
            selectedColors?.remove(at: index!);
        } else{
            checkMark!.isHidden = false;
            selectedColors?.append(colorsString[indexPath.row]);
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        didQuit?(tf_limit.text!, // 1
                 selectedColors, // 2
                 segmentControlGender.titleForSegment(at:  segmentControlGender.selectedSegmentIndex)!, // 3
                 [rangeSliderPrice.minValue, rangeSliderPrice.maxValue], // 4
            [rangeSliderSize.minValue, rangeSliderSize.maxValue],// 5
            [segmentControlSort.titleForSegment(at: segmentControlSort.selectedSegmentIndex)!,
             segmentControlAsc.selectedSegmentIndex == 0 ? "asc":"desc"]/*6*/);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        selectedColors = userDef.value(forKey: "colors") as? [String] ?? [];
        
        collectionV_colors.dataSource = self;
        collectionV_colors.delegate = self;
        
        if let gen = userDef.string(forKey: "gender"){
            segmentControlGender.selectedSegmentIndex = (gen == "female" ? 0 : 1);
        }
        
        tf_limit.text = userDef.string(forKey: "limit") ?? "10";
        
        let segments = ["name", "price","size","color"];
        
        if let ord = userDef.value(forKey: "order") as? [String]{
            segmentControlSort.selectedSegmentIndex = segments.firstIndex(of: ord[0]) ?? 0;
            segmentControlAsc.selectedSegmentIndex = (ord[1] == "asc" ? 0:1);
        }
        
        rangeSliderPrice.layer.backgroundColor = UIColor.gray.cgColor;
        rangeSliderPrice.layer.cornerRadius = 8;
        view.addSubview(rangeSliderPrice);
        
        rangeSliderSize.layer.backgroundColor = UIColor.gray.cgColor;
        rangeSliderSize.layer.cornerRadius = 8;
        view.addSubview(rangeSliderSize);
        
        let prices = userDef.value(forKey: "prices") as? [Int] ?? [0,600_000];
        setValuesToRangeSlider(to: rangeSliderPrice, lower: prices[0], upper: prices[1], maxDecimal: 600_000);
        let sizes = userDef.value(forKey: "sizes") as? [Int] ?? [1,70];
        setValuesToRangeSlider(to: rangeSliderSize, lower: sizes[0], upper: sizes[1], maxDecimal: 70);
    }
    
    private func setValuesToRangeSlider(to slider:RangeSlider, lower:Int, upper:Int, maxDecimal:CGFloat){
        slider.maxDecimal = maxDecimal;
        slider.minValue = lower;
        slider.maxValue = upper;
        slider.lowerValue = CGFloat(lower) / maxDecimal;
        slider.upperValue = CGFloat(upper) / maxDecimal;
    }
    
    private func setPostionToRangeSlider(with slider:RangeSlider, offsetY:CGFloat)->Void{
        slider.frame = CGRect(x: 0, y: 0, width: view.bounds.width - 75, height: 8);
        slider.center = CGPoint(x: view.center.x, y: view.center.y+offsetY);
    }
    
    override func viewDidLayoutSubviews() {
        setPostionToRangeSlider(with: rangeSliderPrice, offsetY: 60);
        setPostionToRangeSlider(with: rangeSliderSize, offsetY: 140);
    }
}
