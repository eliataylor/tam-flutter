#!/bin/sh
base=$1

#!/bin/sh
base=$1
dest=${2:-'ios/Runner/Assets.xcassets/AppIcon.appiconset'}
androidDes=${3:-'android/app/src/main/res'}


if [ -z $base ]
  then
    echo No argument given
else
  ##
  ## iOS files
  # convert -density 1536 -background none "$base" -resize 512x512!     "logo-512-512.png"
  convert -density 1536 -background none "$base" -resize 20x20!     "$dest/Icon-20.png"
  convert -density 1536 -background none "$base" -resize 29x29!     "$dest/Icon-Small.png"
  convert -density 1536 -background none "$base" -resize 40x40!     "$dest/Icon-Small-40.png"
  convert -density 1536 -background none "$base" -resize 50x50!     "$dest/Icon-Small-50.png"
  convert -density 1536 -background none "$base" -resize 57x57!     "$dest/Icon.png"
  convert -density 1536 -background none "$base" -resize 58x58!     "$dest/Icon-Small@2x.png"
  convert -density 1536 -background none "$base" -resize 87x87!     "$dest/Icon-Small@3x.png"
  convert -density 1536 -background none "$base" -resize 60x60!     "$dest/Icon-60.png"
  convert -density 1536 -background none "$base" -resize 72x72!     "$dest/Icon-72.png"
  convert -density 1536 -background none "$base" -resize 76x76!     "$dest/Icon-76.png"
  convert -density 1536 -background none "$base" -resize 80x80!     "$dest/Icon-Small-40@2x.png"
  convert -density 1536 -background none "$base" -resize 100x100!   "$dest/Icon-Small-50@2x.png"
  convert -density 1536 -background none "$base" -resize 114x114!   "$dest/Icon@2x.png"
  convert -density 1536 -background none "$base" -resize 120x120!   "$dest/Icon-60@2x.png"
  convert -density 1536 -background none "$base" -resize 144x144!   "$dest/Icon-72@2x.png"
  convert -density 1536 -background none "$base" -resize 152x152!   "$dest/Icon-76@2x.png"
  convert -density 1536 -background none "$base" -resize 167x167!   "$dest/Icon-83.5@2x.png"
  convert -density 1536 -background none "$base" -resize 180x180!   "$dest/Icon-60@3x.png"
  convert -density 1536 -background none "$base" -resize 512x512!   "$dest/iTunesArtwork"
  convert -density 1536 -background none "$base" -resize 1024x1024! "$dest/iTunesArtwork@2x"
  ##
  ## Apple Watch
  ## Guidelines: https://developer.apple.com/design/human-interface-guidelines/watchos/icons-and-images/home-screen-icons/
  convert -density 1536 -background none "$base" -resize 48x48!     "$dest/Icon-Watch-38mm@2x.png"
  convert -density 1536 -background none "$base" -resize 55x55!     "$dest/Icon-Watch-40mm@2x.png"
  convert -density 1536 -background none "$base" -resize 80x80!     "$dest/Icon-WatchHome-40@2x.png"
  convert -density 1536 -background none "$base" -resize 88x88!     "$dest/Icon-WatchHome-44@2x.png"
  convert -density 1536 -background none "$base" -resize 100x100!   "$dest/Icon-WatchHome-50@2x.png"
  convert -density 1536 -background none "$base" -resize 48x48!     "$dest/Icon-WatchNotification-24@2x.png"
  convert -density 1536 -background none "$base" -resize 55x55!     "$dest/Icon-WatchNotification-27.5@2x.png"
  convert -density 1536 -background none "$base" -resize 58x58!     "$dest/Icon-WatchNotification-29@2x.png"
  convert -density 1536 -background none "$base" -resize 172x172!   "$dest/Icon-WatchShortNotification-86@2x.png"
  convert -density 1536 -background none "$base" -resize 196x196!   "$dest/Icon-WatchShortNotification-98@2x.png"
  convert -density 1536 -background none "$base" -resize 216x216!   "$dest/Icon-WatchShortNotification-108@2x.png"
  convert -density 1536 -background none "$base" -resize 58x58!     "$dest/Icon-WatchCompanion-29@2x.png"
  convert -density 1536 -background none "$base" -resize 87x87!     "$dest/Icon-WatchCompanion-29@3x.png"
  ##

  ## Android files
  convert -density 1536 -background none "$base" -resize 72x72!    "$androidDes/mipmap-hdpi/ic_launcher.png"
  convert -density 1536 -background none "$base" -resize 48x48!    "$androidDes/mipmap-mdpi/ic_launcher.png"
  convert -density 1536 -background none "$base" -resize 96x96!    "$androidDes/mipmap-xhdpi/ic_launcher.png"
  convert -density 1536 -background none "$base" -resize 144x144!  "$androidDes/mipmap-xxhdpi/ic_launcher.png"
  convert -density 1536 -background none "$base" -resize 192x192!  "$androidDes/mipmap-xxxhdpi/ic_launcher.png"
fi
