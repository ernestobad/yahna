//
//  CollectionView.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/13/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import Foundation
import SwiftUI

struct CollectionView<Data, CellContent> : UIViewControllerRepresentable where Data : RandomAccessCollection, CellContent : View, Data.Element : Hashable & Identifiable {
    
    let data: Data
    
    let cellContent: (Data.Element) -> CellContent
    
    //let estimatedItemSize: CGSize
    
    public init(_ data: Data, estimatedItemSize: CGSize, @ViewBuilder cellContent: @escaping (Data.Element) -> CellContent) {
        self.data = data
        //self.estimatedItemSize = estimatedItemSize
        self.cellContent = cellContent
    }
    
    typealias UIViewControllerType = MyCollectionViewController
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CollectionView>) -> MyCollectionViewController<Data, CellContent> {
        let vc = MyCollectionViewController<Data, CellContent>(cellContent: cellContent)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MyCollectionViewController<Data, CellContent>, context: UIViewControllerRepresentableContext<CollectionView>) {
        uiViewController.update(data: data)
    }
}

//class PrefetchingDiffableDataSource<Data> : UICollectionViewDiffableDataSource<MyCollectionViewSection, Data.Element>, UICollectionViewDataSourcePrefetching where Data : RandomAccessCollection,Data.Element : Hashable & Identifiable {
//    
//    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
//        <#code#>
//    }
//}

class MyCollectionViewController<Data, CellContent> : UICollectionViewController, UICollectionViewDelegateFlowLayout where Data : RandomAccessCollection, CellContent : View, Data.Element : Hashable & Identifiable {
    
    var dataSource: UICollectionViewDiffableDataSource<MyCollectionViewSection, Data.Element>!
    
    var data: Data?
    
    let cellContent: (Data.Element) -> CellContent
    
    var viewControllersDict = [Data.Element.ID: UIHostingController<AnyView>]()
    
    private let cellReuseIdentifier = "MyCollectionViewControllerCell"
    
    public init(cellContent: @escaping (Data.Element) -> CellContent) {
        self.cellContent = cellContent
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(data: Data) {
        var snapshot = NSDiffableDataSourceSnapshot<MyCollectionViewSection, Data.Element>()
        snapshot.appendSections([.section])
        snapshot.appendItems(Array(data), toSection: .section)
        setupChildViewControllers(data: data)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    override func viewDidLoad() {
        
        collectionView.backgroundColor = UIColor.clear
        
        collectionView.register(MyCollectionViewCell<CellContent>.classForCoder(),
                                forCellWithReuseIdentifier: cellReuseIdentifier)
        
        dataSource = UICollectionViewDiffableDataSource<MyCollectionViewSection, Data.Element>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, element: Data.Element) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellReuseIdentifier,
                                                          for: indexPath) as! MyCollectionViewCell<CellContent>
            
            if let vc = self.viewControllersDict[element.id] {
                cell.setUp(content: vc.view)
            }
            
            return cell
        }
    }
    
    private func setupChildViewControllers(data: Data) {
        
        var idsToDelete = Set<Data.Element.ID>(viewControllersDict.keys)
        
        for element in data {
            idsToDelete.remove(element.id)
            if let existingViewController = viewControllersDict[element.id] {
                let view = cellContent(element)
                existingViewController.rootView = AnyView(view)
            } else {
                let view = cellContent(element)
                let newVC = UIHostingController(rootView: AnyView(view))
                viewControllersDict[element.id] = newVC
                addChild(newVC)
                newVC.didMove(toParent: self)
            }
        }
        
        for id in idsToDelete {
            if let vc = viewControllersDict[id] {
                vc.view.removeFromSuperview()
                vc.willMove(toParent: nil)
                vc.removeFromParent()
                viewControllersDict.removeValue(forKey: id)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let element = dataSource.itemIdentifier(for: indexPath), let vc = viewControllersDict[element.id] {
            return vc.sizeThatFits(in: CGSize(width: collectionView.frame.width, height: .greatestFiniteMagnitude))
        } else {
            return .zero
        }
    }
}

enum MyCollectionViewSection : Hashable {
    case section
}

class MyCollectionViewCell<CellContent : View> : UICollectionViewCell {
    
    var subview: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp(content: UIView) {
        
        if let subview = self.subview {
            subview.removeFromSuperview()
        }
        
        subview = content
        
        content.frame = self.contentView.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.contentView.addSubview(content)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if let subview = self.subview {
            subview.removeFromSuperview()
        }
        subview = nil
    }
}
