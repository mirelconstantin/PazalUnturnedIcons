Add-Type -AssemblyName System.Drawing

$paddingFactor = 1.25
$files = Get-ChildItem -Path . -Filter "*.png" -Recurse -File

foreach ($file in $files) {
    try {
        $img = [System.Drawing.Image]::FromFile($file.FullName)
        
        $maxDim = [Math]::Max($img.Width, $img.Height)
        $newDim = [int]($maxDim * $paddingFactor)
        
        $newImg = New-Object System.Drawing.Bitmap($newDim, $newDim)
        $g = [System.Drawing.Graphics]::FromImage($newImg)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        
        $x = ($newDim - $img.Width) / 2
        $y = ($newDim - $img.Height) / 2
        
        $g.Clear([System.Drawing.Color]::Transparent)
        $g.DrawImage($img, $x, $y, $img.Width, $img.Height)
        
        $g.Dispose()
        $img.Dispose()
        
        # Save temp file then replace
        $tempPath = $file.FullName + ".tmp"
        $newImg.Save($tempPath, [System.Drawing.Imaging.ImageFormat]::Png)
        $newImg.Dispose()
        
        Remove-Item -Path $file.FullName -Force
        Rename-Item -Path $tempPath -NewName $file.Name
        
        Write-Host "Resized $($file.Name)"
    } catch {
        Write-Host "Failed to process $($file.Name): $_"
    }
}
