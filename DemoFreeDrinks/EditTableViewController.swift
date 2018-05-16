//
//  EditTableViewController.swift
//  DemoFreeDrinks
//
//  Created by Chao Shin on 2018/5/13.
//  Copyright © 2018 Chao Shin. All rights reserved.
//

import UIKit

class EditTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    @IBOutlet var editTableView: UITableView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var sizeSegmented: UISegmentedControl!
    @IBOutlet var sugarSegmented: UISegmentedControl!
    @IBOutlet var iceSegmented: UISegmentedControl!
    @IBOutlet var extraSegmented: UISegmentedControl!
    @IBOutlet var noteTextField: UITextField!
    @IBOutlet var teaPicker: UIPickerView!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var confirmButton: UIButton!
    
    var activityIndicator:UIActivityIndicatorView!
    var userName: String!
    var userPassword: String!
    
    var teaIndex = 0
    
    var order : OrderTeaData!
    var teaData: [TeaInfomation] = []
    var userData: OrderInformation!
    
    func disableUI(){
        teaPicker.isHidden = true
        sizeSegmented.isEnabled = false
        sugarSegmented.isEnabled = false
        iceSegmented.isEnabled = false
        extraSegmented.isEnabled = false
        noteTextField.isEnabled = false
        confirmButton.isEnabled = false
        
    }

    @IBAction func extraSegmentedAction(_ sender: Any) {
        updatePriceUI()
    }
    
    func showAlertMessage(title: String, message: String) {
        let inputErrorAlert = UIAlertController(title: title, message: message, preferredStyle: .alert) //產生AlertController
        let okAction = UIAlertAction(title: "確認", style: .default, handler: nil) // 產生確認按鍵
        inputErrorAlert.addAction(okAction) // 將確認按鍵加入AlertController
        self.present(inputErrorAlert, animated: true, completion: nil) // 顯示Alert
    }
    
    @IBAction func sizeSegmentedAction(_ sender: Any) {
        if sizeSegmented.selectedSegmentIndex == 0 {
            showAlertMessage(title: "Sorry!無法選擇大杯",message: "請客的人要養小孩，所以限定中杯")
            sizeSegmented.selectedSegmentIndex = 1
        }
    }
    
    func updateUI(){
        nameTextField.text = userName
        teaPicker.isHidden = false
        if let index = Int(userData.index) {
            teaPicker.selectRow(index, inComponent: 0, animated: true)
        }
        
        priceLabel.text = userData.price
        
        sizeSegmented.isEnabled = true
        if userData.size == "大杯" {
            sizeSegmented.selectedSegmentIndex = 0
        }else {
            sizeSegmented.selectedSegmentIndex = 1
        }
        
        sugarSegmented.isEnabled = true
        switch userData.sugar{
        case "正常":
            sugarSegmented.selectedSegmentIndex = 0
        case "少糖":
            sugarSegmented.selectedSegmentIndex = 1
        case "半糖":
            sugarSegmented.selectedSegmentIndex = 2
        case "微糖":
            sugarSegmented.selectedSegmentIndex = 3
        case "無糖":
            sugarSegmented.selectedSegmentIndex = 4
        default:
            break
        }
        
        iceSegmented.isEnabled = true
        switch userData.ice {
        case "正常":
            iceSegmented.selectedSegmentIndex = 0
        case "多冰":
            iceSegmented.selectedSegmentIndex = 1
        case "少冰":
            iceSegmented.selectedSegmentIndex = 2
        case "去冰":
            iceSegmented.selectedSegmentIndex = 3
        case "熱飲":
            iceSegmented.selectedSegmentIndex = 4
        default:
            break
        }
        
        extraSegmented.isEnabled = true
        if userData.extra == "加購珍珠"{
            extraSegmented.selectedSegmentIndex = 0
        } else {
            extraSegmented.selectedSegmentIndex = 1
        }
        noteTextField.isEnabled = true
        noteTextField.text = userData.note
        
        confirmButton.isEnabled = true
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
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
    
    func editOrder() {
        userData.tea = teaData[teaIndex].name
        print("訂購飲料：\(userData.tea)")
        if sizeSegmented.selectedSegmentIndex == 0 {
            userData.size = "大杯"
        }else {
            userData.size = "小杯"
        }
        print("容量：\(userData.size)")
        
        switch sugarSegmented.selectedSegmentIndex {
        case 0:
            userData.sugar = "正常"
        case 1:
            userData.sugar = "少糖"
        case 2:
            userData.sugar = "半糖"
        case 3:
            userData.sugar = "微糖"
        case 4:
            userData.sugar = "無糖"
        default:
            break
        }
        print("甜度：\(userData.sugar)")
        
        
        switch iceSegmented.selectedSegmentIndex {
        case 0:
            userData.ice = "正常"
        case 1:
            userData.ice = "多冰"
        case 2:
            userData.ice = "少冰"
        case 3:
            userData.ice = "去冰"
        case 4:
            userData.ice = "熱飲"
        default:
            break
        }
        print("冰度：\(userData.ice)")
        
        if extraSegmented.selectedSegmentIndex == 0 {
            userData.extra = "加購珍珠"
        }else {
            userData.extra = "不需加購"
        }
        print("加購：\(userData.extra)")
        
        if let note = noteTextField.text {
            userData.note = note
            print("備註：\(note)")
        }

        
        if let price = priceLabel.text {
            let money = (price as NSString).substring(from: 4) //因為顯示時有加上NT. ，所以移除後上傳
            userData.price = money
        }
        print("價格：\(userData.price)")
        
        userData.index = "\(teaIndex)"
        print("飲料編號：\(userData.index)")
        
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
    
    
    func getOrder(){
        let commandString = "search?name=\(userName!)&&password=\(userPassword!)"
        let urlStr = "https://sheetdb.io/api/v1/5af6fd5e5cda2/\(commandString)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) // 將網址轉換成URL編碼（Percent-Encoding）
        let url = URL(string: urlStr!) // 將字串轉換成url
        // 背景抓取飲料訂單資料
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if let data = data, let content = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [[String: Any]]{ // 因為資料的Json的格式為陣列（Array）包物件（Object），所以[[String: Any]]
                for order in content {
                    if let data = OrderInformation(json: order){
                        self.userData = data
                    }
                }
                print(self.userData)
                if let indexNumber = Int(self.userData.index){
                    self.teaIndex = indexNumber
                }
                
                DispatchQueue.main.async {  // UI的更新必須在Main thread
                    self.stopLoding() //停止Loading動畫並且關閉不顯示
                    self.updateUI() // 更新畫面
                    self.updatePriceUI() // 更新價錢
                    self.updateIceUI(row: self.teaIndex) //更新冰度
                    self.editTableView.reloadData()    // 更新訂購表
                }
            }
        }
        task.resume() // 開始在背景下載資料
    }
    
    @IBAction func editButtonPress(_ sender: Any) {
        editOrder() // 取得修改的訂單資訊
        sendOrderToServer() // 傳送到網路上的試算表
    }
    
    func sendOrderToServer() {
        let url = URL(string: "https://sheetdb.io/api/v1/5af6fd5e5cda2/name/\(userData.name)") // 依照API所需PUT https://sheetdb.io/api/v1/5af6fd5e5cda2/{column}/{value}，因此用name為索引更新的column，要更新人名為value
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "PUT" // 更新上傳資料所以設定為PUT
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type") // PUT的API需要知道上傳的資料是什麼格式，所以依照API Documentation的規定設定
        
        let confirmOrder: [String : String] = ["name": userData.name, "tea": userData.tea, "size": userData.size, "sugar": userData.sugar, "ice": userData.ice, "extra": userData.extra, "note": userData.note, "price": userData.price, "index": userData.index, "password": userPassword!] // PUT所提供的API，Value為物件的陣列（Array），所以利用Dictionary實作
        
        let postData: [String: Any] = ["data" : confirmOrder] // PUT API 需要在物件（Object）內設定key值為data, value為一個物件的陣列（Array）
        
        do {
            let data = try JSONSerialization.data(withJSONObject: postData, options: []) // 將Data轉為JSON格式
            let task = URLSession.shared.uploadTask(with: urlRequest, from: data) { (retData, res, err) in // 背景上傳資料
                NotificationCenter.default.post(name: Notification.Name("waitMessage"), object: nil, userInfo: ["message": true])

            }
            task.resume()
            NotificationCenter.default.post(name: Notification.Name("waitMessage"), object: nil, userInfo: ["message": false])
            navigationController?.isNavigationBarHidden = true // 隱藏NavigationBar
            self.navigationController?.popViewController(animated: true) // 返回訂購頁面
        }
        catch{
        }
    }
    
    func showLoading(){ //用程式顯示ActivityIndicator
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle:
            UIActivityIndicatorViewStyle.whiteLarge) // 建立ActivityIndicator
        activityIndicator.color = UIColor.blue  //設定顏色為藍色
        activityIndicator.center=self.view.center   // 顯示位置為中央
        self.view.addSubview(activityIndicator);    // 增加到View上
        activityIndicator.startAnimating()  // 開始動畫效果
    }
    
    func stopLoding(){
        activityIndicator.stopAnimating()   // 停止動畫效果
        activityIndicator.hidesWhenStopped = true   // 當停止動畫後隱藏
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        disableUI() // 讓使用者在更新前無法修改
        showLoading() // 顯示Loading
        getTeaList()    // 從檔案抓取飲料名稱與價錢
        getOrder()  // 從網路上抓取要修改的訂單
 
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    /*
     override func numberOfSections(in tableView: UITableView) -> Int {
     // #warning Incomplete implementation, return the number of sections
     return 1
     }
     
     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     // #warning Incomplete implementation, return the number of rows
     return orderArray.count
     }
     
     
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
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
