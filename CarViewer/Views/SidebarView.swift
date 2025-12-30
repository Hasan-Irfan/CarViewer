//
//  SidebarView.swift
//  CarViewer
//
//  侧边栏视图 - 按类型分组快速筛选
//

import SwiftUI

/// 缓存的赞赏码图片
private let cachedDonationImage: NSImage? = {
    if let url = Bundle.main.url(forResource: "zanshangma", withExtension: "png"),
       let image = NSImage(contentsOf: url) {
        return image
    }
    return nil
}()

struct SidebarView: View {
    @Environment(AssetStore.self) private var store

    private var isChinese: Bool {
        Locale.current.language.languageCode?.identifier == "zh"
    }

    var body: some View {
        @Bindable var store = store

        VStack(spacing: 0) {
            // 分类列表
            List(selection: $store.filterType) {
                // 分类（可折叠）
                Section {
                    DisclosureGroup(isExpanded: $store.isCategoriesExpanded) {
                        ForEach(RenditionType.allCases) { type in
                            NavigationLink(value: type) {
                                Label {
                                    HStack {
                                        Text(type.localizedName)
                                        Spacer()
                                        Text("\(countForType(type))")
                                            .foregroundStyle(.secondary)
                                            .font(.caption)
                                    }
                                } icon: {
                                    Image(systemName: type.systemImage)
                                }
                            }
                            .contextMenu {
                                if type != .all && countForType(type) > 0 {
                                    Button {
                                        store.exportType(type)
                                    } label: {
                                        Label(isChinese ? "导出全部\(type.localizedName)" : "Export All \(type.localizedName)", systemImage: "square.and.arrow.up")
                                    }
                                }
                            }
                        }
                    } label: {
                        Label {
                            HStack {
                                Text(isChinese ? "分类" : "Categories")
                                Spacer()
                                Text("\(RenditionType.allCases.count)")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                        } icon: {
                            Image(systemName: "square.grid.2x2")
                        }
                    }
                }

                // 文件夹列表（可折叠）
                if !store.allFolders.isEmpty {
                    Section {
                        DisclosureGroup(isExpanded: $store.isFoldersExpanded) {
                            // 搜索框
                            HStack(spacing: 6) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                                TextField(isChinese ? "搜索文件夹..." : "Search folders...", text: $store.folderSearchText)
                                    .textFieldStyle(.plain)
                                    .font(.callout)
                                if !store.folderSearchText.isEmpty {
                                    Button {
                                        store.folderSearchText = ""
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.secondary)
                                            .font(.caption)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.primary.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 6))

                            // 多选操作栏
                            HStack(spacing: 6) {
                                // 全选/反选按钮
                                Button {
                                    store.selectAllFolders()
                                } label: {
                                    Text(isChinese ? "全选" : "All")
                                        .font(.caption)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)

                                Button {
                                    store.invertFolderSelection()
                                } label: {
                                    Text(isChinese ? "反选" : "Invert")
                                        .font(.caption)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)

                                Spacer()

                                // 已选数量和操作
                                if !store.selectedFolders.isEmpty {
                                    Text(isChinese ? "已选 \(store.selectedFolders.count)" : "\(store.selectedFolders.count) sel.")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                    Button {
                                        store.exportSelectedFolders()
                                    } label: {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.caption)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .controlSize(.small)

                                    Button {
                                        store.clearFolderSelection()
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.caption2)
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                }
                            }
                            .padding(.vertical, 4)

                            // 全部文件夹选项（仅在没有搜索时显示）
                            if store.folderSearchText.isEmpty {
                                folderRow(folder: nil, label: isChinese ? "全部" : "All", count: store.allRenditions.count)
                            }

                            // 各个文件夹（筛选后）
                            ForEach(store.filteredFolders, id: \.self) { folder in
                                folderRow(folder: folder, label: folder, count: countForFolder(folder))
                            }

                            // 无搜索结果提示
                            if store.filteredFolders.isEmpty && !store.folderSearchText.isEmpty {
                                Text(isChinese ? "未找到匹配的文件夹" : "No matching folders")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                                    .padding(.vertical, 4)
                            }
                        } label: {
                            Label {
                                HStack {
                                    Text(isChinese ? "文件夹" : "Folders")
                                    if !store.selectedFolders.isEmpty {
                                        Text("(\(store.selectedFolders.count))")
                                            .foregroundStyle(Color.accentColor)
                                            .font(.caption)
                                    }
                                    Spacer()
                                    Text("\(store.allFolders.count)")
                                        .foregroundStyle(.secondary)
                                        .font(.caption)
                                }
                            } icon: {
                                Image(systemName: "folder")
                            }
                        }
                    }
                }
            }
            .listStyle(.sidebar)

            Divider()

            // 赞赏区域
            VStack(spacing: 8) {
                // 赞赏码图片 - 使用缓存的图片
                if let image = cachedDonationImage {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                Text(isChinese
                     ? "觉得不错对你有用\n请作者喝一杯咖啡吧"
                     : "If you find it useful\nBuy me a coffee")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Text(isChinese ? "微信扫码" : "WeChat")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 12)

            Divider()

            // 底部操作区
            VStack(spacing: 10) {
                // 导出全部按钮
                Button {
                    store.exportAll()
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text(isChinese ? "导出全部资源" : "Export All Assets")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(store.allRenditions.isEmpty)

                // 项目信息 - 简洁显示
                HStack(spacing: 12) {
                    Text("v1.0.3")
                        .font(.caption2)

                    Link(destination: URL(string: "mailto:xiaolajiaoyyds@gmail.com")!) {
                        Image(systemName: "envelope")
                    }

                    Link(destination: URL(string: "https://github.com/xiaolajiaoyyds/CarViewer")!) {
                        Image(systemName: "link")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(12)
        }
        .navigationSplitViewColumnWidth(min: 180, ideal: 220, max: 280)
    }

    private func countForType(_ type: RenditionType) -> Int {
        if type == .all {
            return store.allRenditions.count
        }
        return store.allRenditions.filter { $0.type == type }.count
    }

    /// 文件夹内资源数量
    private func countForFolder(_ folder: String) -> Int {
        store.allRenditions.filter { $0.elementName == folder }.count
    }

    /// 文件夹行视图
    @ViewBuilder
    private func folderRow(folder: String?, label: String, count: Int) -> some View {
        let isFiltered = store.filterFolder == folder
        let isMultiSelected = folder != nil && store.selectedFolders.contains(folder!)

        HStack {
            // 多选指示器
            if folder != nil {
                Image(systemName: isMultiSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isMultiSelected ? Color.accentColor : Color.secondary.opacity(0.5))
                    .font(.caption)
            }

            Image(systemName: folder == nil ? "tray.full" : "folder")
                .foregroundStyle(isFiltered ? Color.accentColor : .secondary)
            Text(label)
                .lineLimit(1)
            Spacer()
            Text("\(count)")
                .foregroundStyle(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .background(isFiltered ? Color.accentColor.opacity(0.15) : (isMultiSelected ? Color.accentColor.opacity(0.08) : Color.clear))
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .onTapGesture {
            // 点击切换筛选
            if folder == nil {
                store.clearFolderFilter()
            } else {
                store.filterFolder = folder
            }
        }
        .simultaneousGesture(
            TapGesture()
                .modifiers(.command)
                .onEnded { _ in
                    // Cmd+Click 多选
                    if let folder = folder {
                        store.toggleFolderSelection(folder)
                    }
                }
        )
        .contextMenu {
            if let folder = folder, count > 0 {
                Button {
                    store.exportFolder(folder)
                } label: {
                    Label(isChinese ? "导出「\(folder)」文件夹" : "Export \"\(folder)\" Folder", systemImage: "square.and.arrow.up")
                }

                if !store.selectedFolders.isEmpty {
                    Divider()
                    Button {
                        store.exportSelectedFolders()
                    } label: {
                        Label(isChinese ? "导出选中的 \(store.selectedFolders.count) 个文件夹" : "Export \(store.selectedFolders.count) Selected Folders", systemImage: "square.and.arrow.up.on.square")
                    }
                    Button {
                        store.clearFolderSelection()
                    } label: {
                        Label(isChinese ? "取消全部选择" : "Deselect All", systemImage: "xmark.circle")
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationSplitView {
        SidebarView()
            .environment(AssetStore())
    } detail: {
        Text("Detail")
    }
}
