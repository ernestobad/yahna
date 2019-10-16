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
    
    let cellSize: (Data.Element, CGFloat) -> CGSize
    
    public init(_ data: Data,
                cellSize: @escaping (Data.Element, CGFloat) -> CGSize,
                @ViewBuilder cellContent: @escaping (Data.Element) -> CellContent) {
        self.data = data
        self.cellContent = cellContent
        self.cellSize = cellSize
    }
    
    typealias UIViewControllerType = MyCollectionViewController
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CollectionView>) -> MyCollectionViewController<Data, CellContent> {
        let vc = MyCollectionViewController<Data, CellContent>(cellSize: cellSize, cellContent: cellContent)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MyCollectionViewController<Data, CellContent>, context: UIViewControllerRepresentableContext<CollectionView>) {
        uiViewController.update(data: data)
    }
}

class MyCollectionViewController<Data, CellContent> : UICollectionViewController, UICollectionViewDelegateFlowLayout where Data : RandomAccessCollection, CellContent : View, Data.Element : Hashable & Identifiable {
    
    var dataSource: UICollectionViewDiffableDataSource<MyCollectionViewSection, Data.Element>!
    
    var data: Data?
    
    let cellSize: (Data.Element, CGFloat) -> CGSize
    
    let cellContent: (Data.Element) -> CellContent
    
    private let cellReuseIdentifier = "MyCollectionViewControllerCell"
    
    public init(cellSize: @escaping (Data.Element, CGFloat) -> CGSize,
                cellContent: @escaping (Data.Element) -> CellContent) {
        self.cellSize = cellSize
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
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    override func viewDidLoad() {
        
        collectionView.backgroundColor = UIColor.clear
        
        collectionView.register(MyCollectionViewCell<CellContent>.classForCoder(),
                                forCellWithReuseIdentifier: cellReuseIdentifier)
        
        dataSource = UICollectionViewDiffableDataSource<MyCollectionViewSection, Data.Element>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, element: Data.Element) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellReuseIdentifier,
                                                          for: indexPath) as! MyCollectionViewCell<CellContent>
            
            cell.setUp(content: self.cellContent(element))
            
            return cell
        }
    }
    

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? MyCollectionViewCell<CellContent>)?.moveHostingControllerToParentViewController(self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let element = dataSource.itemIdentifier(for: indexPath) {
            return cellSize(element, collectionView.frame.width)
        } else {
            return .zero
        }
    }
}

enum MyCollectionViewSection : Hashable {
    case section
}

class MyCollectionViewCell<CellContent : View> : UICollectionViewCell {
    
    var hostingController: UIHostingController<AnyView> = UIHostingController<AnyView>(rootView: AnyView(EmptyView()))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp(content: CellContent) {
        hostingController.rootView = AnyView(content)
    }
    
    func moveHostingControllerToParentViewController(_ parentViewController: UIViewController) {
        guard hostingController.parent == nil else {
            return
        }
        parentViewController.addChild(hostingController)
        hostingController.didMove(toParent: parentViewController)
        hostingController.view.frame = contentView.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(hostingController.view)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        hostingController.rootView = AnyView(EmptyView())
    }
    
}
