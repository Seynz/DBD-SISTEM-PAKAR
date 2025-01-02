require 'sinatra'
require 'sqlite3'
require 'time'

# Membuat dan menghubungkan ke database SQLite
db = SQLite3::Database.new 'database.db'

# Halaman utama untuk menampilkan aturan
get '/' do
  erb :index
end

# Menampilkan semua aturan beserta gejalanya
get '/aturan' do
  @aturan = db.execute <<-SQL
    SELECT aturan.id, aturan.nama
    FROM aturan
    GROUP BY aturan.id
  SQL
  erb :aturan
end



# Menampilkan semua gejala
get '/gejala' do
  @gejala = db.execute("SELECT * FROM gejala")
  erb :gejala
end

# Menampilkan semua history
get '/history' do
  @history = db.execute("SELECT * FROM history")
  erb :history
end

# Menambahkan aturan baru
post '/tambah_aturan' do
  nama = params[:nama]
  db.execute("INSERT INTO aturan (nama) VALUES (?)", nama)  # Hanya memasukkan nama
  redirect '/aturan'
end

# Menambahkan gejala baru
post '/tambah_gejala' do
  nama = params[:nama]
  db.execute("INSERT INTO gejala (nama) VALUES (?)", nama)
  redirect '/gejala'
end

# Menambahkan hubungan antara aturan dan gejala
post '/hubungkan_aturan_gejala' do
  aturan_id = params[:aturan_id]
  gejala_id = params[:gejala_id]
  db.execute("INSERT INTO aturan_gejala (aturan_id, gejala_id) VALUES (?, ?)", aturan_id, gejala_id)
  redirect '/aturan'
end

# Menambahkan entri history dengan waktu lokal
post '/tambah_history' do
  aturan_id = params[:aturan_id]
  waktu = Time.now.strftime("%Y-%m-%d %H:%M:%S")  # Waktu lokal
  db.execute("INSERT INTO history (aturan_id, waktu) VALUES (?, ?)", aturan_id, waktu)
  redirect '/history'
end

# Menghapus aturan beserta hubungannya dengan gejala
post '/hapus_aturan' do
  aturan_id = params[:aturan_id]
  db.execute("DELETE FROM aturan WHERE id = ?", aturan_id)
  db.execute("DELETE FROM aturan_gejala WHERE aturan_id = ?", aturan_id)
  redirect '/aturan'
end

# Menghapus gejala beserta hubungannya dengan aturan
post '/hapus_gejala' do
  gejala_id = params[:gejala_id]
  db.execute("DELETE FROM gejala WHERE id = ?", gejala_id)
  db.execute("DELETE FROM aturan_gejala WHERE gejala_id = ?", gejala_id)
  redirect '/gejala'
end

# Menghapus hubungan antara aturan dan gejala
post '/hapus_aturan_gejala' do
  aturan_id = params[:aturan_id]
  gejala_id = params[:gejala_id]
  db.execute("DELETE FROM aturan_gejala WHERE aturan_id = ? AND gejala_id = ?", aturan_id, gejala_id)
  redirect '/aturan'
end

# Menambahkan hubungan antara aturan dan gejala
post '/hubungkan_aturan_gejala' do
  aturan_id = params[:aturan_id]
  gejala_id = params[:gejala_id]
  
  # Memasukkan hubungan antara aturan dan gejala ke dalam tabel aturan_gejala
  db.execute("INSERT INTO aturan_gejala (aturan_id, gejala_id) VALUES (?, ?)", aturan_id, gejala_id)
  
  redirect '/aturan' # Redirect ke halaman aturan setelah hubungan terbuat
end

# Menghapus entri history
post '/hapus_history' do
  history_id = params[:history_id]
  db.execute("DELETE FROM history WHERE id = ?", history_id)
  redirect '/history'
end

# Logika Sistem Pakar - Menentukan aturan yang sesuai dengan gejala yang diberikan
post '/diagnosa' do
  gejala_input = params[:gejala] # gejala yang dikirimkan oleh pengguna, dalam bentuk array
  gejala_ids = gejala_input.map { |g| db.execute("SELECT id FROM gejala WHERE nama = ?", g).flatten.first }

  # Mencari aturan yang memiliki gejala yang sama
  matching_aturan = db.execute <<-SQL
    SELECT aturan.id, aturan.nama, GROUP_CONCAT(gejala.nama) AS gejala
    FROM aturan
    LEFT JOIN aturan_gejala ON aturan.id = aturan_gejala.aturan_id
    LEFT JOIN gejala ON aturan_gejala.gejala_id = gejala.id
    WHERE gejala.id IN (#{gejala_ids.join(',')})
    GROUP BY aturan.id
    HAVING COUNT(gejala.id) = #{gejala_ids.length}
  SQL

  if matching_aturan.empty?
    "Diagnosis tidak ditemukan untuk gejala tersebut."
  else
    # Menyimpan history diagnosis
    aturan_id = matching_aturan.first[0]
    waktu = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    db.execute("INSERT INTO history (aturan_id, waktu) VALUES (?, ?)", aturan_id, waktu)

    "Diagnosis ditemukan: #{matching_aturan.map { |aturan| aturan[1] }.join(', ')}"
  end
end
