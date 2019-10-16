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
    
    let estimatedItemSize: CGSize
    
    public init(_ data: Data, estimatedItemSize: CGSize, @ViewBuilder cellContent: @escaping (Data.Element) -> CellContent) {
        self.data = data
        self.estimatedItemSize = estimatedItemSize
        self.cellContent = cellContent
    }
    
    typealias UIViewControllerType = MyCollectionViewController
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CollectionView>) -> MyCollectionViewController<Data, CellContent> {
        let vc = MyCollectionViewController<Data, CellContent>(estimatedItemSize: estimatedItemSize, cellContent: cellContent)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MyCollectionViewController<Data, CellContent>, context: UIViewControllerRepresentableContext<CollectionView>) {
        uiViewController.update(data: data)
    }
}

class MyCollectionViewController<Data, CellContent> : UICollectionViewController, UICollectionViewDelegateFlowLayout where Data : RandomAccessCollection, CellContent : View, Data.Element : Hashable & Identifiable {
    
    var dataSource: UICollectionViewDiffableDataSource<MyCollectionViewSection, Data.Element>!
    
    var data: Data?
    
    let cellContent: (Data.Element) -> CellContent
    
    private let cellReuseIdentifier = "MyCollectionViewControllerCell"
    
    public init(estimatedItemSize: CGSize, cellContent: @escaping (Data.Element) -> CellContent) {
        self.cellContent = cellContent
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = estimatedItemSize
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
            cell.setUp(content: self.cellContent(element))
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? MyCollectionViewCell<CellContent>)?.moveHostingControllerToParentViewController(self)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? MyCollectionViewCell<CellContent>)?.removeViewControllerFromParentViewController()
    }
}

enum MyCollectionViewSection : Hashable {
    case section
}

class MyCollectionViewCell<CellContent : View> : UICollectionViewCell {
    
    var hostingController: UIHostingController<AnyView> = UIHostingController<AnyView>(rootView: AnyView(EmptyView()))
    
    var _preferredSize: CGSize?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var preferredSize: CGSize {
        if let size = _preferredSize {
            return size
        } else {
            let size = hostingController.sizeThatFits(in: CGSize(width: contentView.frame.size.width,
                                                                 height: CGFloat.greatestFiniteMagnitude))
            _preferredSize = size
            return size
        }
    }
    
    func setUp(content: CellContent) {
        hostingController.rootView = AnyView(content)
        _preferredSize = nil
    }
    
    func moveHostingControllerToParentViewController(_ parentViewController: UIViewController) {
        parentViewController.addChild(hostingController)
        hostingController.didMove(toParent: parentViewController)
        hostingController.view.frame = CGRect(origin: contentView.bounds.origin, size: preferredSize)
        contentView.addSubview(hostingController.view)
    }
    
    func removeViewControllerFromParentViewController() {
        if hostingController.view.superview != nil {
            hostingController.view.removeFromSuperview()
            hostingController.willMove(toParent: nil)
            hostingController.removeFromParent()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        removeViewControllerFromParentViewController()
        hostingController.rootView = AnyView(EmptyView())
        _preferredSize = nil
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        attributes.size = preferredSize
        return attributes
    }
}
