// PaywallView.swift - Encaminha diretamente para o PaywallView_Premium ($100k/mês redesign)
// Mantém total retrocompatibilidade em todo o fluxo de monetização do app

import SwiftUI

public struct PaywallView: View {
    public init() {}
    
    public var body: some View {
        PaywallView_Premium()
    }
}

#Preview {
    PaywallView()
}
