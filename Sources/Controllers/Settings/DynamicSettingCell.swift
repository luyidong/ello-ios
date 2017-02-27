////
///  DynamicSettingCell.swift
//

@objc
protocol DynamicSettingCellResponder: class {
    func toggleSetting(_ setting: DynamicSetting, value: Bool)
    func deleteAccount()
}

class DynamicSettingCell: UITableViewCell {

    @IBOutlet weak var titleLabel: StyledLabel!
    weak var descriptionLabel: StyledLabel!
    @IBOutlet weak var toggleButton: ElloToggleButton!
    @IBOutlet weak var deleteButton: ElloToggleButton!

    var setting: DynamicSetting?

    @IBAction func toggleButtonTapped() {
        guard let setting = setting else { return }

        let responder = target(forAction: #selector(DynamicSettingCellResponder.toggleSetting(_:value:)), withSender: self) as? DynamicSettingCellResponder
        responder?.toggleSetting(setting, value: !toggleButton.value)
        toggleButton.value = !toggleButton.value
    }

    @IBAction func deleteButtonTapped() {
        let responder = target(forAction: #selector(DynamicSettingCellResponder.toggleSetting(_:value:)), withSender: self) as? DynamicSettingCellResponder
        responder?.deleteAccount()
    }
}
