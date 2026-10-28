# Backlight - Setup Instructions

This script opens a small Windows app for changing the HP keyboard-backlight settings. This works only well with HP Elitebook(It is tested with Elitebook 845 g11). Also ensure your laptop has lux sensor(my unit had it)

## 1. Save the script

1. Open Notepad.
2. Paste the working PowerShell script.
3. Save it as:

   `C:\Users\USER\Backlight\Backlight.ps1`
*Remember to use the path of the file you are using*
   Set **Save as type** to **All files** so it is not saved as `Backlight.ps1.txt`.

## 2. Test the app

Press `Win + R`, paste the command below, and press Enter:

```
powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File "C:\Users\KIIT\Backlight\Backlight.ps1"
```

Check that the Backlight window opens and that **Refresh** and **Apply** work.

## 3. Start it automatically when you sign in

1. Press `Win + R`.
2. Type `shell:startup` and press Enter.
3. In the folder that opens, right-click an empty area and choose **New → Shortcut**.
4. For the shortcut location, paste:

   ```
   powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File "C:\Users\KIIT\Backlight\Backlight.ps1"
   ```

5. Click **Next**, name it `Backlight`, then click **Finish**.

The app should now open each time you sign in to Windows.

## Notes

- This starts the app; it does **not** automaticaly press **Apply** or change the BIOS settings by itself.
- If applying settings fails because of permissions, close the app and run PowerShell with the required administrator permissions.
- Keep the script at the same path unless you also update the shortcut.

To test if your laptop has lux sensor use the below code in Powershell:
```
Add-Type -AssemblyName System.Runtime.WindowsRuntime

try {
    $sensor = [Windows.Devices.Sensors.LightSensor,Windows,ContentType=WindowsRuntime]::GetDefault()

    if ($null -eq $sensor) {
        Write-Host "No ambient light sensor exposed to Windows."
    } else {
        for ($i = 1; $i -le 10; $i++) {
            $reading = $sensor.GetCurrentReading()

            if ($null -ne $reading) {
                Write-Host ("Light: {0:N2} lux" -f $reading.IlluminanceInLux)
            } else {
                Write-Host "No reading available yet."
            }

            Start-Sleep -Seconds 2
        }
    }
} catch {
    Write-Host "Sensor test failed:"
    Write-Host $_.Exception.Message
}
```

# Please give it a star 
