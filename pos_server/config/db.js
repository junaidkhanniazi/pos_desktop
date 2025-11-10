import mysql from "mysql2/promise";

export const pool = mysql.createPool({
  host: "localhost", // your MySQL host
  user: "root", // your MySQL username
  password: "", // your MySQL password
  database: "desktop_pos", // your MySQL DB name
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});
