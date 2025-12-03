const AWS = require('aws-sdk');
const { Client } = require('pg');

const s3 = new AWS.S3();

exports.handler = async (event) => {
  const client = new Client({
    host: process.env.DB_HOST,
    user: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: 5432,
    ssl: { rejectUnauthorized: false }
  });

  try {
    await client.connect();

    const res = await client.query('SELECT uuid, filename FROM archivos WHERE estado = $1', ['usado']);

    for (const row of res.rows) {
      const { filename, uuid } = row;

      await client.query('UPDATE archivos SET estado = $1 WHERE uuid = $2', ['borrado', uuid]);
      
      await s3.deleteObject({
        Bucket: process.env.S3_BUCKET,
        Key: filename
      }).promise();

      console.log(`Archivo ${filename} (UUID: ${uuid}) eliminado de S3`);

    }

  } catch (err) {
    console.error('Error en Lambda Cleanup:', err);
  } finally {
    await client.end();
  }

  return { statusCode: 200, body: 'Cleanup completado' };
};
