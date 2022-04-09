//
//  ViewController.swift
//  GetOutfit
//
//  Created by Cell on 26.03.2022.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tf_search: UITextField!;
    @IBOutlet weak var tableV_results: UITableView!;
    @IBOutlet weak var b_filter: UIButton!;
    
    private var items:[Clothes]? = nil;
    private let userDef:UserDefaults = UserDefaults();
    private var colors:String = "",
                limit:String = "10",
                gender:String = "male",
                rangePrices:[Int] = [0,600_000],
                rangeSizes:[Int] = [1,70],
                order:[String] = ["name","asc"];
    
    private let dateFormatter = ISO8601DateFormatter();
    private let calendar = Calendar.current;
    struct Clothes: Decodable{
        let name: String;
        let pictures: [String];
        let gender: String;
        let price: Int;
        let size: String;
        let vendor: String;
        let old_price:Int?;
        let modified_time:String;
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableV_results.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchCell;
        cell.l_price.text = items![indexPath.row].price.description + " ₽";
        cell.l_name.text = items![indexPath.row].name;
        cell.l_gender.text = items![indexPath.row].gender;
        cell.l_size.text = items![indexPath.row].size;
        cell.l_vendor.text = "By: " + items![indexPath.row].vendor;
       
        let components = calendar.dateComponents([.year, .month, .day, .hour,.minute], from: dateFormatter.date(from: items![indexPath.row].modified_time)!);
        
        let day = components.day!;
        let month = components.month!;
        let hour = components.hour!;
        let minute = components.minute!;
        
        cell.l_modified.text = addZero(day)+"."+addZero(month)+"."+components.year!.description+" "+addZero(hour)+":"+addZero(minute);
        
        let attach = NSTextAttachment();
        let h = cell.l_modified.bounds.height;
        let img = UIImage(systemName: "clock.arrow.circlepath")!;
        img.withTintColor(UIColor.systemGray);
        img.withRenderingMode(.alwaysTemplate);
        attach.image = img;
        attach.bounds = CGRect(x: 0, y: -h+9, width: h, height: h);
        let attr = NSMutableAttributedString();
        attr.append(NSAttributedString(attachment: attach));
        let a = NSMutableAttributedString(string: "  "+cell.l_modified.text!);
        a.addAttributes([NSAttributedString.Key.foregroundColor:UIColor.systemGray], range: NSRange(location: 0, length: cell.l_modified.text!.count));
        attr.append(a);
        cell.l_modified.attributedText = attr;
        
        if let oldPrice = items![indexPath.row].old_price{
            cell.l_oldPrice.text = oldPrice.description + " ₽";
            let strikeThrougthAttr = NSMutableAttributedString(string: cell.l_oldPrice.text!);
            strikeThrougthAttr.addAttribute(.strikethroughStyle, value: 2, range: NSRange(location: 0, length: strikeThrougthAttr.length));
            
            cell.l_oldPrice.attributedText = strikeThrougthAttr;
        }
        
        if let url = URL(string: items![indexPath.row].pictures[0]){
            URLSession.shared.dataTask(with: url, completionHandler: {
                data, response, error in
                if (error != nil){
                    print("Error from the server while loading image: ",error);
                    return;
                }
                
                DispatchQueue.main.async {
                    cell.icon.image = UIImage(data: data!, scale: UIScreen.main.nativeScale/2-0.65);
                }
            }).resume();
        } else {
            print("Image haven't been loaded. URL is nil");
        }
        return cell;
    }
    
    private func addZero(_ val:Int)->String{
        return val < 10 ? ("0"+val.description) : val.description;
    }
    
    private func getData(){
        /*&size=gte.\(self.rangeSizes[0])&size=lte.\(self.rangeSizes[1])*/
        let url = "http://spb.getoutfit.co:3000/items?name=like.*\(self.nameParam())*&limit=\(self.limit)\(self.colors)&gender=eq.\(self.gender)&price=gte.\(self.rangePrices[0])&price=lte.\(self.rangePrices[1])&order=\(self.order[0]).\(self.order[1])";
        print("URL:",url);
        if let query = URL(string: url){
            print("shared");
            URLSession.shared.dataTask(with: query, completionHandler: {
                data, response, error in
                guard let data = data, error == nil else{
                    print(response);
                    print("URLTask contains some errors:",error);
                    return;
                }
                DispatchQueue.main.async {
                    do {
                        self.items = try JSONDecoder().decode([Clothes].self, from: data);
                        self.tableV_results.reloadData();
                        
                    } catch {
                        print("Error in main thread when decode JSON:",error.localizedDescription);
                    }
                }
            }).resume();
        } else {
            print("URL is nil");
        }
    }
    
    private func search() -> Void {
        tf_search.resignFirstResponder();
        getData();
    }
    
    private func nameParam()->String{
        return tf_search.text!.isEmpty ? "trainers" : tf_search.text!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!;
    }
    
    private func setColorsParam(with color:[String])->Void{
        if !color.isEmpty{
            colors = "&color=in.(";
            for i in 0..<color.count{
                colors += color[i].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!;
                if i != color.count-1{
                    colors+=",";
                }
            }
            colors += ")";
        } else {
            colors = "";
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        search();
        return true;
    }
    
    @IBAction func filter(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "filter") as! FilterViewController;
        vc.didQuit = {
            (limit, colors, gender, prices, sizes, order) in
            let c = self.colors;
            self.setColorsParam(with: colors!);
            if (limit != self.limit
                    || c != self.colors
                    || gender != self.gender
                    || prices[0] != self.rangePrices[0]
                    || prices[1] != self.rangePrices[1]
                    || sizes[0] != self.rangeSizes[0]
                    || sizes[1] != self.rangeSizes[1]
                    || order[0] != self.order[0]
                    || order[1] != self.order[1]) {
                self.userDef.setValue(colors!, forKey: "colors");
                self.userDef.setValue(limit, forKey: "limit");
                self.userDef.setValue(gender, forKey: "gender");
                self.userDef.setValue(sizes, forKey: "sizes");
                self.userDef.setValue(prices, forKey: "prices");
                self.userDef.setValue(order, forKey: "order");
                self.limit = limit;
                self.gender = gender;
                self.rangePrices = prices;
                self.rangeSizes = sizes;
                self.order = order;
                self.getData();
            }
        }
        present(vc, animated: true, completion: nil);
    }
    
    @IBAction func searchData(_ sender: UIButton) {
        search();
    }
    
    private var prevPoint:CGPoint = CGPoint(x: 0.0, y: 0.0);
    
    private func drawLine(_ path:UIBezierPath,x:CGFloat,y:CGFloat )->Void{
        path.addLine(to: CGPoint(x: x, y: y));
        path.move(to: CGPoint(x: x, y: y));
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // Draw 'Filter' icon
        let shapeLayer = CAShapeLayer();
        let path = UIBezierPath();
        
        path.move(to: CGPoint(x: 22.5, y: 39));
        drawLine(path, x: 27.5, y: 39);
        drawLine(path, x: 27.5, y: 27);
        drawLine(path, x: 33.5, y: 20);
        drawLine(path, x: 16.5, y: 20);
        drawLine(path, x: 22.5, y: 27);
        drawLine(path, x: 22.5, y: 39);
        path.close();
        
        shapeLayer.path = path.cgPath;
        shapeLayer.strokeColor = UIColor.black.cgColor;
        shapeLayer.lineWidth = 2;
        shapeLayer.lineCap = .round;
        shapeLayer.lineJoin = .round;
        b_filter.layer.addSublayer(shapeLayer);
        
        self.tableV_results.dataSource = self;
        self.tableV_results.delegate = self;
        self.tableV_results.rowHeight = 120.0;
        
        if let color = userDef.value(forKey: "colors") as? [String] {
            setColorsParam(with: color);
        }
        
        limit = userDef.string(forKey: "limit") ?? limit;
        gender = userDef.string(forKey: "gender") ?? gender;
        rangePrices = userDef.value(forKey: "prices") as? [Int] ?? rangePrices;
        rangeSizes = userDef.value(forKey: "sizes") as? [Int] ?? rangeSizes;
        
        order = userDef.value(forKey: "order") as? [String] ?? order;
        getData();
    }


}