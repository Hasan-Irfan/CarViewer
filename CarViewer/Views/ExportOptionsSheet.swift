//
//  ExportOptionsSheet.swift
//  CarViewer
//
//  导出选项面板 - 选择导出分辨率（支持多选）
//

import SwiftUI

struct ExportOptionsSheet: View {
    @Environment(AssetStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    private var isChinese: Bool {
        Locale.current.language.languageCode?.identifier == "zh"
    }

    /// 是否有选中的选项
    private var hasSelection: Bool {
        !store.exportScaleOptions.isEmpty
    }

    var body: some View {
        @Bindable var store = store

        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text(isChinese ? "导出选项" : "Export Options")
                    .font(.headline)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // 内容区
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 待导出信息
                    HStack {
                        Image(systemName: "photo.stack")
                            .font(.title2)
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(isChinese ? "待导出资源" : "Assets to Export")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("\(store.pendingExportItems.count)")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                    // 分辨率选择（多选）
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(isChinese ? "选择导出分辨率" : "Select Export Resolutions")
                                .font(.headline)
                            Spacer()
                            Text(isChinese ? "可多选" : "Multi-select")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        // 提示：多选时会分目录导出
                        if store.exportScaleOptions.count > 1 {
                            HStack(spacing: 6) {
                                Image(systemName: "folder.badge.plus")
                                    .foregroundStyle(.orange)
                                Text(isChinese
                                    ? "多选时，每种分辨率将导出到单独的子目录"
                                    : "When multi-selecting, each resolution exports to a separate subdirectory")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.orange.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        ForEach(ExportScaleOption.allCases) { option in
                            ExportOptionCheckboxRow(
                                option: option,
                                isSelected: store.exportScaleOptions.contains(option),
                                action: {
                                    toggleOption(option)
                                }
                            )
                        }
                    }
                }
                .padding()
            }

            Divider()

            // 底部按钮
            HStack {
                Button(isChinese ? "取消" : "Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                // 显示选中数量
                if store.exportScaleOptions.count > 0 {
                    Text(isChinese
                        ? "已选 \(store.exportScaleOptions.count) 项"
                        : "\(store.exportScaleOptions.count) selected")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Button {
                    store.confirmExport()
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text(isChinese ? "开始导出" : "Export")
                    }
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(!hasSelection)
            }
            .padding()
        }
        .frame(width: 500, height: 580)
    }

    /// 切换选项的选中状态
    private func toggleOption(_ option: ExportScaleOption) {
        if store.exportScaleOptions.contains(option) {
            store.exportScaleOptions.remove(option)
        } else {
            // 如果选择了"全部"，清除其他选项
            if option == .all {
                store.exportScaleOptions = [.all]
            } else {
                // 如果选择了其他选项，移除"全部"
                store.exportScaleOptions.remove(.all)
                store.exportScaleOptions.insert(option)
            }
        }
    }
}

// MARK: - 导出选项行（复选框样式）
struct ExportOptionCheckboxRow: View {
    let option: ExportScaleOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // 复选框
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.title2)
                    .foregroundStyle(isSelected ? .blue : .secondary)

                // 图标
                Image(systemName: option.systemImage)
                    .font(.title3)
                    .foregroundStyle(isSelected ? .blue : .primary)
                    .frame(width: 28)

                // 文本
                VStack(alignment: .leading, spacing: 2) {
                    Text(option.localizedName)
                        .font(.body)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .foregroundStyle(.primary)

                    Text(option.hint)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                // 导出目录名预览
                if isSelected {
                    Text(option.directoryName)
                        .font(.caption)
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ExportOptionsSheet()
        .environment(AssetStore())
}
