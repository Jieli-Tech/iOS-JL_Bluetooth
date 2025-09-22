//
//  FileBrowseView.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2024/2/27.
//  Copyright © 2024 www.zh-jieli.com. All rights reserved.
//

import UIKit

class FileBrowseView: BaseView, UICollectionViewDelegateFlowLayout {
    var handleFileSelect: ((JLModel_File) -> Void)?
    private let titleItemsArray = BehaviorRelay<[JLModel_File]>(value: [])
    private let subItemsArray = BehaviorRelay<[JLModel_File]>(value: [])
    private var titleColoct: UICollectionView!
    private var subItemsTable = UITableView()
    private var nowModel: JLModel_File?
    override func initUI() {
        super.initUI()

        let flayout = UICollectionViewFlowLayout()
        flayout.itemSize = CGSize(width: 120, height: 30)
        flayout.minimumLineSpacing = 0
        flayout.minimumInteritemSpacing = 0
        flayout.scrollDirection = .horizontal

        titleColoct = UICollectionView(frame: CGRectZero, collectionViewLayout: flayout)
        titleColoct.backgroundColor = .clear
        titleColoct.showsHorizontalScrollIndicator = false
        titleColoct.register(FilesBrowseCell.self, forCellWithReuseIdentifier: "FilesBrowseCell")
        addSubview(titleColoct)
        titleColoct.rx.setDelegate(self).disposed(by: disposeBag)

        subItemsTable.register(FileModelCell.self, forCellReuseIdentifier: "FileModelCell")
        subItemsTable.backgroundColor = .clear
        subItemsTable.separatorStyle = .none
        subItemsTable.tableFooterView = UIView()
        subItemsTable.rowHeight = 50
        subItemsTable.mj_footer = MJRefreshAutoFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        addSubview(subItemsTable)

        titleColoct.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(10)
            make.height.equalTo(30)
        }

        subItemsTable.snp.makeConstraints { make in
            make.top.equalTo(titleColoct.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview().inset(10)
        }

        titleItemsArray.bind(to: titleColoct.rx
            .items(cellIdentifier: "FilesBrowseCell",
                   cellType: FilesBrowseCell.self))
        { _, model, cell in
            cell.mainLabel.text = model.fileName
            cell.backgroundColor = UIColor.random()
            cell.mainLabel.textColor = UIColor.white
        }.disposed(by: disposeBag)

        subItemsArray.bind(to: subItemsTable.rx
            .items(cellIdentifier: "FileModelCell",
                   cellType: FileModelCell.self))
        { _, model, cell in
            cell.textLabel1.text = model.fileName
            cell.centerView.backgroundColor = UIColor.random()
            if model.fileType == .folder {
                cell.imgv.image = UIImage(systemName: "folder.fill")
            } else {
                cell.imgv.image = UIImage(systemName: "music.note")
            }
        }.disposed(by: disposeBag)

        handleItemSelect()
    }

    override func initData() {
        super.initData()
    }

    @objc func loadMoreData() {
        if let nowModel = nowModel {
            BleManager.shared.currentCmdMgr?.mFileManager.cmdBrowseModel(nowModel, number: 10)
        }
    }

    func loadWithModel(model: JLModel_File) {
        nowModel = model
        guard let nowModel = nowModel else { return }
        BleManager.shared.currentCmdMgr?.mFileManager.cmdCleanCacheType(nowModel.cardType)
        titleItemsArray.accept([nowModel])

        BleManager.shared.currentCmdMgr?.mFileManager.cmdBrowseModel(nowModel, number: 10)
        BleManager.shared.currentCmdMgr?.mFileManager.cmdBrowseMonitorResult { [weak self] items, reason in
            switch reason {
            case .busy:
                break
            case .commandEnd:
                break
            case .folderEnd:
                self?.makeToast(R.localStr.endOfBrowsing(), position: .center)
                self?.subItemsTable.mj_footer?.endRefreshing()
            case .playSuccess:
                self?.makeToast("play files")
            case .dataFail:
                self?.makeToast("Data reading failed")
            case .reading:
                if let arr = items as? [JLModel_File] {
                    DispatchQueue.main.async {
                        self?.subItemsArray.accept(arr)
                    }
                }
            case .unknown:
                break
            @unknown default:
                break
            }
        }
    }

    private func handleItemSelect() {
        titleColoct.rx.modelSelected(JLModel_File.self).subscribe(onNext: { [weak self] model in
            guard let self = self else {
                return
            }
            var newArr: [JLModel_File] = []
            for i in 0 ..< self.titleItemsArray.value.count {
                let item = self.titleItemsArray.value[i]
                newArr.append(item)
                if item.fileClus == model.fileClus {
                    break
                }
            }
            self.titleItemsArray.accept(newArr)
            self.nowModel = model
            BleManager.shared.currentCmdMgr?.mFileManager.cmdBrowseModel(model, number: 10)
        }).disposed(by: disposeBag)

        subItemsTable.rx.modelSelected(JLModel_File.self).subscribe(onNext: {
            [weak self] model in
            guard let self = self else {
                return
            }
            if model.fileType == .folder {
                var newArr: [JLModel_File] = self.titleItemsArray.value
                newArr.append(model)
                self.titleItemsArray.accept(newArr)
                self.nowModel = model
                BleManager.shared.currentCmdMgr?.mFileManager.cmdBrowseModel(model, number: 10)
            } else {
                self.handleFileSelect?(model)
            }
        }).disposed(by: disposeBag)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = titleItemsArray.value[indexPath.row]
        let width = item.fileName.textAutoWidth(height: 30, font: UIFont.systemFont(ofSize: 14)) + 20
        return CGSize(width: width, height: 30)
    }
}

private extension String {
    func textAutoWidth(height: CGFloat, font: UIFont) -> CGFloat {
        let string = self as NSString
        let origin = NSStringDrawingOptions.usesLineFragmentOrigin
        let lead = NSStringDrawingOptions.usesFontLeading
        let rect = string.boundingRect(with: CGSize(width: 0, height: height), options: [origin, lead], attributes: [NSAttributedString.Key.font: font], context: nil)
        return rect.width
    }
}
