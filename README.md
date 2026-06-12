# Bluetooth Configurator - A KOReader plugin for Android to configure page turners


## **⚠ BETA — ANDROID ONLY**
>This plugin is **Android** only. Have a Kobo? Try [this](https://github.com/onatbas/bluetooth.koplugin) plugin instead!
>
> **This plugin is in beta. Back up your KOReader directory before installing.**
> It patches KOReader's input handler at runtime and may cause instability.

---

Bluetooth Configurator is a KOReader plugin that lets you easily and intuitively map Bluetooth game controller and page turner buttons to actions within the reader. Not only is this far easier then the official way of using [keymapping](https://github.com/koreader/koreader/wiki/Android-tips-and-tricks#customize-keys), but it provides for more controlls then keymapping allows. It supports standard media keys as well as D-pad/joystick controllers. 

It has been verified to work with both [8BitDo Micro](https://www.8bitdo.com/micro/) as well as a few generic page turners such as [this](https://www.amazon.com/dp/B0B6RBHJFY?ref_=ppx_hzsearch_conn_dt_b_fed_asin_title_3) one, although it should support any similar controller. 

<img src="demo.gif" height="400" /><img height="400" alt="Screenshot_20260611_235123_blurred" src="https://github.com/user-attachments/assets/f8879974-98c3-4f29-898e-1293f69e20a4" /><img height="400" alt="Screenshot_20260611_235129" src="https://github.com/user-attachments/assets/9807d1db-5434-4303-b093-fbe760377932" />


## Requirements

- KOReader on **Android** (not supported on Kindle, Kobo, or other platforms)
- A Bluetooth page turner or controller

## Installation

1. Download or clone this repository
2. Copy the `bluetoothconfigurator.koplugin` folder into your KOReader `plugins` directory
3. Restart KOReader
4. Open a book, then go to the top menu → **Plugins** → **Configure Bluetooth Controls**

## Usage

Open a book and access **Plugins → Configure Bluetooth Controls** to set up your bindings.

- Tap **Add Binding** to create a new binding
- Tap **"tap to set..."**. The plugin will begin listening for your controller.
- Press the desired button you want to pair. The plugin will capture its keycode. 
- Select the action you want it to trigger
- Use the "x" icon to remove a binding

Bindings are saved automatically and persist across sessions.

## Supported Actions

Actions are grouped into the following categories:

- **Navigation** — page turns, chapters, go to page, skim, back, location history
- **Bookmarks** — toggle, view, search, previous/next bookmark
- **Display** — night mode, font size, frontlight, status bar, screen refresh
- **Reader** — table of contents, menus, search, book info, translate, screenshot
- **Library** — file browser, history, favorites, collections, dictionary/Wikipedia lookup
- **Device** — Wi-Fi toggle, sleep

## Notes

- D-pad controllers are supported. The plugin maps joystick axis events (AXIS_X/AXIS_Y) to directional keycodes.
- The plugin only appears in the menu when a book is open.

## Testers Needed
As this plugin is in beta, testers are needed and appreciated! If you run into any controllers or actions that don't work, or other problems, don't hesitate to create an issue. I am a big propnent of accessibility and want this plugin to work perfectly for everyone. Page turners have been a life saver for me. 

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## AI Disclosure

This plugin was developed with the assistance of [Claude Code](https://claude.ai/code) (Anthropic). All code was reviewed and tested by the author.
