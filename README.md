# What is Nekometer?

> **⚠️ DEPRECATION NOTICE**: This addon is no longer under active development. Users are encouraged to switch to the Blizzard built-in damage meter for future updates and support.

**Nekometer** is an alternative, minimalist damage meter addon. I have originally developed this addon for personal use as a hobby project. After using it for a while, I have decided to share it in case someone else finds it useful.

Why did I develop my own damage meter addon instead of using an existing popular addon from the list of available ones?

There are several reasons:

   * I wanted to develop an addon for fun and personal enjoyment
   * I've found the existing similar addons too bloated for my taste
   * I like to use the default WoW UI with as little modifications as possible, but I still wanted to have a basic idea of my character's throughput
   

# Addon philosophy

When developing the addon, the following were taken into consideration:

   * small feature set
   * clean, simple, non-intrusive interface
   * simple settings, with sensible defaults
   * small, readable, open code base
   * should have a minimal impact on system resources

I've decided **not to add** some features to keep the addon minimal:

   * logging/reporting to file, chat, sharing the data
   * fancy graphics, charts
   * complex configuration options, startup wizards
   * multiple windows

A lot of features other similar addons support are missing, often intentionally. It is important to remember, that it is not the goal for this addon to compete with those addons, but to provide a minimalist alternative for those who do not want to use them for any reason.

# Usage, commands

### Main Commands

You can use the following commands from the chat window:

*   /nm config: open the settings window (you can also use the game menu)
*   /nm toggle: show/hide the nekometer window
*   /nm reset: reset the meters (you can also use the reset button on the nekometer toolbar)
*   /nm center: reposition the main window to the center of the screen
*   /nm wipe: reset all nekometer settings to the default

### Meters

Currently the following meters can be enabled/disabled:

   * damage
   * dps
   * healing
   * damage breakdown
   * healing breakdown
   * deaths
   * interrupts
   * dispels
   * overhealing

### Settings

Here are some of the most useful features that you can tweak in the addon's settings:

   * Enable/disable individual meters (disabled meters don't consume any resources)
   * Lock window (prevents move & resize)
   * Use class colors for bars
   * Merge pets with their owners
   * Auto hide
   * Auto reset
   * Show/hide position
   * Show/hide class and ability icons
   

# Feedback

Please report issues using the GitHub issue tracker.

# Contribution

The source code is free and open-source. You can access it from the "Source" tab.