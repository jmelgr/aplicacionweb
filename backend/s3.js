const AWS = require('aws-sdk');

const s3 = new AWS.S3({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION
});

async function uploadFile(key, fileBuffer) {
  const params = {
    Bucket: process.env.S3_BUCKET,
    Key: key,
    Body: fileBuffer
  };

  return s3.upload(params).promise();
}

async function getFile(key) {
  const params = {
    Bucket: process.env.S3_BUCKET,
    Key: key
  };

  const data = await s3.getObject(params).promise();
  return data.Body;
}

module.exports = { uploadFile, getFile };
