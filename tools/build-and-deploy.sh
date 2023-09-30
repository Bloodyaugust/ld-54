#!/bin/sh

# set -e

which butler

echo "Checking application versions..."
echo "-----------------------------"
cat ~/.local/share/godot/templates/4.0-rc2/version.txt
godot --version
butler -V
echo "-----------------------------"

mkdir build/
mkdir build/linux/
mkdir build/osx/
mkdir build/win/

echo "EXPORTING FOR LINUX"
echo "-----------------------------"
godot --headless --export-debug "Linux/X11" build/linux/ld-54-4.x86_64 -v
# echo "EXPORTING FOR OSX"
# echo "-----------------------------"
# godot --export "Mac OSX" build/osx/ld-54-4.dmg -v
echo "EXPORTING FOR WINDOZE"
echo "-----------------------------"
godot --headless --export-debug "Windows Desktop" build/win/ld-54-4.exe -v
echo "-----------------------------"

# echo "CHANGING FILETYPE AND CHMOD EXECUTABLE FOR OSX"
# echo "-----------------------------"
# cd build/osx/
# mv ld-54-4.dmg ld-54-4-osx-alpha.zip
# unzip ld-54-4-osx-alpha.zip
# rm ld-54-4-osx-alpha.zip
# chmod +x ld-54-4.app/Contents/MacOS/ld-54-4
# zip -r ld-54-4-osx-alpha.zip ld-54-4.app
# rm -rf ld-54-4.app
# cd ../../

ls -al
ls -al build/
ls -al build/linux/
ls -al build/osx/
ls -al build/win/

echo "ZIPPING FOR WINDOZE"
echo "-----------------------------"
cd build/win/
zip -r ld-54-4-win-alpha.zip ld-54-4.exe ld-54-4.pck
rm -r ld-54-4.exe ld-54-4.pck
cd ../../

echo "ZIPPING FOR LINUX"
echo "-----------------------------"
cd build/linux/
zip -r ld-54-4-linux-alpha.zip ld-54-4.x86_64 ld-54-4.pck
rm -r ld-54-4.x86_64 ld-54-4.pck
cd ../../

echo "Logging in to Butler"
echo "-----------------------------"
butler login

echo "Pushing builds with Butler"
echo "-----------------------------"
butler push build/linux/ synsugarstudio/ld-54:linux-alpha
# butler push build/osx/ synsugarstudio/ld-54:osx-alpha
butler push build/win/ synsugarstudio/ld-54:win-alpha
