//
//  DiscoverViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/20/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

public class DiscoverViewController: StreamableViewController {
    var screen: DiscoverScreen!

    override public var tabBarItem: UITabBarItem? {
        get { return UITabBarItem.item(.Sparkles, insets: UIEdgeInsets(top: 8, left: 0, bottom: -8, right: 0)) }
        set { self.tabBarItem = newValue }
    }

    required public init(category: Category) {
        super.init(nibName: nil, bundle: nil)

        sharedInit(title: category.name)
        switch category.endpoint {
        case let .CategoryPosts(slug):
            streamViewController.streamKind = .CategoryPosts(slug: slug)
        case let .Discover(type):
            streamViewController.streamKind = .Discover(type: type)
        default:
            fatalError("invalid endpoint \(category.endpoint)")
        }

        streamViewController.customStreamCellItems = { jsonables, defaultItems in
            var items: [StreamCellItem] = []

            let toggleCellItem = StreamCellItem(jsonable: JSONAble(version: 1), type: .ColumnToggle)
            items += [toggleCellItem]

            items += defaultItems()
            return items
        }
    }

    required public init() {
        super.init(nibName: nil, bundle: nil)

        sharedInit()
        streamViewController.streamKind = .Discover(type: .Featured)
        streamViewController.customStreamCellItems = { jsonables, defaultItems in
            var items: [StreamCellItem] = []

            let toggleCellItem = StreamCellItem(jsonable: JSONAble(version: 1), type: .ColumnToggle)
            let categoryListItem = StreamCellItem(jsonable: CategoryList.hardCodedPrimaries(), type: .CategoryList)
            items += [toggleCellItem, categoryListItem]

            items += defaultItems()
            return items
        }
    }

    private func sharedInit(title title: String = InterfaceString.Discover.Title) {
        self.title = title
        elloNavigationItem.title = title

        if title != InterfaceString.Discover.Title {
            let leftItem = UIBarButtonItem.backChevronWithTarget(self, action: #selector(backTapped(_:)))
            elloNavigationItem.leftBarButtonItems = [leftItem]
            elloNavigationItem.fixNavBarItemPadding()
        }

        addSearchButton()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        self.screen = DiscoverScreen(navigationItem: elloNavigationItem)
        self.view = screen
        viewContainer = screen.streamContainer
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true

        scrollLogic.prevOffset = streamViewController.collectionView.contentOffset
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.loadInitialPage()
    }

    private func updateInsets() {
        updateInsets(navBar: screen.navigationBar, streamController: streamViewController)
    }

    override public func showNavBars(scrollToBottom: Bool) {
        super.showNavBars(scrollToBottom)
        positionNavBar(screen.navigationBar, visible: true, withConstraint: screen.navigationBarTopConstraint)
        updateInsets()

        if scrollToBottom {
            self.scrollToBottom(streamViewController)
        }
    }

    override public func hideNavBars() {
        super.hideNavBars()
        positionNavBar(screen.navigationBar, visible: false, withConstraint: screen.navigationBarTopConstraint)
        updateInsets()
    }
}

// MARK: StreamViewDelegate
extension DiscoverViewController {
    override public func streamViewCustomLoadFailed() -> Bool {
        if case .CategoryPosts = streamViewController.streamKind {
            streamViewController.discoverCategoryTapped(.Discover(type: .Featured))
            return true
        }
        return false
    }
}
