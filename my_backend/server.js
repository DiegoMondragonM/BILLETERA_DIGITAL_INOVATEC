// Importa los módulos necesarios, incluyendo crypto
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const mysql = require('mysql2');
const crypto = require('crypto'); // Importa crypto para el hashing

const app = express();

// Habilita CORS para permitir el acceso desde Flutter y otros clientes.
app.use(cors());

// Middleware para parsear solicitudes en formato JSON y URL encoded.
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Configura la conexión a MySQL (ajusta estos valores según tu entorno)
const connection = mysql.createConnection({
  host: '127.0.0.1',  // La IP local del servidor MySQL
  user: 'root',
  password: 'alexruth',
  database: 'billetera'
});

// Conecta a MySQL y reporta el estado
connection.connect(err => {
  if (err) {
    console.error("Error al conectar a MySQL: ", err);
  } else {
    console.log("Conexión a MySQL exitosa.");
  }
});

// Endpoint para registrar usuarios
// POST /register
app.post('/register', (req, res) => {
  const {
    nombre,
    apellidoPaterno,
    apellidoMaterno,
    correo,
    password   // ya hasheada por Flutter
  } = req.body;

  // Sentencia SQL usando correo_electronico como PK
  const query = `
    INSERT INTO usuarios
      (correo_electronico, nombre, apellido_paterno, apellido_materno, contrasena)
    VALUES (?, ?, ?, ?, ?)
  `;

  connection.query(
    query,
    [correo, nombre, apellidoPaterno, apellidoMaterno, password],
    (err, results) => {
      if (err) {
        console.error('Error al insertar usuario:', err);
        // Si ya existía ese correo → conflicto
        if (err.code === 'ER_DUP_ENTRY') {
          return res.status(409).json({
            error: 'El correo ya está registrado'
          });
        }
        return res.status(500).json({ error: err.message });
      }
      // Usuario creado correctamente
      res.status(201).json({
        correo: correo,
        message: 'Usuario registrado correctamente'
      });
    }
  );
});

// 1. POST /login
app.post('/login', (req, res) => {
  const { correo, password } = req.body;
  const sql = `
    SELECT correo_electronico, nombre, apellido_paterno, apellido_materno, contrasena
    FROM usuarios
    WHERE correo_electronico = ?
  `;
  connection.query(sql, [correo], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    if (results.length === 0) {
      return res.status(401).json({ error: 'Credenciales inválidas' });
    }
    const user = results[0];
    // Compara el hash enviado por Flutter con el que hay en BD
    if (user.contrasena !== password) {
      return res.status(401).json({ error: 'Credenciales inválidas' });
    }
    // Login OK → devolvemos datos mínimos
    res.json({
      correo: user.correo_electronico,
      nombre: user.nombre + ' ' + user.apellido_paterno
    });
  });
});


// 2. POST/add_card Inserta una tarjeta para el correo dado
app.post('/add_card', (req, res) => {
  const {
    correo_electronico,
    nombre_tarjeta,
    numero_tarjeta,
    tipo_tarjeta,
    monto,
    pin,
    fecha_vencimiento,
    color  // nuevo campo
  } = req.body;

  const sql = `
    INSERT INTO tarjetas 
      (correo_electronico, nombre_tarjeta, numero_tarjeta, tipo_tarjeta, monto, pin, fecha_vencimiento, color)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  `;
  connection.query(
    sql,
    [correo_electronico, nombre_tarjeta, numero_tarjeta, tipo_tarjeta, monto, pin, fecha_vencimiento, color],
    (err, result) => {
      if (err) {
        console.error('Error al insertar tarjeta:', err);
        return res.status(500).json({ error: err.message });
      }
      res.status(201).json({
        id: result.insertId,
        message: 'Tarjeta registrada correctamente'
      });
    }
  );
});

// GET /tarjetas/:correo  → devuelve todas las tarjetas de ese correo
app.get('/tarjetas/:correo', (req, res) => {
  const correo = req.params.correo;
  const sql = `
    SELECT id, nombre_tarjeta, numero_tarjeta, tipo_tarjeta,
           monto, pin, fecha_vencimiento, fecha_vinculacion, color
    FROM tarjetas
    WHERE correo_electronico = ?
  `;
  connection.query(sql, [correo], (err, rows) => {
    if (err) {
      console.error('Error al obtener tarjetas:', err);
      return res.status(500).json({ error: err.message });
    }
    res.json(rows);
  });
});


// DELETE /tarjetas/:id?correo_electronico=usuario@ejemplo.com
app.delete('/tarjetas/:id', (req, res) => {
  const id = req.params.id;
  // Se usa "correo_electronico" (o "correo" como fallback) según tu base de datos
  const correo = req.query.correo_electronico || req.query.correo;

  if (!correo) {
    return res.status(400).json({ error: 'Falta el parámetro correo_electronico' });
  }

  // 1) Verifica que la tarjeta exista y pertenezca al usuario.
  const selectSql = `
    SELECT * FROM tarjetas
    WHERE id = ? AND correo_electronico = ?
  `;
  connection.query(selectSql, [id, correo], (selectErr, rows) => {
    if (selectErr) {
      console.error('Error en SELECT antes de borrar:', selectErr);
      return res.status(500).json({ error: selectErr.message });
    }
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Tarjeta no encontrada' });
    }

    // Utilizar transacción para borrar movimientos y luego la tarjeta.
    connection.beginTransaction(transactionErr => {
      if (transactionErr) {
        console.error('Error iniciando la transacción:', transactionErr);
        return res.status(500).json({ error: transactionErr.message });
      }

      // 2) Borra los movimientos asociados a la tarjeta.
      const deleteMovSql = `
        DELETE FROM movimientos
        WHERE tarjeta_id = ?
      `;
      connection.query(deleteMovSql, [id], (deleteMovErr, resultMov) => {
        if (deleteMovErr) {
          console.error('Error al borrar movimientos:', deleteMovErr.message);
          return connection.rollback(() => {
            return res.status(500).json({ error: deleteMovErr.message });
          });
        }

        // 3) Borra la tarjeta.
        const deleteTarjetaSql = `
          DELETE FROM tarjetas
          WHERE id = ? AND correo_electronico = ?
        `;
        connection.query(deleteTarjetaSql, [id, correo], (deleteTarjetaErr, resultTarjeta) => {
          if (deleteTarjetaErr) {
            console.error('Error al borrar tarjeta:', deleteTarjetaErr.message);
            return connection.rollback(() => {
              return res.status(500).json({ error: deleteTarjetaErr.message });
            });
          }

          // 4) Confirma la transacción.
          connection.commit(commitErr => {
            if (commitErr) {
              console.error('Error al confirmar la transacción:', commitErr.message);
              return connection.rollback(() => {
                return res.status(500).json({ error: commitErr.message });
              });
            }
            return res.status(204).send();
          });
        });
      });
    });
  });
});

// Endpoint POST para registrar un nuevo movimiento
/**
 * POST /movimientos
 * Ahora esperamos también recibir `tarjeta_id` en el body.
 */
app.post('/movimientos', (req, res) => {
  const {
    correo_electronico,
    tarjeta_id,
    encabezado,
    tipo,
    monto,
    detalles,
    fecha_movimiento
  } = req.body;

  if (!correo_electronico || !tarjeta_id || !encabezado || !tipo || monto == null) {
    return res.status(400).json({ error: 'Faltan parámetros obligatorios.' });
  }

  const insertSql = `
    INSERT INTO movimientos
      (correo_electronico, tarjeta_id, encabezado, tipo, monto, detalles, fecha_movimiento)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `;
  const insertParams = [
    correo_electronico,
    tarjeta_id,
    encabezado,
    tipo,
    monto,
    detalles || null,
    fecha_movimiento || new Date()
  ];

  connection.query(insertSql, insertParams, (err, result) => {
    if (err) {
      console.error('Error al insertar movimiento:', err.message);
      return res.status(500).json({ error: err.message });
    }

    // --- Aquí actualizamos el saldo de la tarjeta ---
    const delta = (tipo === 'ingreso' ? 1 : -1) * parseFloat(monto);
    const updateSql = `
      UPDATE tarjetas
         SET monto = monto + ?
       WHERE id = ?
    `;
    connection.query(updateSql, [delta, tarjeta_id], (err2, updateResult) => {
      if (err2) {
        console.error('Error al actualizar saldo de tarjeta:', err2.message);
        // Podrías aquí enviar rollback si usaras transacciones
        return res.status(500).json({ error: err2.message });
      }

      console.log(`Tarjeta ${tarjeta_id} actualizada, filas afectadas:`, updateResult.affectedRows);
      return res.status(201).json({ id: result.insertId });
    });
  });
});



/**
 * GET /movimientos
 * Filtra por correo y por tarjeta_id para que no se mezclen
 */
app.get('/movimientos', (req, res) => {
  const correo = req.query.correo;
  const tarjetaId = parseInt(req.query.tarjeta_id, 10);

  if (!correo || isNaN(tarjetaId)) {
    return res.status(400).json({ error: 'Se requieren query params correo y tarjeta_id.' });
  }

  const sql = `
    SELECT
      id,
      correo_electronico AS correo,
      tarjeta_id,
      encabezado,
      tipo,
      monto,
      detalles,
      fecha_movimiento
    FROM movimientos
    WHERE correo_electronico = ?
      AND tarjeta_id       = ?
    ORDER BY fecha_movimiento DESC
  `;

  connection.query(sql, [correo, tarjetaId], (err, results) => {
    if (err) {
      console.error('Error al leer movimientos:', err.message);
      return res.status(500).json({ error: err.message });
    }
    res.json(results);
  });
});

app.use((req, res) => {
  console.log(`✘ Ruta no manejada: ${req.method} ${req.url}`);
  res.status(404).send('Not found');
});

// Endpoint para health check (para verificar que el servidor esté corriendo)
app.get('/health', (req, res) => res.status(200).send('OK'));

// Inicia el servidor en el puerto 3000 y escucha en todas las interfaces:
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Servidor corriendo en el puerto ${PORT} (0.0.0.0)`);
});