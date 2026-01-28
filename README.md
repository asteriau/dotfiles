<h1 align="center">dotfiles</h1>
<h4 align="center">.files for everything i use</h4>

<div align="center"> 
<a href="https://github.com/asteriau/dotfiles/stargazers"><img src="https://img.shields.io/github/stars/asteriau/dotfiles?colorA=151515&colorB=8DA3B9&style=for-the-badge&logo=starship"></a>
<a href="https://github.com/asteriau/dotfiles/issues"><img src="https://img.shields.io/github/issues/asteriau/dotfiles?colorA=151515&colorB=8DA3B9&style=for-the-badge&logo=ifixit"></a>
<a href="https://github.com/asteriau/dotfiles/network/members"><img src="https://img.shields.io/github/forks/asteriau/dotfiles?colorA=151515&colorB=8DA3B9&style=for-the-badge&logo=github"></a>
</a>
</div>

## Deprecation warning
hi this is all very shitty and old gonna rewrite it all in quickshell at some point
if stuff broke uhhhhh gl

## Gallery 📸
  <p align="center">
  <img src=https://i.imgur.com/Fn79aGd.png">
  <img src="https://i.imgur.com/7bb9mON.png">

## Info 📖
These are my personal dotfiles which form the desktop you see above. It uses the [Paradise](https://github.com/paradise-theme/paradise) color scheme.

  • **OS**: Arch Linux <br>
  • **Window Manager / Compositor**: [Hyprland](https://github.com/hyprwm/Hyprland) <br>
  • **Status Bar**: [Waybar](https://github.com/Alexays/Waybar) <br>
  • **Notifications**: [dunst](https://github.com/dunst-project/dunst) <br>
  • **Terminal**: [kitty](https://github.com/kovidgoyal/kitty) <br>
  • **Launcher**: [rofi](https://github.com/davatorium/rofi/) <br>
 


## Installation 🔧
> [!NOTE]
> The packages listed are for arch. Depending on your distribution, the names of the packages below may slightly differ. Also, some of the packages might not be available in your distribution's repositories so you might have to build them from source.

    sudo pacman -S hyprland waybar dunst kitty rofi-wayland swww nautilus grim slurp firefox wl-clipboard pavucontrol pamixer playerctl python-gobject zsh gammastep unzip --needed
    yay -S notify-send.sh
1. **Clone the repo & Apply configs:**
    ```sh
    git clone https://github.com/asteriau/dotfiles
    cd dotfiles
    cp -r config/{hypr,waybar,dunst,kitty,rofi,gtk-3.0,xsettingsd} ~/.config
    ```

2. **Move folders**  

    ```sh
    # Scripts folder
    mv ~/dotfiles/bin/* ~/.local/share/bin/
    chmod -R +x ~/.local/share/bin/
    # Home folder
    cp -a ~/dotfiles/home/. ~/
    ```

3. **Install fonts**  

    I have uploaded a [.zip file to Dropbox](https://www.dropbox.com/scl/fi/5jlq2wcfd62utippn4bo4/asteria-dotfiles-fonts.zip?rlkey=qo79l4j985zn89rmcfh6zlsi8&st=vkgkm7qt&dl=0) to save you some time. <br> 
    To make your life easier you should be in hyprland by this point. <br>
    Download the .zip and then:

    ```sh
    # Assuming the .zip was saved in ~/Downloads
    unzip -d ~/.local/share/fonts ~/Downloads/asteria-dotfiles-fonts.zip
    fc-cache -v
    ```

4. **Change shell to Zsh**

   ```sh
   chsh -s /usr/bin/zsh
   ```

5. **Set wallpaper**  

    ```sh
    swww img ~/dotfiles/home/wallpapers/somewallpaper.png
    ```

If you followed all the steps correctly you should now be good to go. You might wanna reboot for everything to apply. <br>
There's also a [extra](https://github.com/asteriau/dotfiles/tree/main/extra) folder you might wanna check out which holds themes for various apps. <br>

## Special Thanks 🫂
• [manas140](https://github.com/manas140) For making [this beautiful color scheme](https://github.com/paradise-theme/paradise)

• [elenapan](https://github.com/elenapan) For some miscellaneous files i used

## TO-DO:
- [ ] Make a actually good install script & re-write the readme with it in mind
- [ ] add more stuff to extras and make it be a option in the install script
- [ ] re-write every config cuz they're lowk all dogshit
- [ ] finish quickshell config 10 years from now



