//
//  ContentView.swift
//  Base64_Encoder_Decoder
//
//  Created by Ao XIE on 08/07/2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var toastMessage: String = ""
    @State private var showToast: Bool = false
    
    var body: some View {
        ZStack {
            // 简约背景
            Color(NSColor.windowBackgroundColor)
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // 简约标题栏 - 遵循黄金比例调整高度
                    HStack {
                        Text("Base64 编解码")
                            .font(.title)
                            .fontWeight(.light)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, geometry.size.width * 0.04)
                    .padding(.vertical, 16)
                    
                    // 主要内容区域 - 响应式布局
                    if geometry.size.width >= 800 {
                        // 宽屏模式：水平布局
                        HStack(spacing: 24) {
                            // 左侧编码区域
                            EncoderView(showToast: $showToast, toastMessage: $toastMessage)
                                .frame(maxWidth: .infinity)
                            
                            // 右侧解码区域
                            DecoderView(showToast: $showToast, toastMessage: $toastMessage)
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, geometry.size.width * 0.04)
                        .padding(.bottom, 32)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // 窄屏模式：垂直布局
                        ScrollView {
                            VStack(spacing: 24) {
                                // 编码区域
                                EncoderView(showToast: $showToast, toastMessage: $toastMessage)
                                
                                // 解码区域
                                DecoderView(showToast: $showToast, toastMessage: $toastMessage)
                            }
                            .padding(.horizontal, geometry.size.width * 0.04)
                            .padding(.bottom, 32)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            
            // 简约Toast提示
            if showToast {
                VStack {
                    Spacer()
                    
                    Text(toastMessage)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.black.opacity(0.8))
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    showToast = false
                                }
                            }
                        }
                }
                .padding(.bottom, 40)
            }
        }
        .frame(minWidth: 600, idealWidth: 800, maxWidth: 1200)
        .frame(minHeight: 500, idealHeight: 650, maxHeight: 900)
    }
}

struct EncoderView: View {
    @State private var draggedImage: NSImage?
    @State private var base64String: String = ""
    @State private var isOverDropZone = false
    @State private var isAnimating = false
    @Binding var showToast: Bool
    @Binding var toastMessage: String
    
    var body: some View {
        VStack(spacing: 20) {
            // 区域标题 - 调整间距
            HStack {
                Image(systemName: "arrow.up.circle")
                    .font(.title3)
                    .foregroundColor(.blue)
                
                Text("编码")
                    .font(.title3)
                    .fontWeight(.medium)
                
                Spacer()
            }
            
            // 拖拽区域
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(isOverDropZone ? Color.blue.opacity(0.08) : Color.gray.opacity(0.05))
                    .stroke(
                        isOverDropZone ? Color.blue : Color.gray.opacity(0.3),
                        style: StrokeStyle(lineWidth: 2, dash: isOverDropZone ? [] : [8, 4])
                    )
                    .frame(height: 200)
                    .scaleEffect(isOverDropZone ? 1.02 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOverDropZone)
                    .onDrop(of: [.image], isTargeted: $isOverDropZone) { providers in
                        return handleDrop(providers: providers)
                    }
                
                if let draggedImage = draggedImage {
                    Image(nsImage: draggedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 180)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 36, weight: .ultraLight))
                            .foregroundColor(.blue)
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                        
                        VStack(spacing: 4) {
                            Text("拖拽图像到这里")
                                .font(.headline)
                                .fontWeight(.medium)
                            Text("支持 JPG、PNG、GIF 等格式")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onAppear {
                        isAnimating = true
                    }
                }
            }
            
            // Base64编码显示区域
            if !base64String.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Base64 编码")
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            AppleButton(
                                title: "复制",
                                icon: "doc.on.doc",
                                style: .primary,
                                action: copyToClipboard
                            )
                            
                            if draggedImage != nil {
                                AppleButton(
                                    title: "保存",
                                    icon: "square.and.arrow.down",
                                    style: .secondary,
                                    action: saveOriginalImage
                                )
                            }
                            
                            AppleButton(
                                title: "清空",
                                icon: "trash",
                                style: .destructive,
                                action: clearAll
                            )
                        }
                    }
                    
                    ScrollView {
                        Text(base64String)
                            .font(.system(.body, design: .monospaced))
                            .textSelection(.enabled)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 120)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            Spacer()
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        
        if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { item, error in
                if error != nil {
                    DispatchQueue.main.async {
                        self.showToastMessage("加载图像失败")
                    }
                    return
                }
                
                if let url = item as? URL {
                    DispatchQueue.main.async {
                        self.loadImage(from: url)
                    }
                }
            }
            return true
        }
        
        return false
    }
    
    private func loadImage(from url: URL) {
        do {
            let imageData = try Data(contentsOf: url)
            if let image = NSImage(data: imageData) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    self.draggedImage = image
                    self.base64String = imageData.base64EncodedString()
                }
                showToastMessage("图像编码成功")
            }
        } catch {
            showToastMessage("读取图像失败")
        }
    }
    
    private func copyToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(base64String, forType: .string)
        showToastMessage("已复制到剪贴板")
    }
    
    private func saveOriginalImage() {
        guard let image = draggedImage else { return }
        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png, .jpeg]
        savePanel.nameFieldStringValue = "encoded_image"
        savePanel.allowsOtherFileTypes = false
        
        if savePanel.runModal() == .OK {
            if let url = savePanel.url {
                let fileExtension = url.pathExtension.lowercased()
                
                var imageData: Data?
                if fileExtension == "png" {
                    imageData = image.pngData()
                } else {
                    imageData = image.jpegData(compressionFactor: 0.9)
                }
                
                if let data = imageData {
                    do {
                        try data.write(to: url)
                        showToastMessage("图像保存成功")
                    } catch {
                        showToastMessage("保存失败")
                    }
                }
            }
        }
    }
    
    private func clearAll() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            draggedImage = nil
            base64String = ""
        }
        showToastMessage("已清空")
    }
    
    private func showToastMessage(_ message: String) {
        toastMessage = message
        withAnimation(.easeInOut(duration: 0.3)) {
            showToast = true
        }
    }
}

struct DecoderView: View {
    @State private var base64String: String = ""
    @State private var decodedImage: NSImage?
    @State private var isAnimating = false
    @State private var isDecoding = false
    @Binding var showToast: Bool
    @Binding var toastMessage: String
    
    var body: some View {
        VStack(spacing: 20) {
            // 区域标题 - 调整间距
            HStack {
                Image(systemName: "arrow.down.circle")
                    .font(.title3)
                    .foregroundColor(.green)
                
                Text("解码")
                    .font(.title3)
                    .fontWeight(.medium)
                
                Spacer()
            }
            
            // Base64输入区域
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Base64 编码")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    AppleButton(
                        title: "粘贴",
                        icon: "doc.on.clipboard",
                        style: .primary,
                        action: pasteFromClipboard
                    )
                }
                
                ZStack {
                    if base64String.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "text.cursor")
                                .font(.title2)
                                .foregroundColor(.secondary)
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                            
                            Text("粘贴 Base64 编码")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(height: 100)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .onAppear {
                            isAnimating = true
                        }
                    } else {
                        ScrollView {
                            TextEditor(text: Binding(
                                get: { base64String },
                                set: { newValue in
                                    base64String = newValue
                                    decodeBase64()
                                }
                            ))
                            .font(.system(.body, design: .monospaced))
                            .scrollContentBackground(.hidden)
                            .padding(12)
                        }
                        .frame(height: 100)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
            }
            
            // 解码图像显示区域
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("解码结果")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    if decodedImage != nil {
                        HStack(spacing: 8) {
                            AppleButton(
                                title: "保存",
                                icon: "square.and.arrow.down",
                                style: .secondary,
                                action: saveImage
                            )
                            
                            AppleButton(
                                title: "清空",
                                icon: "trash",
                                style: .destructive,
                                action: clearAll
                            )
                        }
                    }
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.05))
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        .frame(height: 200)
                    
                    if isDecoding {
                        VStack(spacing: 16) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.2)
                            
                            Text("正在解码...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    } else if let decodedImage = decodedImage {
                        Image(nsImage: decodedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 180)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "photo")
                                .font(.system(size: 28, weight: .ultraLight))
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: 4) {
                                Text("解码后的图像将显示在这里")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                Text("请输入有效的 Base64 编码")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
    
    private func decodeBase64() {
        guard !base64String.isEmpty else {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                decodedImage = nil
            }
            return
        }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            isDecoding = true
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let cleanBase64 = base64String.replacingOccurrences(of: "\n", with: "")
                                         .replacingOccurrences(of: " ", with: "")
            
            var resultImage: NSImage? = nil
            var isValid = false
            
            if let data = Data(base64Encoded: cleanBase64),
               let image = NSImage(data: data) {
                resultImage = image
                isValid = true
            }
            
            DispatchQueue.main.async {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    self.isDecoding = false
                    self.decodedImage = resultImage
                }
                
                if isValid {
                    self.showToastMessage("解码成功")
                } else if !cleanBase64.isEmpty {
                    self.showToastMessage("无效的 Base64 编码")
                }
            }
        }
    }
    
    private func pasteFromClipboard() {
        let pasteboard = NSPasteboard.general
        if let string = pasteboard.string(forType: .string) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                base64String = string
            }
            decodeBase64()
            showToastMessage("已从剪贴板粘贴")
        } else {
            showToastMessage("剪贴板中没有文本")
        }
    }
    
    private func saveImage() {
        guard let image = decodedImage else { return }
        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png, .jpeg]
        savePanel.nameFieldStringValue = "decoded_image"
        savePanel.allowsOtherFileTypes = false
        
        if savePanel.runModal() == .OK {
            if let url = savePanel.url {
                let fileExtension = url.pathExtension.lowercased()
                
                var imageData: Data?
                if fileExtension == "png" {
                    imageData = image.pngData()
                } else {
                    imageData = image.jpegData(compressionFactor: 0.9)
                }
                
                if let data = imageData {
                    do {
                        try data.write(to: url)
                        showToastMessage("图像保存成功")
                    } catch {
                        showToastMessage("保存失败")
                    }
                }
            }
        }
    }
    
    private func clearAll() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            base64String = ""
            decodedImage = nil
            isDecoding = false
        }
        showToastMessage("已清空")
    }
    
    private func showToastMessage(_ message: String) {
        toastMessage = message
        withAnimation(.easeInOut(duration: 0.3)) {
            showToast = true
        }
    }
}

struct AppleButton: View {
    let title: String
    let icon: String
    let style: ButtonStyle
    let action: () -> Void
    
    enum ButtonStyle {
        case primary, secondary, destructive
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(backgroundColor)
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: false)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return .blue
        case .secondary:
            return Color.gray.opacity(0.15)
        case .destructive:
            return Color.red.opacity(0.1)
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return .primary
        case .destructive:
            return .red
        }
    }
}

#Preview {
    ContentView()
}

extension NSImage {
    func pngData() -> Data? {
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        return bitmapRep.representation(using: .png, properties: [:])
    }
    
    func jpegData(compressionFactor: CGFloat) -> Data? {
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        return bitmapRep.representation(using: .jpeg, properties: [:])
    }
}
