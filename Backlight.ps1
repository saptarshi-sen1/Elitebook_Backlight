
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ns = "root\HP\InstrumentedBIOS"

$form = New-Object System.Windows.Forms.Form
$form.Text = "Backlight"
$form.Size = New-Object System.Drawing.Size(420, 390)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)

$title = New-Object System.Windows.Forms.Label
$title.Text = "Backlight"
$title.Font = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
$title.Location = New-Object System.Drawing.Point(22, 18)
$title.Size = New-Object System.Drawing.Size(350, 38)
$form.Controls.Add($title)

$subtitle = New-Object System.Windows.Forms.Label
$subtitle.Text = "HP Keyboard Settings"
$subtitle.Location = New-Object System.Drawing.Point(25, 58)
$subtitle.Size = New-Object System.Drawing.Size(340, 24)
$form.Controls.Add($subtitle)

$auto = New-Object System.Windows.Forms.CheckBox
$auto.Text = "Enable automatic keyboard backlight"
$auto.Location = New-Object System.Drawing.Point(25, 105)
$auto.Size = New-Object System.Drawing.Size(350, 28)
$form.Controls.Add($auto)

$label = New-Object System.Windows.Forms.Label
$label.Text = "Backlight timeout"
$label.Location = New-Object System.Drawing.Point(25, 155)
$label.Size = New-Object System.Drawing.Size(350, 25)
$form.Controls.Add($label)

$timeout = New-Object System.Windows.Forms.ComboBox
$timeout.Location = New-Object System.Drawing.Point(25, 185)
$timeout.Size = New-Object System.Drawing.Size(345, 30)
$timeout.DropDownStyle = "DropDownList"
$form.Controls.Add($timeout)

$status = New-Object System.Windows.Forms.Label
$status.Location = New-Object System.Drawing.Point(25, 235)
$status.Size = New-Object System.Drawing.Size(350, 42)
$status.Text = "Loading settings..."
$form.Controls.Add($status)

$refresh = New-Object System.Windows.Forms.Button
$refresh.Text = "Refresh"
$refresh.Location = New-Object System.Drawing.Point(25, 295)
$refresh.Size = New-Object System.Drawing.Size(100, 35)
$form.Controls.Add($refresh)

$apply = New-Object System.Windows.Forms.Button
$apply.Text = "Apply"
$apply.Location = New-Object System.Drawing.Point(265, 295)
$apply.Size = New-Object System.Drawing.Size(105, 35)
$form.Controls.Add($apply)

function Get-HPSettings {
    Get-CimInstance -Namespace $ns -ClassName HPBIOS_BIOSEnumeration
}

function Read-Backlight {
    try {
        $settings = @(Get-HPSettings)
        $a = $settings | Where-Object Name -eq "Automatic Keyboard Backlit" | Select-Object -First 1
        $t = $settings | Where-Object Name -eq "Backlit keyboard timeout" | Select-Object -First 1

        if (-not $a -or -not $t) {
            throw "Required HP BIOS settings were not found."
        }

        $auto.Checked = ($a.CurrentValue -eq "Enable")

        $timeout.Items.Clear()
        foreach ($v in $t.PossibleValues) {
            $v = ([string]$v).Trim().TrimStart('*')
            if ($v) { [void]$timeout.Items.Add($v) }
        }

        $currentTimeout = ([string]$t.CurrentValue).Trim().TrimStart('*')
        if ($timeout.Items.Contains($currentTimeout)) {
            $timeout.SelectedItem = $currentTimeout
        } elseif ($timeout.Items.Count -gt 0) {
            $timeout.SelectedIndex = 0
        }

        $status.Text = "Current settings loaded."
    } catch {
        $status.Text = "Could not read HP settings: " + $_.Exception.Message
    }
}

function Set-HPSetting($settingName, $value) {
    $interface = Get-CimInstance -Namespace $ns -ClassName HP_BIOSSettingInterface |
        Select-Object -First 1

    if (-not $interface) {
        throw "HP BIOS setting interface not found."
    }

    $result = Invoke-CimMethod -InputObject $interface `
        -MethodName SetBIOSSetting `
        -Arguments @{ Name = $settingName; Value = $value }

    if ($null -eq $result.Return -or [int]$result.Return -ne 0) {
        throw "HP rejected '$settingName'. Return code: $($result.Return)"
    }
}

$refresh.Add_Click({ Read-Backlight })

$apply.Add_Click({
    $apply.Enabled = $false
    try {
        $targetAuto = if ($auto.Checked) { "Enable" } else { "Disable" }
        $settings = @(Get-HPSettings)
        $a = $settings | Where-Object Name -eq "Automatic Keyboard Backlit" | Select-Object -First 1
        $t = $settings | Where-Object Name -eq "Backlit keyboard timeout" | Select-Object -First 1

        if (-not $a -or -not $t -or $null -eq $timeout.SelectedItem) {
            throw "Settings are unavailable. Click Refresh and try again."
        }

        if ($a.CurrentValue -ne $targetAuto) {
            Set-HPSetting "Automatic Keyboard Backlit" $targetAuto
        }

        $targetTimeout = [string]$timeout.SelectedItem
        if ($t.CurrentValue -ne $targetTimeout) {
            Set-HPSetting "Backlit keyboard timeout" $targetTimeout
        }

        Read-Backlight
        $status.Text = "Settings applied successfully."
        [System.Windows.Forms.MessageBox]::Show(
            "Your keyboard-backlight settings have been applied.",
            "Backlight",
            "OK",
            "Information"
        ) | Out-Null
    } catch {
        $status.Text = "Could not apply settings."
        [System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            "Backlight - Error",
            "OK",
            "Error"
        ) | Out-Null
    } finally {
        $apply.Enabled = $true
    }
})

Read-Backlight
[void]$form.ShowDialog()
