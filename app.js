require('dotenv').config();
const express = require('express');
const { postgraphile } = require('postgraphile');

const PORT = process.env.PORT || 3000;

const postgresConfig = {
  user: process.env.POSTGRES_USERNAME,
  password: process.env.POSTGRES_PASSWORD,
  host: process.env.POSTGRES_HOST,
  port: process.env.POSTGRES_PORT,
  database: process.env.POSTGRES_DATABASE
};

const app = express();

app.use(
  postgraphile(postgresConfig, process.env.POSTGRAPHILE_SCHEMA, {
    watchPg: true,
    graphiql: true,
    enhanceGraphiql: true,
    jwtPgTypeIdentifier: `${process.env.POSTGRAPHILE_SCHEMA}.jwt_token`,
    jwtSecret: process.env.JWT_SECRET,
    pgDefaultRole: process.env.POSTGRAPHILE_DEFAULT_ROLE
    // pgSettings: req => ({ 'jwt.claims.user_id': req.user ? req.user.id : undefined })
  })
);

app.listen(PORT, () => {
  console.log('server is up');
});
