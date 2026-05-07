//
//  CollapsingHeaderViewTests.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 30/04/26.
//

import Testing
import Foundation
@testable import MoisesSearch

@Suite(.tags(.unit))
struct CollapsingHeaderLayoutTests {
    @Test(arguments: [
        (scroll: CGFloat(0), expected: CGFloat(0)),
        (scroll: CGFloat(49), expected: CGFloat(0)),
        (scroll: CGFloat(50), expected: CGFloat(0)),
        (scroll: CGFloat(82.5), expected: CGFloat(0.5)),
        (scroll: CollapsingHeaderLayout.fullyCollapsedScrollDistance - 1, expected: CGFloat(64) / 65),
        (scroll: CollapsingHeaderLayout.fullyCollapsedScrollDistance, expected: CGFloat(1)),
        (scroll: CGFloat(200), expected: CGFloat(1)),
    ])
    func collapseProgress_matchesExpected(scroll: CGFloat, expected: CGFloat) {
        let result = CollapsingHeaderLayout.collapseProgress(scrollDistance: scroll)
        #expect(abs(result - expected) < 0.0001)
    }

    @Test func inlineSearchOpacity_matchesOneMinusCollapseProgress() {
        let scrollDistance: CGFloat = 90
        let collapseProgress = CollapsingHeaderLayout.collapseProgress(scrollDistance: scrollDistance)
        let inlineSearchOpacity = CollapsingHeaderLayout.inlineSearchOpacity(scrollDistance: scrollDistance)

        #expect(abs(inlineSearchOpacity - (1 - collapseProgress)) < 0.0001)
    }

    @Test func isCollapsed_isFalseBeforeThreshold() {
        #expect(
            CollapsingHeaderLayout.isCollapsed(
                scrollDistance: CollapsingHeaderLayout.fullyCollapsedScrollDistance - 1
            ) == false
        )
    }

    @Test func isCollapsed_isTrueAtAndAfterThreshold() {
        #expect(CollapsingHeaderLayout.isCollapsed(scrollDistance: CollapsingHeaderLayout.fullyCollapsedScrollDistance))
        #expect(CollapsingHeaderLayout.isCollapsed(scrollDistance: 500))
    }

    @Test func fullyCollapsedScrollDistance_matchesFadePlusCollapse() {
        #expect(CollapsingHeaderLayout.fullyCollapsedScrollDistance == CollapsingHeaderLayout.fadeLeadIn + CollapsingHeaderLayout.collapseDistance)
    }
}
