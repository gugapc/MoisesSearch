//
//  CollapsingHeaderLayout.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 30/04/26.
//

import Foundation

/// Pure layout math for `CollapsingHeaderView` (scroll distance → opacity / collapsed).
enum CollapsingHeaderLayout {
    /// Scroll distance (pt) before the fade begins.
    static let fadeLeadIn: CGFloat = 50
    /// Scroll distance (pt) over which the search fades after `fadeLeadIn`.
    static let collapseDistance: CGFloat = 65

    /// Scroll distance at which the inline search is fully faded and the compact toolbar state applies.
    static var fullyCollapsedScrollDistance: CGFloat {
        fadeLeadIn + collapseDistance
    }

    static func collapseProgress(scrollDistance: CGFloat) -> CGFloat {
        min(1, max(0, (scrollDistance - fadeLeadIn) / max(collapseDistance, 1)))
    }

    static func inlineSearchOpacity(scrollDistance: CGFloat) -> CGFloat {
        1 - collapseProgress(scrollDistance: scrollDistance)
    }

    static func isCollapsed(scrollDistance: CGFloat) -> Bool {
        collapseProgress(scrollDistance: scrollDistance) >= 1
    }
}
