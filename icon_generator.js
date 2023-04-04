const fs = require("fs");
const execSync = require("child_process").execSync;

function buildiOSIcons() {
    const src_icon = 'launch_icon.png';
    const dest_dir='ios/Runner/Assets.xcassets/AppIcon.appiconset';

    let contents = JSON.parse(fs.readFileSync('ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json', 'utf8'));
    contents.images.forEach(img => {
        if (typeof img.filename === 'undefined') {
            img.filename = `${img.idiom}-${img.size.replaceAll('.', '_')}@${img.scale}.png`;
        }
        let realsize = img.size.split('x');
        let scale = parseInt(img.scale.charAt(0));
        realsize[0] = realsize[0] * scale;
        realsize[1] = realsize[1] * scale;
        let cmd = `convert -density 1536 ${src_icon} -background '#211645' -alpha remove -alpha off -resize ${realsize.join('x')} "${dest_dir}/${img.filename}"`
        console.log(cmd);
        execSync(cmd);
    })
    fs.writeFileSync('ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json', JSON.stringify(contents, null, 2), 'utf8');
}

function buildiOSScreenshots() {
    const devices = {
        "6.7" : ["1290x2796"],
        "6.5" : ["1242x2688", "1284x2778"],
        "5.5" : ["1242x2208"],
        "12.9" : ["2048x2732"]
    }
    const src_dir = 'screenshots/640x1136';

    const screenshots = fs.readdirSync(src_dir);
    screenshots.forEach((screenshot) => {
        if (screenshot.indexOf('.') === 0) return false;
        for(let type in devices) {
            const dest_dir = `screenshots/gen/${type.replaceAll('.', '_')}`;
            fs.mkdirSync(dest_dir, {recursive: true});
            devices[type].forEach(size => {
                const filename = screenshot.replace('.png', `-${size}.png`);
                let cmd = `convert -density 1536 ${src_dir}/${screenshot} -background '#211645' -alpha remove -alpha off -resize ${size} -gravity Center -extent ${size} ${dest_dir}/${filename}`
                console.log(cmd);
                execSync(cmd);
            });
        }
    })

}


buildiOSScreenshots();