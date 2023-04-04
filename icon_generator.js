const fs = require("fs");
const execSync = require("child_process").execSync;
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
    let cmd = `convert -density 1536 -background none ${src_icon} -resize ${realsize.join('x')} "${dest_dir}/${img.filename}"`
    console.log(cmd);
    execSync(cmd);
})
fs.writeFileSync('ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json', JSON.stringify(contents, null, 2), 'utf8');
