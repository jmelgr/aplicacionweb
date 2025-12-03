const { Pool } = require('pg');

// Con esto se crea la conexion con variables de entorno
const pool = new Pool({
  host: process.env.DB_HOST,
  user: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT,
  ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false 
});

// Esto lo uso para debuggear si se establece la conexion en local
pool.connect((err, client, release) => {
  if (err) {
    console.error('Error conectando a RDS:', err);
  } else {
    console.log('Conectado correctamente a RDS');
  }
  release();
});

async function getArchivo(uuid) {
  const res = await pool.query('SELECT * FROM archivos WHERE uuid = $1', [uuid]);
  return res.rows[0];
}

async function getAllArchivos() {
  const res = await pool.query('SELECT * FROM archivos');
  return res.rows;
}

module.exports = { pool, getArchivo, getAllArchivos };
