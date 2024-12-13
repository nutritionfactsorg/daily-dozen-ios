# Thematic Elements - Dark, Light, Color

_Note: This is a historic check-in of some resources used circa 2022-2023._

This folder contains assets used in the location and assement of the dark & light mode thematic elements.

The purples assets are used find the hard coded elements which needed to be generalized and connected to the core assets via a common Daily Dozen specific color manager.

![](README_files/App-Icon-29@2x_Develop.png) ![](README_files/App-Icon-29@2x_Release.png)

| BrandGreen | hexadecimal | Red, Green, Blue     | Color     |
|------------|:-----------:|:--------------------:|:---------:|
| Develop    |  `#694cc0`  | `rgb(105, 76, 192)`  | ![cBGdev][] |
| Release    |  `#7fc04c`  | `rgb(127, 192, 76)`  | ![cBGrel][] |

``` swift
UIColor(red: 127/255, green: 192/255, blue: 76/255, alpha: 1)
```

[cBGdev]:README_files/color_BrandGreen_develop.png  
[cBGrel]:README_files/color_BrandGreen_release.png  

| IguanaGreen | hexadecimal | Red, Green, Blue     | Color        |
|-------------|:-----------:|:--------------------:|:------------:|
| Develop     |  `#a36cae`  | `rgb(163, 108, 174)` | ![cIGdev][]  |
| Release     |  `#6cae75`  | `rgb(108, 174, 117)` | ![cIGrel][]  |

``` swift
UIColor(red: 108/255, green: 174/255, blue: 117/255, alpha: 1)
```

[cIGdev]:README_files/color_IguanaGreen_develop.png
[cIGrel]:README_files/color_IguanaGreen_release.png

| LightGreen | hexadecimal | Red, Green, Blue     | Color     |
|------------|:-----------:|:--------------------:|:---------:|
| Develop    |  `#ab8ed7`  | `rgb(171, 142, 215)` | ![cLGdev][] |
| Release    |  `#aed78e`  | `rgb(174, 215, 142)` | ![cLGrel][] |

``` swift
UIColor(red: 174/255, green: 215/255, blue: 142/255, alpha: 1)
```

[cLGdev]:README_files/color_LightGreen_develop.png
[cLGrel]:README_files/color_LightGreen_release.png

_GraphicsMagick color replacement_

See script `script_color_shift_app_icons.sh`.

``` sh
gm convert room.jpg -fuzz 15% -fill '#84BE6A' -opaque '#d89060' room1.jpg
gm convert *.png -fuzz 15% -fill 'rgb(103, 78, 167)' -opaque 'rgb(103, 78, 167)' room1.jpg
```
