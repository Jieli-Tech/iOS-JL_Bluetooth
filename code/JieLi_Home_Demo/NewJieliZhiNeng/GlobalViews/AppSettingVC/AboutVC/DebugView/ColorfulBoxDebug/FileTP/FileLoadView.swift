//
//  FileLoadView.swift
//  WatchTest
//
//  Created by EzioChan on 2023/10/26.
//

import UIKit

class FileLoadView: BasicView{
    
    
    let table = UITableView()
    let bgView = UIView()
    let contentView = UIView()
    var handleBlock:((String)->())?
    private var filesArray:[String] = []
    private var filePath = ""
    
    override func initUI() {
        super.initUI()
        bgView.backgroundColor = UIColor.eHex("#000000",alpha: 0.6)
        self.addSubview(bgView)
        contentView.backgroundColor = UIColor.eHex("#FFFFFF",alpha: 0.7)
        contentView.layer.cornerRadius = 16
        contentView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        contentView.clipsToBounds = true
        self.addSubview(contentView)
        
        table.register(UITableViewCell.self, forCellReuseIdentifier: "FileCell")
        table.delegate = self
        table.dataSource = self
        table.tableFooterView = UIView()
        table.rowHeight = 40
        contentView.addSubview(table)
        
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalToSuperview().inset(100)
        }
        
        table.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let ges = UITapGestureRecognizer(target: self, action: #selector(didHiddenAction))
        bgView.addGestureRecognizer(ges)
        
    }
     
    
    @objc private func didHiddenAction(){
        self.isHidden = true
    }
    func showFiles(_ path:String,hasSuffix:String = ""){
        //遍历文件夹
        filesArray.removeAll()
        filePath = path
        if let files = try? FileManager.default.contentsOfDirectory(atPath: path){
            for file in files{
                //判断是否为文件夹
                let p = path + "/" + file
                var isDirctory:ObjCBool = ObjCBool(false)
                let isExist:Bool = FileManager.default.fileExists(atPath: p, isDirectory: &isDirctory)
                if isExist && !isDirctory.boolValue{
                    if hasSuffix != ""{
                        if file.hasSuffix(hasSuffix){
                            filesArray.append(file)
                        }
                    }else{
                        filesArray.append(file)
                    }
                }
            }
            table.reloadData()
        }
        
    }

}
    
extension FileLoadView: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath)
        let size = R.sizeForFilePath(self.filePath + "/" + filesArray[indexPath.row])
        cell.textLabel?.text = filesArray[indexPath.row] + " (" + R.covertToFileString(size) + ")"
        cell.textLabel?.textColor = UIColor.eHex("#000000")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.isHidden = true
        handleBlock?(self.filePath + "/" + filesArray[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "删除") { _, _, _ in
            try?FileManager.default.removeItem(atPath: self.filePath + "/" + self.filesArray[indexPath.row])
            self.filesArray.remove(at: indexPath.row)
            self.table.reloadData()
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
}
    
