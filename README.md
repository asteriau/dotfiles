<div align="center">
    <img src="https://files.catbox.moe/n4ydnt.png">
</div>

<hr style="width:40%;">

<div align="center"> 
<a href="https://github.com/Manas140/dotfiles/stargazers"><img src="https://img.shields.io/github/stars/Manas140/dotfiles?colorA=151515&colorB=8DA3B9&style=for-the-badge&logo=starship"></a>
<a href="https://github.com/Manas140/dotfiles/issues"><img src="https://img.shields.io/github/issues/Manas140/dotfiles?colorA=151515&colorB=8DA3B9&style=for-the-badge&logo=ifixit"></a>
<a href="https://github.com/Manas140/dotfiles/network/members"><img src="https://img.shields.io/github/forks/Manas140/dotfiles?colorA=151515&colorB=8DA3B9&style=for-the-badge&logo=github"></a>
</a>
</div>

## Gallery 📸
  <p align="center">
  <img src="https://files.catbox.moe/tzz3cn.png">

## Info 📖
These are my personal dotfiles which form the desktop you see above.

Let's get the boring stuff out of the way :

  ✦ **OS** · Arch Linux <br>
  ✦ **Window Manager / Compositor** · [Hyprland](https://github.com/hyprwm/Hyprland) <br>
  ✦ **Status Bar** · [Waybar](https://github.com/Alexays/Waybar) <br>
  ✦ **Notifications** · [dunst](https://github.com/dunst-project/dunst) <br>
  ✦ **Terminal** · [kitty](https://github.com/kovidgoyal/kitty) <br>
  ✦ **Launcher** · [rofi](https://github.com/davatorium/rofi/) <br>
 


## Installation 🔧
> [!NOTE]
> The packages listed are for arch. Depending on your distribution, the names of the packages below may slightly differ. Also, some of the packages might not be available in your distribution's repositories so you might have to build them from source.

    sudo pacman -S hyprland waybar dunst kitty rofi-wayland swww nautilus grim slurp wl-clipboard pavucontrol pamixer playerctl --needed
1. **Clone the repo & Apply configs:**
    ```sh
    git clone https://github.com/asteriau/dotfiles
    cd dotfiles
    cp -r config/{hypr,waybar,dunst,kitty,rofi} ~/.config
    ```

2. **Install fonts**  

    I have uploaded a [.zip file to Dropbox](https://www.dropbox.com/scl/fi/j8zna9d6bls3kl8xm1mq9/asteriadots-fonts.zip?rlkey=7g76krtpvi86ecbafnvy1jmuy&st=a8jdisrz&dl=0) to save you some time. Download the .zip and then:

    ```sh
    # Assuming the .zip was saved in ~/Downloads
    unzip -d ~/.local/share/fonts ~/Downloads/asteriadots-fonts.zip
    fc-cache -v
    ```

3. **Move scripts folder**  

    ```sh
    mkdir -p ~/.local/share/bin # Assuming it doesn't exist yet
    mv ~/dotfiles/bin/ ~/.local/share/bin
    chmod -R u+rwx ~/.local/share/bin
    ```

4. **Set your wallpaper**  

    ```sh
    swww img /path/to/some/wallpaper.someformat
    ```

You're now all set. You might want to reboot after you completed the steps for everything to work properly.


## Tip Jar 💗

If you enjoy using these dotfiles or parts of them and would like to show your appreciation, you may leave a tip here or star the repository.  
It is never required but always appreciated.  
Thank you from the bottom of my heart! 💙  

- [**Ko-Fi**](https://ko-fi.com/asteriau)  
- **Litecoin**: LhV2kkvj6uHiLABAhkXCrcYHx6ALknDZr3  
- **Bitcoin**: bc1q73qudet3a9f8p2yht8mums983zqgl9924spqn0
- **Monero** 4B73quPWrpR9ke7cstyHYWameQuoJjLVUHaEruGk9E2cUrZsGHkVRnbehFgUB6wKQWh69a7fuexmr6fraytJgB5bNSLSzWv
