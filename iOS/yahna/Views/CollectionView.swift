//
//  CollectionView.swift
//  yahna
//
//  Created by Ernesto Badillo on 10/13/19.
//  Copyright © 2019 Ernesto Badillo. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct CollectionView<Data, CellContent> : UIViewControllerRepresentable where Data : RandomAccessCollection, CellContent : View, Data.Element : Hashable & Identifiable {
    
    let data: Data
    
    var contentOffset: Binding<CGPoint?>?
    
    var firstVisibleIndexPath: Binding<IndexPath?>?
    
    let scrollToIndexPathPublisher: AnyPublisher<IndexPath, Never>?
    
    let cellContent: (Data.Element) -> CellContent
    
    let cellSize: (Data.Element, CGFloat) -> CGSize
    
    let refresh: (() -> AnyPublisher<Void, Never>)?
    
    public init(_ data: Data,
                contentOffset: Binding<CGPoint?>? = nil,
                firstVisibleIndexPath: Binding<IndexPath?>? = nil,
                scrollToIndexPathPublisher: AnyPublisher<IndexPath, Never>? = nil,
                refresh:  (() -> AnyPublisher<Void, Never>)? = nil,
                cellSize: @escaping (Data.Element, CGFloat) -> CGSize,
                @ViewBuilder cellContent: @escaping (Data.Element) -> CellContent) {
        self.contentOffset = contentOffset
        self.firstVisibleIndexPath = firstVisibleIndexPath
        self.scrollToIndexPathPublisher = scrollToIndexPathPublisher
        self.data = data
        self.refresh = refresh
        self.cellContent = cellContent
        self.cellSize = cellSize
    }
    
    typealias UIViewControllerType = MyCollectionViewController
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CollectionView>) -> MyCollectionViewController<Data, CellContent> {
        return MyCollectionViewController<Data, CellContent>(contentOffset: contentOffset,
                                                             initialData: data,
                                                             firstVisibleIndexPath: firstVisibleIndexPath,
                                                             scrollToIndexPathPublisher: scrollToIndexPathPublisher,
                                                             refresh: refresh,
                                                             cellSize: cellSize,
                                                             cellContent: cellContent)
    }
    
    func updateUIViewController(_ uiViewController: MyCollectionViewController<Data, CellContent>, context: UIViewControllerRepresentableContext<CollectionView>) {
        uiViewController.update(data: data,
                                contentOffset: contentOffset,
                                firstVisibleIndexPath: firstVisibleIndexPath,
                                animate: true)
    }
}

class MyCollectionViewController<Data, CellContent> : UICollectionViewController, UICollectionViewDelegateFlowLayout where Data : RandomAccessCollection, CellContent : View, Data.Element : Hashable & Identifiable {
    
    private var dataSource: UICollectionViewDiffableDataSource<MyCollectionViewSection, Data.Element>!
    
    private var initialData: Data?
    
    private var contentOffset: Binding<CGPoint?>?
    
    private var firstVisibleIndexPath: Binding<IndexPath?>?
    
    private let cellSize: (Data.Element, CGFloat) -> CGSize
    
    private let cellContent: (Data.Element) -> CellContent
    
    private let refresh: (() -> AnyPublisher<Void, Never>)?
    
    private let cellReuseIdentifier = "MyCollectionViewControllerCell"
    
    private let refreshControl = UIRefreshControl()
    
    private var scrollToIndexPathCancellable: AnyCancellable?
    
    public init(contentOffset: Binding<CGPoint?>? = nil,
                initialData: Data? = nil,
                firstVisibleIndexPath: Binding<IndexPath?>? = nil,
                scrollToIndexPathPublisher: AnyPublisher<IndexPath, Never>? = nil,
                refresh: (() -> AnyPublisher<Void, Never>)? = nil,
                cellSize: @escaping (Data.Element, CGFloat) -> CGSize,
                cellContent: @escaping (Data.Element) -> CellContent) {
        self.contentOffset = contentOffset
        self.initialData = initialData
        self.firstVisibleIndexPath = firstVisibleIndexPath
        self.refresh = refresh
        self.cellSize = cellSize
        self.cellContent = cellContent
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        super.init(collectionViewLayout: layout)
        
        scrollToIndexPathCancellable = scrollToIndexPathPublisher?.sink(receiveValue: { (indexPath) in
            self.collectionView.scrollToItem(at: indexPath,
                                             at: UICollectionView.ScrollPosition.top,
                                             animated: true)
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(data: Data,
                contentOffset: Binding<CGPoint?>? = nil,
                firstVisibleIndexPath: Binding<IndexPath?>? = nil,
                animate: Bool = true) {
        
        if let contentOffset = contentOffset {
            self.contentOffset = contentOffset
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<MyCollectionViewSection, Data.Element>()
        snapshot.appendSections([.section])
        snapshot.appendItems(Array(data), toSection: .section)
        
        dataSource.apply(snapshot, animatingDifferences: animate) {
            if let contentOffset = self.contentOffset?.wrappedValue {
                if contentOffset != self.collectionView.contentOffset {
                    self.collectionView.setContentOffset(contentOffset,
                                                         animated: animate)
                }
            }
        }
    }
    
    private var popItemViewCancellable: AnyCancellable?
    
    override func viewDidLoad() {
        
        // workaround for NavigationLink.isActive crashing when set to false.
        popItemViewCancellable = NavigationHelper.shared.popItemViewPublisher().sink(receiveValue: {
            self.navigationController?.popToRootViewController(animated: true)
        })
        
        collectionView.backgroundColor = UIColor.clear
        
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        collectionView.alwaysBounceVertical = true
        collectionView.refreshControl = refreshControl
        
        collectionView.register(MyCollectionViewCell<CellContent>.classForCoder(),
                                forCellWithReuseIdentifier: cellReuseIdentifier)
        
        dataSource = UICollectionViewDiffableDataSource<MyCollectionViewSection, Data.Element>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, element: Data.Element) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellReuseIdentifier,
                                                          for: indexPath) as! MyCollectionViewCell<CellContent>
            
            cell.setUp(content: self.cellContent(element))
            
            return cell
        }
        
        if let data = initialData {
            self.update(data: data, animate: false)
            initialData = nil
        }
    }
    
    @objc
    private func didPullToRefresh(_ sender: Any) {
        // Do you your api calls in here, and then asynchronously remember to stop the
        // refreshing when you've got a result (either positive or negative)
        guard let refresh = self.refresh else {
            self.refreshControl.endRefreshing()
            return
        }
        
        _ = refresh()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in self.refreshControl.endRefreshing() }, receiveValue: { _ in })
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
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        contentOffset?.wrappedValue = nil
        firstVisibleIndexPath?.wrappedValue = nil
    }
    
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        contentOffset?.wrappedValue = scrollView.contentOffset
        firstVisibleIndexPath?.wrappedValue = firstReallyVisibleIndexPath()
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        DispatchQueue.main.async {
            if !scrollView.isDecelerating {
                self.contentOffset?.wrappedValue = scrollView.contentOffset
                self.firstVisibleIndexPath?.wrappedValue = self.firstReallyVisibleIndexPath()
            }
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        contentOffset?.wrappedValue = scrollView.contentOffset
        firstVisibleIndexPath?.wrappedValue = firstReallyVisibleIndexPath()
    }
    
    private func firstReallyVisibleIndexPath() -> IndexPath? {
        let bounds = self.collectionView.bounds
        let targetRect = CGRect(origin: CGPoint(x: bounds.origin.x, y: bounds.origin.y+5),
                                size: CGSize(width: bounds.width, height: 10))
        guard let cell = collectionView.visibleCells.first(where: { $0.frame.intersects(targetRect) }) else {
            return nil
        }
        return collectionView.indexPath(for: cell)
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
