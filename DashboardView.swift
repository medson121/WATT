// DashboardView.swift - Encaminha diretamente para o redesign $100k/mês DashboardView_Premium
// Mantém total retrocompatibilidade com a navegação existente no ContentView

import SwiftUI

public struct DashboardView: View {
    public var onNavigateToVampires: (() -> Void)? = nil
    
    public init(onNavigateToVampires: (() -> Void)? = nil) {
        self.onNavigateToVampires = onNavigateToVampires
    }
    
    public var body: some View {
        DashboardView_Premium(onNavigateToVampires: onNavigateToVampires)
    }
}

#Preview {
    DashboardView()
}
