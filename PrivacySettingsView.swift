// PrivacySettingsView.swift - Central de Privacidade, Segurança e Conformidade GDPR / Apple
// Permite ativar Face ID, inspecionar criptografia de dados e exercer direito ao esquecimento

import SwiftUI

struct PrivacySettingsView: View {
    @StateObject private var biometric = BiometricAuthManager.shared
    @StateObject private var paywall = PaywallManager.shared
    @StateObject private var supabase = SupabaseManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showDeleteConfirmation = false
    @State private var isPurging = false
    @State private var showSupabaseTest = false
    @State private var showExportSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#FFF9F0").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header com escudo de proteção
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "#10B981").opacity(0.12))
                                    .frame(width: 72, height: 72)
                                Image(systemName: "shield.lefthalf.filled.badge.checkmark")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(Color(hex: "#059669"))
                            }
                            .padding(.top, 8)
                            
                            Text("Privacidade & Segurança")
                                .font(.system(size: 24, weight: .heavy, design: .rounded))
                                .foregroundColor(Color(hex: "#0F2235"))
                            
                            Text("Seus dados de energia e histórico protegidos com criptografia de hardware Apple.")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "#0F2235").opacity(0.65))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        
                        // MARK: - Seção 1: Bloqueio Biométrico (Face ID)
                        VStack(alignment: .leading, spacing: 14) {
                            Label("ACESSO PROTEGIDO", systemImage: "lock.shield")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#0F2235").opacity(0.5))
                            
                            HStack {
                                Image(systemName: biometric.biometricType.systemIcon)
                                    .font(.system(size: 22))
                                    .foregroundColor(Color(hex: "#3B82F6"))
                                    .frame(width: 36)
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Bloqueio por \(biometric.biometricType.title)")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(hex: "#0F2235"))
                                    
                                    Text("Exigir autenticação ao abrir ou retornar ao WATT")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(hex: "#0F2235").opacity(0.6))
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: Binding(
                                    get: { biometric.isBiometricEnabled },
                                    set: { newValue in
                                        Task {
                                            if newValue {
                                                let success = await biometric.authenticate()
                                                if success {
                                                    biometric.isBiometricEnabled = true
                                                }
                                            } else {
                                                biometric.isBiometricEnabled = false
                                            }
                                        }
                                    }
                                ))
                                .labelsHidden()
                            }
                            
                            if let error = biometric.authErrorMessage {
                                Text(error)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(18)
                        .shadow(color: Color.black.opacity(0.03), radius: 8, y: 3)
                        
                        // MARK: - Seção 2: Blindagem e Criptografia
                        VStack(alignment: .leading, spacing: 14) {
                            Label("BLINDAGEM DO DISPOSITIVO", systemImage: "cpu")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#0F2235").opacity(0.5))
                            
                            securityFeatureRow(
                                icon: "key.fill",
                                title: "Apple Secure Enclave",
                                subtitle: "Chaves de assinatura e entitlements protegidos no Keychain",
                                status: "Ativo",
                                statusColor: Color(hex: "#10B981")
                            )
                            
                            Divider()
                            
                            securityFeatureRow(
                                icon: "eye.slash.fill",
                                title: "Privacy Screen Shield",
                                subtitle: "Desfoque automático ativo ao alternar aplicativos no iOS",
                                status: "Ativo",
                                statusColor: Color(hex: "#10B981")
                            )
                            
                            Divider()
                            
                            securityFeatureRow(
                                icon: "person.crop.circle.badge.checkmark",
                                title: "Zero Rastreamento de Terceiros",
                                subtitle: "Nenhum SDK de analytics ou ad-tracker invasivo instalado",
                                status: "100% Limpo",
                                statusColor: Color(hex: "#10B981")
                            )
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(18)
                        .shadow(color: Color.black.opacity(0.03), radius: 8, y: 3)
                        
                        // MARK: - Seção 3: Diagnóstico de Conexão Supabase
                        Button {
                            showSupabaseTest = true
                        } label: {
                            HStack {
                                Image(systemName: "externaldrive.badge.icloud")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(hex: "#059669"))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Diagnóstico Supabase Cloud")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(hex: "#0F2235"))
                                    Text("Verificar conexão de dados e latência REST")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(hex: "#0F2235").opacity(0.6))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color.gray.opacity(0.5))
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(18)
                            .shadow(color: Color.black.opacity(0.03), radius: 8, y: 3)
                        }
                        
                        // MARK: - Seção 4: Links Legais Obrigatórios
                        VStack(spacing: 8) {
                            HStack(spacing: 16) {
                                Link(destination: AppConfiguration.shared.privacyURL) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "hand.raised.fill")
                                            .font(.system(size: 12))
                                        Text("Política de Privacidade")
                                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    }
                                    .foregroundColor(Color(hex: "#3B82F6"))
                                }
                                
                                Text("•")
                                    .foregroundColor(.gray)
                                
                                Link(destination: AppConfiguration.shared.termsURL) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "doc.text.fill")
                                            .font(.system(size: 12))
                                        Text("Termos de Uso")
                                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    }
                                    .foregroundColor(Color(hex: "#3B82F6"))
                                }
                            }
                        }
                        .padding(.top, 4)
                        
                        // MARK: - Seção 5: Exclusão de Dados (Direito ao Esquecimento - GDPR/LGPD)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("ZONA DE CONFORMIDADE GDPR / LGPD")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(Color.red.opacity(0.8))
                            
                            Button {
                                showDeleteConfirmation = true
                            } label: {
                                HStack {
                                    if isPurging {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .red))
                                    } else {
                                        Image(systemName: "trash.fill")
                                            .font(.system(size: 16))
                                    }
                                    
                                    Text(isPurging ? "Excluindo dados..." : "Apagar Meus Dados e Reiniciar")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color.red.opacity(0.08))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red.opacity(0.2), lineWidth: 1)
                                )
                            }
                            .disabled(isPurging)
                            
                            Text("Esta ação remove permanentemente seus dados do Supabase, zera o identificador anônimo do dispositivo e limpa as credenciais locais do Keychain.")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "#0F2235").opacity(0.5))
                                .padding(.horizontal, 4)
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(18)
                        .shadow(color: Color.black.opacity(0.03), radius: 8, y: 3)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Segurança & Privacidade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "#3B82F6"))
                }
            }
            .sheet(isPresented: $showSupabaseTest) {
                SupabaseTestView()
            }
            .alert("Apagar todos os dados?", isPresented: $showDeleteConfirmation) {
                Button("Cancelar", role: .cancel) { }
                Button("Sim, Excluir Tudo", role: .destructive) {
                    isPurging = true
                    Task {
                        await paywall.resetAllDataGDPR()
                        isPurging = false
                        dismiss()
                    }
                }
            } message: {
                Text("Seus registros de economia diária, histórico de vampiros de energia e chaves locais no Keychain serão permanentemente eliminados. O aplicativo voltará ao estado inicial de onboarding.")
            }
        }
    }
    
    @ViewBuilder
    private func securityFeatureRow(icon: String, title: String, subtitle: String, status: String, statusColor: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color(hex: "#0F2235"))
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#0F2235"))
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "#0F2235").opacity(0.6))
            }
            
            Spacer()
            
            Text(status)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(statusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.12))
                .cornerRadius(8)
        }
    }
}

#Preview {
    PrivacySettingsView()
}
