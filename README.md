# Associative Memory Mixer VST Plugin

This repository contains the code used to create the Associative Memory Mixer VST Plugin. It also
contains the plugin itself (associative-memory-mixer.vstsound).

This project contains 3 main code files:

1. **amm.lua** - *This is the main file loaded by the script. It requires mix.lua in order to work.
   Its main function is to declare the parameters used by the script and read the MIDI files
   indicated by the user.*

2. **mix.lua** - *This file contains all the logic necessary to mix the two motifs and generate a
   new one. This file depends on the last file, utils.lua.*

3. **utils.lua** - *This file contains functions that are required to perform the operations done in
   mix.lua Since the HALion Script environment does not provide convenience functions to work with
   matrices, this file is required.*

In order to use the plugin (associative-memory-mixer.vstsound), it is required to install **HALion
Sonic SE 3** (a free sound library software). In order to install **HALion Sonic SE 3** it is
necessary to install the **eLicenser Control Center** and the **Steinberg Library Manager** (all
owend by Steinberg). Once the previous programs have been installed, simply click on the .vstsound
file. The **Steinberg Library Manager** should pop up and offer to install the package. After
installing the plugin, it will appear as a virtual instrument inside **HALion Sonic SE 3**.

**Note**: If having problems finding the Associative Memory Mixer, try to use the filter for Layers
instead of Programs

In order to create your own VST plugin instrument using this code as a base, you will require HALion.
Take a look at
the [HALion Script Home](https://developer.steinberg.help/display/HSD/HALion+Script+Home) page for
more details.

The file called *associative-memory-mixer-macro-page.xml* describes the user interface of the
plugin. It is not meant to be modified directly, instead HALion should be used. It is included in
the project for the sake of completeness, as the scripts expect parameter values indicated through
this user interface.
