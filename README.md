pacman_Aria2c_wrapper
=====================

A wrapper for pacman using Aria2c to download update files.

Version 0.01

Features:
Syncs repos before updating as a rule
Displays the updates as a tabulated list as compared to original pacman display of the updates, with version number of the updates and its repository.
Uses Aria2c to download the files and pacman to update.

Planned:
Currently there is no logging, serial numbering for the updates.
Providing option for no sync

========

Version 0.02

Additional Features:
Adding serial numbering during display of the updates. Display total number of files to be upgraded.

Planned:
Logging
Saving previous updates as compressed tar file to save space.
Providing option for no sync