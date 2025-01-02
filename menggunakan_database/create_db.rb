require 'sinatra'
require 'sqlite3'
require 'time'

# Membuat dan menghubungkan ke database SQLite
db = SQLite3::Database.new 'database.db'

# Membuat tabel aturan
db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS aturan (
    id INTEGER PRIMARY KEY,
    nama TEXT
  );
SQL

# Membuat tabel gejala
db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS gejala (
    id INTEGER PRIMARY KEY,
    nama TEXT
  );
SQL

# Membuat tabel hubungan antara aturan dan gejala
db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS aturan_gejala (
    id INTEGER PRIMARY KEY,
    aturan_id INTEGER,
    gejala_id INTEGER,
    FOREIGN KEY (aturan_id) REFERENCES aturan(id),
    FOREIGN KEY (gejala_id) REFERENCES gejala(id)
  );
SQL

# Membuat tabel history
db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS history (
    id INTEGER PRIMARY KEY,
    aturan_id INTEGER,
    waktu TEXT,
    FOREIGN KEY (aturan_id) REFERENCES aturan(id)
  );
SQL
