# bluetoothconfigurator.koplugin

## **⚠ BETA — ANDROID ONLY**

> **This plugin is in beta. Back up your KOReader directory before installing.**
> It patches KOReader's input handler at runtime and may cause instability.

---

A KOReader plugin that lets you easily and intuitively map Bluetooth controller and page turner buttons to reader actions. Not only is this far easier then the reccomended way of usin [keymapping](https://github.com/koreader/koreader/wiki/Android-tips-and-tricks#customize-keys), but it provides for more controlls then keymapping allows. It supports standard media keys as well as D-pad/joystick controllers. 

It has been verified to work with both [8BitDo Micro](https://www.8bitdo.com/micro/) as well as a few generic page turners such as [this](https://www.amazon.com/dp/B0B6RBHJFY?ref_=ppx_hzsearch_conn_dt_b_fed_asin_title_3) one, although it should support any similar controller. 

<img width="150" alt="Screenshot_20260611_235123_blurred" src="https://github.com/user-attachments/assets/f8879974-98c3-4f29-898e-1293f69e20a4" />
<img width="150" alt="Screenshot_20260611_235129" src="https://github.com/user-attachments/assets/9807d1db-5434-4303-b093-fbe760377932" />


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

- Tap **Add Button** to create a new binding
- Press the button on your page turner to capture its keycode
- Select the action you want it to trigger
- Use the trash icon to remove a binding

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
- If the plugin disappears from the menu after a crash, re-enable it via **Plugins → Plugin Management**.
