const fs = require("fs");
const execSync = require("child_process").execSync;

const devices = {
    "6.7" : ["1290x2796"],
    "6.5" : ["1242x2688", "1284x2778"],
    "5.5" : ["1242x2208"],
    "12.9" : ["2048x2732"]
}


function buildiOSIcons(appName, bgColor) {
    const src_icon = `launch_icon_${appName}.png`;
    const dest_dir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';

    let contents = JSON.parse(fs.readFileSync('ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json', 'utf8'));
    contents.images.forEach(img => {
        if (typeof img.filename === 'undefined') {
            img.filename = `${img.idiom}-${img.size.replaceAll('.', '_')}@${img.scale}.png`;
        }
        let realsize = img.size.split('x');
        let scale = parseInt(img.scale.charAt(0));
        realsize[0] = realsize[0] * scale;
        realsize[1] = realsize[1] * scale;
        let cmd = `convert -density 96 ${src_icon} -background '${bgColor}' -alpha remove -alpha off -resize ${realsize.join('x')} "${dest_dir}/${img.filename}"`
        console.log(cmd);
        execSync(cmd);
    })
    fs.writeFileSync('ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json', JSON.stringify(contents, null, 2), 'utf8');
}

function buildiOSLaunchScreens(appName, bgColor) {
    const src_launch_screen = `launch_screen_${appName}.png`;
    const dest_dir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';

    const contents = JSON.parse(fs.readFileSync('ios/Runner/Assets.xcassets/LaunchImage.imageset/Contents.json', 'utf8'));
    contents.images.forEach(img => {
        if (typeof img.filename === 'undefined') {
            img.filename = `${img.idiom}-${img.size.replaceAll('.', '_')}@${img.scale}.png`;
        }
        let percent = parseInt(img.scale.charAt(0)) * 100;
        let cmd = `convert ${src_launch_screen} -background '${bgColor}' -alpha remove -alpha off -resize ${percent}% "${dest_dir}/${img.filename}"`
        if (percent === 100) {
            // cmd = `cp ${src_launch_screen} ${dest_dir}/${img.filename}`
        }
        console.log(cmd);
        execSync(cmd);
    })
    fs.writeFileSync('ios/Runner/Assets.xcassets/LaunchImage.imageset/Contents.json', JSON.stringify(contents, null, 2), 'utf8');
}

function buildAndroidIcons(appName, bgColor) {
    let src_icon = `launch_icon_${appName}.png`;
    const base_dir = `android/app/src/${appName}/res/`;
    const imgDirs = {'drawable': 1, 'drawable-v21': 2, "mipmap-mdpi": .5, "mipmap-hdpi": 1.5, "mipmap-xhdpi": 2, "mipmap-xxhdpi": 3, "mipmap-xxxhdpi": 3.5};

    for(let dir in imgDirs) {
         let percent = (imgDirs[dir] * 100);
         let dest_dir = base_dir + dir;
         let cmd = `convert -density 96 ${src_icon} -background '${bgColor}' -alpha remove -alpha off -resize ${percent}% "${dest_dir}/ic_launcher.png"`
         if (percent === 100) {
             cmd = `cp ${src_icon} ${dest_dir}/ic_launcher.png`
         }
         console.log(cmd);
         execSync(cmd);
    }

    let sizes = ['512x512'];
    sizes.forEach(size => {
        let cmd = `convert -density 96 ${src_icon} -background '${bgColor}' -alpha remove -alpha off -resize ${size} -gravity Center -extent ${size} "${base_dir}/${size}.png"`
        console.log(cmd);
        execSync(cmd);
    })


    src_icon = `launch_screen_${appName}.png`;
    sizes = ['1024x500'];
    sizes.forEach(size => {
        let cmd = `convert -density 96 ${src_icon} -background '${bgColor}' -alpha remove -alpha off -resize ${size} -gravity Center -extent ${size} "${base_dir}/${size}.png"`
        console.log(cmd);
        execSync(cmd);
    })

}

function buildiOSScreenshots(appName, startDims, bgColor) {
    const src_dir = `screenshots/${appName}/${startDims}`;
    const dest_dir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';

    const screenshots = fs.readdirSync(src_dir);
    screenshots.forEach((screenshot) => {
        if (screenshot.indexOf('.') === 0) return false;
        for(let type in devices) {
            const dest_dir = `screenshots/${appName}/gen/${type.replaceAll('.', '_')}`;
            fs.mkdirSync(dest_dir, {recursive: true});
            devices[type].forEach(size => {
                const filename = screenshot.replace('.png', `-${size}.png`).toLowerCase();
                let cmd = `convert -density 96 ${src_dir}/${screenshot} -background '${bgColor}' -alpha remove -alpha off -resize ${size} -gravity Center -extent ${size} ${dest_dir}/${filename}`
                console.log(cmd);
                execSync(cmd);
            });
        }
    })
}

function resizeScreenshots(appName, startDims, bgColor) {
    const src_dir = `screenshots/${appName}/${startDims}`;
    const screenshots = fs.readdirSync(src_dir);
    screenshots.forEach((screenshot) => {
        if (screenshot.indexOf('.') === 0) return false;
        let cmd = `convert -density 96 ${src_dir}/${screenshot} -background '${bgColor}' -alpha remove -alpha off -resize ${startDims} -gravity Center -extent ${startDims} ${src_dir}/${screenshot}`
        console.log(cmd);
        execSync(cmd);
    })
}

function buildAll(appName, size, bgColor) {
    buildiOSIcons(appName, bgColor);
    buildAndroidIcons(appName, bgColor);
    buildiOSLaunchScreens(appName, bgColor);
    // buildiOSScreenshots(appName, size, bgColor);
}


// resizeScreenshots('pickupmvp', '2048x2732', '#211645');
resizeScreenshots('pickupmvp', '1284x2778', '#211645');
// buildAll('trackauthoritymusic', '1125x2436', '#000000');
// buildAll('rapruler', '1125x2436', '#202020');
// buildAll('pickupmvp', '640x1136', '#211645');
