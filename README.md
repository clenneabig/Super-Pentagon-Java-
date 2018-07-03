# Super-Pentagon-Java-
My Super Pentagon game using the Processing libraries for Java in the Processing IDE

Design Help by Dylan Wansbrough

The Windows 64 bit version has Java embeded. For the other versions, you may need to download and install 
Java 8.

To download just the folder with the executable that you want, You need to use either Linux or the Windows 
Linux Subsystem. In the terminal, make sure you have svn installed by typing `sudo apt install subversion` 
Once that has installed, type `svn checkout https://github.com/clennedani/Super-Pentagon-Java-/Executables/[Name of executable folder]` 
into your terminal and the folder will download to the current directory.

If you would like to save high score times between releases, navagate to the folder with the executable, 
go to the `data` folder and copy the highScore txt files to somewhere, and then when you download the new 
release, put them back in the `data` folder

To launch the game on Windows, navigate the Executables folder, go to the application.windowsXX folder,
where XX is either 32 for x86 systems or 64 for x86_64 systems, double click on Main.exe and the game will 
launch.

To launch the game on Linux, navigate to the Executables folder, if using an x86 or x86_64 system go to either 
application.linuxXX where XX is either 32 for x86 systems or 64 for x86_64 systems, or if you are using an ARMv6 
with a hardware floating point unit, go to application.linux-armv6hf or if you're using an ARM 64-bit system 
go to application.linux-arm64, in the terminal type ./Main to run it.