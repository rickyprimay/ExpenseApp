//
//  SwipeAction.swift
//  ExpanseTracker
//
//  Created by Ricky Primayuda Putra on 16/11/24.
//

import SwiftUI

enum SwipeDirection {
    case leading
    case trailing
    
    var alignment: Alignment {
        switch self {
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        }
    }
}

struct Action: Identifiable {
    private(set) var id: UUID = UUID()
    var tint: Color
    var icon: String
    var iconFont: Font = .title
    var iconTint: Color = .white
    var isEnabled: Bool = true
    var action: () -> ()
}

struct CustomTransition: Transition {
    func body(content: Content, phase: TransitionPhase) -> some View {
        content
            .mask {
                GeometryReader {
                    let size = $0.size
                    
                    Rectangle()
                        .offset(y: phase == .identity ? 0 : -size.height)
                }
                .containerRelativeFrame(.horizontal)
            }
    }
}

struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout Value, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct SwipeAction<Content: View>: View {
    var cornerRadius: CGFloat = 0
    var direction: SwipeDirection = .trailing
    @ViewBuilder var content: Content
    var actions: [Action]
    @Environment(\.colorScheme) private var colorScheme
    
    let viewID = "CONTENTVIEW"
    @State private var isEnabled: Bool = true
    @State private var scrollOffset: CGFloat = .zero
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            scrollContent(scrollProxy: scrollProxy)
        }
        .allowsHitTesting(isEnabled)
        .transition(CustomTransition())
    }
    
    @ViewBuilder
    private func scrollContent(scrollProxy: ScrollViewProxy) -> some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                swipeContent(scrollProxy: scrollProxy)
            }
            .scrollTargetLayout()
            .visualEffect { content, geometryProxy in
                content.offset(x: scrollOffset(geometryProxy))
            }
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned)
        .background(backgroundRectangle())
        .clipShape(.rect(cornerRadius: cornerRadius))
        .rotationEffect(.init(degrees: direction == .leading ? 100 : 0))
    }

    @ViewBuilder
    private func swipeContent(scrollProxy: ScrollViewProxy) -> some View {
        content
            .rotationEffect(.init(degrees: direction == .leading ? -100 : 0))
            .containerRelativeFrame(.horizontal)
            .background(actionBackground())
            .id(viewID)
            .transition(.identity)
            .overlay(overlayGeometryReader())
        ActionButtons {
            withAnimation(.snappy) {
                scrollProxy.scrollTo(viewID, anchor: direction == .trailing ? .topLeading : .topTrailing)
            }
        }
        .opacity(scrollOffset == .zero ? 0 : 1)
    }

    @ViewBuilder
    private func actionBackground() -> some View {
        if let firstAction = filteredActions.first {
            Rectangle()
                .fill(firstAction.tint)
                .opacity(scrollOffset == .zero ? 0 : 1)
        }
    }

    @ViewBuilder
    private func overlayGeometryReader() -> some View {
        GeometryReader { geometry in
            let minX = geometry.frame(in: .scrollView(axis: .horizontal)).minX
            Color.clear
                .preference(key: OffsetKey.self, value: minX)
                .onPreferenceChange(OffsetKey.self) {
                    scrollOffset = $0
                }
        }
    }

    @ViewBuilder
    private func backgroundRectangle() -> some View {
        if let lastAction = actions.last {
            Rectangle()
                .fill(lastAction.tint)
                .opacity(scrollOffset == .zero ? 0 : 1)
        }
    }
    
    @ViewBuilder
    func ActionButtons(resetPosition: @escaping () -> ()) -> some View {
        Rectangle()
            .fill(.clear)
            .frame(width: CGFloat(actions.count) * 100)
            .overlay(alignment: direction.alignment) {
                HStack {
                    ForEach(actions) { button in
                        Button {
                            Task {
                                isEnabled = false
                                resetPosition()
                                try? await Task.sleep(for: .seconds(0.25))
                                button.action()
                                try? await Task.sleep(for: .seconds(0.1))
                                isEnabled = true
                            }
                        } label: {
                            Image(systemName: button.icon)
                                .font(button.iconFont)
                                .foregroundStyle(button.iconTint)
                                .frame(width: 100)
                                .frame(maxHeight: .infinity)
                                .contentShape(.rect)
                        }
                    }
                }
            }
    }
    
    func scrollOffset(_ proxy: GeometryProxy) -> CGFloat {
        let minX = proxy.frame(in: .scrollView(axis: .horizontal)).minX
        return (minX > 0 ? -minX : 0)
    }
    
    var filteredActions: [Action] {
        return actions.filter { $0.isEnabled }
    }
}
