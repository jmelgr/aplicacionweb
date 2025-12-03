require('dotenv').config(); 
const express = require('express');
const cors = require('cors');  
const multer = require('multer');
const { v4: uuidv4 } = require('uuid');
const db = require('./db');
const s3 = require('./s3');
const AWS = require('aws-sdk');

const app = express();

// Uso CORS para que mi backend y frontend puedan comunicarse
app.use(cors({
  origin: "*",
  methods: "GET,POST",
}));

const port = process.env.PORT || 3000;
const upload = multer({ storage: multer.memoryStorage() });

// Configuro SNS para que publique el mensaje a ambas Lambdas
const sns = new AWS.SNS({
  region: process.env.AWS_REGION || 'us-east-1'
});
const SNS_TOPIC_ARN = process.env.SNS_TOPIC_ARN;

app.use(express.json());

app.post('/upload', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).send('No se envió archivo');

    const uuid = uuidv4();
    const filename = req.file.originalname;

    await s3.uploadFile(filename, req.file.buffer);

    const messageBody = JSON.stringify({ uuid, filename, estado: 'pendiente' });
    console.log('Publicando en SNS:', messageBody);
    await sns.publish({ TopicArn: SNS_TOPIC_ARN, Message: messageBody }).promise();

    res.json({ message: 'Archivo subido', uuid });
  } catch (err) {
    console.error(err);
    res.status(500).send('Error al subir archivo');
  }
});

app.get('/download/:uuid', async (req, res) => {
  const { uuid } = req.params;

  try {
    const archivo = await db.getArchivo(uuid);
    if (!archivo) return res.status(404).send('Código inválido');

    if (archivo.estado === 'usado') return res.status(400).send('El archivo ya ha sido descargado');

    const fileBuffer = await s3.getFile(archivo.filename);

    const messageBody = JSON.stringify({ uuid });
    await sns.publish({ TopicArn: SNS_TOPIC_ARN, Message: messageBody }).promise();

    res.setHeader('Content-Disposition', `attachment; filename=${archivo.filename}`);
    res.send(fileBuffer);
  } catch (err) {
    console.error(err);
    res.status(500).send('Error al procesar solicitud');
  }
});

app.get('/health', (req, res) => {
  res.status(200).send('OK');
});

app.listen(port, () => {
  console.log(`Servidor corriendo en http://localhost:${port}`);
});
