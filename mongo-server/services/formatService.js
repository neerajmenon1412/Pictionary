const ffmpeg = require('fluent-ffmpeg');
const path = require('path');
const fs = require('fs');

const processedDir = path.join(__dirname, '../processed');
const uploadsDir = path.join(__dirname, '../uploads');

// Ensure the processed directory exists
if (!fs.existsSync(processedDir)){
    fs.mkdirSync(processedDir);
}

// Ensure the processed directory exists
if (!fs.existsSync(uploadsDir)){
    fs.mkdirSync(uploadsDir);
}

exports.processAndSaveVideo = (videoFile) => {
    const resolutions = [240, 720, 1080];

    const saveVideo = (resolution) => {
        return new Promise((resolve, reject) => {
            const outputFilePath = path.join(processedDir, `${videoFile.filename}-${resolution}p.mp4`);
            ffmpeg(path.join(uploadsDir, videoFile.filename))
                .size(`${resolution}x?`)
                .output(outputFilePath)
                .on('end', () => {
                    resolve({ resolution, path: outputFilePath });
                    // Delete the temporary file after processing
                    fs.unlink(path.join(uploadsDir, videoFile.filename), (err) => {
                        if (err) console.error(`Error deleting temporary file: ${err}`);
                    });
                })
                .on('error', (err) => {
                    reject(err);
                })
                .run();
        });
    };

    const promises = resolutions.map(saveVideo);
    return Promise.all(promises).then(results => {
        const videoData = {
            name: videoFile.originalname,
            formats: results.map(r => ({ resolution: r.resolution, path: r.path })),
            createdAt: new Date()
        };
        // Save video metadata to a local file
        const metadataFilePath = path.join(processedDir, `${videoFile.filename}.json`);
        fs.writeFileSync(metadataFilePath, JSON.stringify(videoData, null, 2));
        return videoData;
    });
};

exports.getVideoPath = (filename, clarity) => {
    const metadataFilePath = path.join(processedDir, `${filename}.json`);
    if (!fs.existsSync(metadataFilePath)) {
        throw new Error('Video not found');
    }
    const videoData = JSON.parse(fs.readFileSync(metadataFilePath));
    const format = videoData.formats.find(f => f.resolution == clarity);
    if (!format) {
        throw new Error('Resolution not found');
    }
    return path.resolve(format.path);
};
