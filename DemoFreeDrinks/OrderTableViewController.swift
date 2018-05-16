//
//  OrderTableViewController.swift
//  DemoFreeDrinks
//
//  Created by Chao Shin on 2018/5/7.
//  Copyright © 2018 Chao Shin. All rights reserved.
//

import UIKit
import GameplayKit

class OrderTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var sizeSegmented: UISegmentedControl!
    @IBOutlet var sugarSegmented: UISegmentedControl!
    @IBOutlet var iceSegmented: UISegmentedControl!
    @IBOutlet var extraSegmented: UISegmentedControl!
    @IBOutlet var noteTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var teaPicker: UIPickerView!
    
    var order = OrderTeaData()
    var teaData: [TeaInfomation] = []
    var teaIndex = 0
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {   // 回傳有幾個類別
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { //回傳有多少飲料名稱
        return teaData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { // 回傳現在顯示的飲料名稱
        return teaData[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateIceUI(row: row)
        teaIndex = row
        updatePriceUI()
    }
    
    @IBAction func extraSegmentedAction(_ sender: UISegmentedControl) {
        updatePriceUI()
    }
    @IBAction func sizeSegmentedAction(_ sender: Any) {
        if sizeSegmented.selectedSegmentIndex == 0 {
            showAlertMessage(title: "Sorry!無法選擇大杯",message: "請客的人要養小孩，所以限定中杯")
            sizeSegmented.selectedSegmentIndex = 1
            
        }
    }
    
    // 晃動手機亂數選飲料
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if event?.subtype == .motionShake{ //偵測手機是否搖動
            let randomNumber = GKRandomDistribution( lowestValue: 0, highestValue: teaData.count - 1 )
            teaIndex = randomNumber.nextInt()
            teaPicker.selectRow(teaIndex, inComponent: 0, animated: true)
            updatePriceUI()
            updateIceUI(row: teaIndex)
        }
    }
    
    
    func showAlertMessage(title: String, message: String) {
        let inputErrorAlert = UIAlertController(title: title, message: message, preferredStyle: .alert) //產生AlertController
        let okAction = UIAlertAction(title: "確認", style: .default, handler: nil) // 產生確認按鍵
        inputErrorAlert.addAction(okAction) // 將確認按鍵加入AlertController
        self.present(inputErrorAlert, animated: true, completion: nil) // 顯示Alert
    }
    
    func getOrder() {
        guard let name = nameTextField.text, name.count > 0 else{   // 檢查姓名是否輸入
            return showAlertMessage(title: "必須輸入姓名!",message: "請確認姓名是否有填寫")    // 顯示必須輸入的警告訊息
        }
        
        order.name = name
        print("訂購人姓名：\(name)")
        order.tea = teaData[teaIndex].name
        print("訂購飲料：\(order.tea)")
        if sizeSegmented.selectedSegmentIndex == 0 {
            order.size = "大杯"
        }else {
            order.size = "小杯"
        }
        print("容量：\(order.size)")
        
        switch sugarSegmented.selectedSegmentIndex {
        case 0:
            order.sugar = .regular
        case 1:
            order.sugar = .lessSuger
        case 2:
            order.sugar = .halfSuger
        case 3:
            order.sugar = .quarterSuger
        case 4:
            order.sugar = .sugerFree
        default:
            break
        }
        print("甜度：\(order.sugar.rawValue)")
        
        
        switch iceSegmented.selectedSegmentIndex {
        case 0:
            order.ice = .regular
        case 1:
            order.ice = .moreIce
        case 2:
            order.ice = .easyIce
        case 3:
            order.ice = .iceFree
        case 4:
            order.ice = .hot
        default:
            break
        }
        print("冰度：\(order.ice.rawValue)")
        
        if extraSegmented.selectedSegmentIndex == 0 {
            order.extra = "加購珍珠"
        }else {
            order.extra = "不需加購"
        }
        print("加購：\(order.extra)")
        
        if let note = noteTextField.text {
            order.note = note
            print("備註：\(note)")
        }
        if let price = priceLabel.text {
            let money = (price as NSString).substring(from: 4) //因為顯示時有加上NT. ，所以移除後上傳
            order.price = money
        }
        print("價格：\(order.price)")
        
        order.index = "\(teaIndex)"
        print("飲料編號：\(order.index)")
        order.password = passwordTextField.text ?? ""
        print("密碼：\(order.password)")
    }
    
    func sendOrderToServer() {
        let url = URL(string: "https://sheetdb.io/api/v1/5af6fd5e5cda2")
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST" // 上傳資料所以設定為POST
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type") // POST的API需要知道上傳的資料是什麼格式，所以依照API Documentation的規定設定
        
        let confirmOrder: [String : String] = ["name": order.name, "tea": order.tea, "size": order.size, "sugar": order.sugar.rawValue, "ice": order.ice.rawValue, "extra": order.extra, "note": order.note, "price": order.price, "index": order.index, "password": order.password] // post所提供的API，Value為物件的陣列（Array），所以利用Dictionary實作
        let postData: [String: Any] = ["data" : confirmOrder] // Post API 需要在物件（Object）內設定key值為data, value為一個物件的陣列（Array）
        
        do {
            let data = try JSONSerialization.data(withJSONObject: postData, options: []) // 將Data轉為JSON格式
            let task = URLSession.shared.uploadTask(with: urlRequest, from: data) { (retData, res, err) in // 背景上傳資料
                NotificationCenter.default.post(name: Notification.Name("waitMessage"), object: nil, userInfo: ["message": true])
            }
            task.resume()
        }
        catch{
        }
    }
    
    @IBAction func confirmButtonPress(_ sender: Any) {
        getOrder()
        navigationController?.isNavigationBarHidden = true // 隱藏NavigationBar
        NotificationCenter.default.post(name: Notification.Name("waitMessage"), object: nil, userInfo: ["message": false])
        sendOrderToServer()
        storeOrderData()
    }
    
    func updateIceUI(row: Int) {
        if row > 24 { //選到熱飲，Disable Segment0到Segment3，讓使用者無法選取
            if iceSegmented.isEnabledForSegment(at: 0) { //判斷Segment0是否已經被Disable
                for i in 0 ..< 4 {
                    iceSegmented.setEnabled(false, forSegmentAt: i) //Disable Segment0到Segment3
                }
                iceSegmented.setEnabled(true, forSegmentAt: 4) //Enable Segment4到Segment3
                iceSegmented.selectedSegmentIndex = 4 //將目前選擇指到Segment4(熱飲)
                iceSegmented.tintColor = .red //將顏色變為紅色
            }
            
        }else { //選到冷飲，Disable Segment4，讓使用者無法選取
            if iceSegmented.isEnabledForSegment(at: 4) {    //判斷Segment4是否已經被Disable
                iceSegmented.setEnabled(false, forSegmentAt: 4) //Disable Segment4
                if !iceSegmented.isEnabledForSegment(at: 0) {
                    for i in 0 ..< 4 {
                        iceSegmented.setEnabled(true, forSegmentAt: i) //Enable Segment0到Segment3
                    }
                }
                iceSegmented.selectedSegmentIndex = 0 //將目前選擇指到Segment0(冷飲的預設值)
                iceSegmented.tintColor = self.view.tintColor //將顏色變為預設的顏色
            }
        }
    }
    
    func updatePriceUI() {
        if extraSegmented.selectedSegmentIndex == 0 {
            priceLabel.text = "NT. \(teaData[teaIndex].price + 10)"
        }else {
            priceLabel.text = "NT. \(teaData[teaIndex].price)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getTeaList()
        updatePriceUI()
        updateIceUI(row: 0)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func storeOrderData() {
        
        let userDefault = UserDefaults.standard
        userDefault.set(order.name, forKey: "name:\(order.name)")
        userDefault.set(order.password, forKey: "password:\(order.name)")
        userDefault.synchronize()
    }
    
    func getTeaList() {
        if let url = Bundle.main.url(forResource: "TeaList", withExtension: "txt"), let content = try? String(contentsOf: url) { // 開啟飲料列表檔案，並將資料讀取出來
            let listArray = content.components(separatedBy: "\n") // 利用components將\n移除
            for number in 0 ..< listArray.count {
                if number % 2 == 0 {
                    let name = listArray[number]
                    if let price = Int(listArray[number + 1]) {
                        if number < 51 { // 51筆之後的資料為熱飲
                            teaData.append(TeaInfomation(name: name, price: price, isHot: false))
                        }else {
                            teaData.append(TeaInfomation(name: name, price: price, isHot: true))
                        }
                    }else {
                        print("轉型失敗")
                    }
                    
                }
            }
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
