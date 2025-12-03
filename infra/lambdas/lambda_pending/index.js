const { Client } = require('pg');

exports.handler = async (event) => {
  for (const record of event.Records) {
    const body = JSON.parse(record.Sns.Message);
    const uuid = body.uuid;
    const filename = body.filename || null;
    const estado = body.estado || null;

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

      const res = await client.query('SELECT * FROM archivos WHERE uuid = $1', [uuid]);

      if (res.rowCount === 0 && estado === 'pendiente') {
        await client.query(
          'INSERT INTO archivos (uuid, filename, estado) VALUES ($1, $2, $3)',
          [uuid, filename, 'pendiente']
        );
      } else if (res.rowCount > 0 && !estado) {
        await client.query('UPDATE archivos SET estado = $1 WHERE uuid = $2', ['usado', uuid]);
      } else if (res.rowCount === 0 && !estado) {
        console.log(`Código inválido: ${uuid}`);
      }

    } catch (err) {
      console.error('Error al conectar o modificar RDS:', err);
    } finally {
      await client.end();
    }
  }

  return { statusCode: 200, body: 'Procesado' };
};
